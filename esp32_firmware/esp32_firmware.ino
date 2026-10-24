/*
 ==============================================================================
  Project: Smart Item Lost Finder - ESP32 Dual Mode (UDP Discovery + Firebase)
  Firebase Project: lostitemfinder-aab53
  Hotspot Wi-Fi   : SSID="vivoy200" | Pass="77777777"
  UDP Discovery   : Port 4210
  HTTP Server     : Port 80 (/trigger, /status)
 ==============================================================================
*/

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ESPmDNS.h>
#include <WebServer.h>
#include <WiFiUdp.h>

// ======================== CONFIGURATION ========================
// 1. Wi-Fi Hotspot Credentials
const char* WIFI_SSID     = "vivoy200";
const char* WIFI_PASSWORD = "77777777";

// 2. Firebase Realtime Database URL
const char* FIREBASE_HOST = "https://lostitemfinder-aab53-default-rtdb.asia-southeast1.firebasedatabase.app";
const char* DEVICE_ID     = "device_01";

// 3. Hardware Pin Definitions
const int TRIGGER_PIN = 25;  // GPIO 25 connected to Remote Button Signal Pin
const int STATUS_LED  = 2;   // On-board blue LED indicator

// 4. Double-Beep Timing Configuration (in milliseconds)
const int BEEP_PULSE_MS = 800; // 0.8 second each beep
const int BEEP_PAUSE_MS = 400; // 0.4 second silence between beeps

// 5. UDP Discovery Port
const unsigned int UDP_PORT = 4210;

// ===============================================================

WebServer server(80);
WiFiUDP udp;
bool isTriggering = false;
unsigned long lastFirebasePoll = 0;
unsigned long lastUdpBroadcast = 0;
const unsigned long FIREBASE_POLL_INTERVAL = 2000;

void releaseButton() {
  pinMode(TRIGGER_PIN, INPUT);
  digitalWrite(STATUS_LED, LOW);
}

void pressButton() {
  digitalWrite(STATUS_LED, HIGH);
  pinMode(TRIGGER_PIN, OUTPUT);
  digitalWrite(TRIGGER_PIN, LOW); // Pulls remote button to GND
}

void triggerDoubleBeep() {
  if (isTriggering) return;
  isTriggering = true;

  Serial.println("\n==============================================");
  Serial.println("  >>> TRIGGERING DOUBLE BEEP (BEEP - BEEP)! <<< ");
  Serial.println("==============================================");
  
  // --- BEEP #1 ---
  Serial.println(" 🔊 [PULSE 1] BEEP #1 (GPIO 25 -> GND for 0.8s)...");
  pressButton();
  delay(BEEP_PULSE_MS);
  
  // --- PAUSE ---
  Serial.println(" ⏸️ [PAUSE]   Silence (GPIO 25 -> Floating for 0.4s)...");
  releaseButton();
  delay(BEEP_PAUSE_MS);
  
  // --- BEEP #2 ---
  Serial.println(" 🔊 [PULSE 2] BEEP #2 (GPIO 25 -> GND for 0.8s)...");
  pressButton();
  delay(BEEP_PULSE_MS);
  
  // --- HARD STOP & RELEASE ---
  releaseButton();
  Serial.println(" 🛑 [STOP]    Finished! Button released. Remote in Standby.");
  Serial.println("==============================================\n");

  while (Serial.available() > 0) {
    Serial.read();
  }
  
  isTriggering = false;
}

void resetFirebaseCommand() {
  if (WiFi.status() != WL_CONNECTED) return;
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  String url = String(FIREBASE_HOST) + "/smart_item_finder/" + String(DEVICE_ID) + ".json";
  if (http.begin(client, url)) {
    http.addHeader("Content-Type", "application/json");
    http.PATCH("{\"findCommand\":false,\"deviceStatus\":\"online\",\"lastCommand\":\"COMPLETED\"}");
    http.end();
  }
}

void checkFirebase() {
  if (WiFi.status() != WL_CONNECTED) return;
  
  WiFiClientSecure client;
  client.setInsecure();
  HTTPClient http;
  http.setFollowRedirects(HTTPC_FORCE_FOLLOW_REDIRECTS);
  http.setTimeout(2500);
  String url = String(FIREBASE_HOST) + "/smart_item_finder/" + String(DEVICE_ID) + ".json";
  
  if (http.begin(client, url)) {
    int httpCode = http.GET();
    if (httpCode == 200) {
      String payload = http.getString();
      StaticJsonDocument<256> doc;
      DeserializationError error = deserializeJson(doc, payload);
      
      if (!error) {
        bool findCommand = doc["findCommand"] | false;
        if (findCommand) {
          Serial.println("[Firebase] Incoming FIND ITEM command detected!");
          triggerDoubleBeep();
          resetFirebaseCommand();
        }
      }
    } else if (httpCode == 401) {
      static unsigned long last401Msg = 0;
      if (millis() - last401Msg > 20000) {
        last401Msg = millis();
        Serial.println("[Firebase 401] Unauthorized! Check Realtime Database Rules: set .read: true, .write: true");
      }
    }
    http.end();
  }
}

void handleUdpDiscovery() {
  // 1. Process incoming discovery queries & triggers
  int packetSize = udp.parsePacket();
  if (packetSize > 0) {
    char packetBuffer[255];
    int len = udp.read(packetBuffer, 254);
    if (len > 0) packetBuffer[len] = 0;
    
    String msg = String(packetBuffer);
    msg.trim();
    Serial.print("[UDP Packet from ");
    Serial.print(udp.remoteIP());
    Serial.print("]: ");
    Serial.println(msg);

    // Direct Instant Trigger over UDP
    if (msg.indexOf("TRIGGER") >= 0 || msg.indexOf("BEEP") >= 0 || msg.indexOf("FIND") >= 0) {
      Serial.println(">>> [UDP COMMAND] Double Beep Triggered via Mobile App! <<<");
      triggerDoubleBeep();
    }
    
    // Reply back with IP and ID
    String reply = "{\"type\":\"SMART_FINDER_BEACON\",\"ip\":\"" + WiFi.localIP().toString() + "\",\"device\":\"device_01\"}";
    udp.beginPacket(udp.remoteIP(), udp.remotePort());
    udp.print(reply);
    udp.endPacket();
  }

  // 2. Periodic Broadcast every 3 seconds so the app automatically discovers ESP32
  if (millis() - lastUdpBroadcast > 3000 && WiFi.status() == WL_CONNECTED) {
    lastUdpBroadcast = millis();
    IPAddress broadcastIp = WiFi.localIP();
    broadcastIp[3] = 255; // Subnet broadcast
    
    String beacon = "{\"type\":\"SMART_FINDER_BEACON\",\"ip\":\"" + WiFi.localIP().toString() + "\",\"device\":\"device_01\"}";
    udp.beginPacket(broadcastIp, UDP_PORT);
    udp.print(beacon);
    udp.endPacket();
  }
}

void handleSerialCli() {
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    input.trim();
    input.toLowerCase();
    
    if (input == "1" || input == "find" || input == "beep" || input == "f" || input == "") {
      triggerDoubleBeep();
    } 
    else if (input == "2" || input == "stop" || input == "s") {
      releaseButton();
      Serial.println("[FORCE STOP] Button Released.\n");
    }
    
    while (Serial.available() > 0) {
      Serial.read();
    }
  }
}

// HTTP API Handlers for Mobile App
void handleRoot() {
  String html = "<!DOCTYPE html><html><head><meta name='viewport' content='width=device-width, initial-scale=1'><title>Smart Finder</title>";
  html += "<style>body{font-family:sans-serif;text-align:center;padding:40px;background:#090D16;color:white;}";
  html += ".btn{display:inline-block;padding:24px 48px;background:#10B981;color:white;text-decoration:none;border-radius:30px;font-size:24px;font-weight:900;box-shadow:0 12px 30px rgba(16,185,129,0.5);}";
  html += "</style></head><body>";
  html += "<h2>🛰️ Smart Item Lost Finder</h2>";
  html += "<p>Hotspot: <b>" + String(WIFI_SSID) + "</b></p>";
  html += "<p>ESP32 IP: <b>" + WiFi.localIP().toString() + "</b></p><br><br>";
  html += "<a href='/trigger' class='btn'>🔊 BEEP BUZZER</a>";
  html += "</body></html>";
  server.send(200, "text/html", html);
}

void handleTrigger() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  triggerDoubleBeep();
  server.send(200, "application/json", "{\"status\":\"success\",\"message\":\"Double Beep Triggered\",\"ip\":\"" + WiFi.localIP().toString() + "\"}");
}

void handleStatus() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", "{\"deviceStatus\":\"online\",\"ip\":\"" + WiFi.localIP().toString() + "\",\"device\":\"device_01\"}");
}

void setup() {
  Serial.begin(115200);
  delay(500);
  
  pinMode(STATUS_LED, OUTPUT);
  releaseButton();
  
  Serial.println("\n==============================================");
  Serial.println("  Smart Lost Finder - Ready!                  ");
  Serial.println("  Hotspot: vivoy200 (Pass: 77777777)          ");
  Serial.println("==============================================");
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  Serial.print("Connecting to Wi-Fi '");
  Serial.print(WIFI_SSID);
  Serial.print("'");
  while (WiFi.status() != WL_CONNECTED && attempts < 25) {
    delay(400);
    Serial.print(".");
    digitalWrite(STATUS_LED, !digitalRead(STATUS_LED));
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    digitalWrite(STATUS_LED, LOW);
    Serial.println("\n\n>>> [Wi-Fi SUCCESS] Connected to " + String(WIFI_SSID) + " <<<");
    Serial.println(">>> ESP32 IP ADDRESS: " + WiFi.localIP().toString() + " <<<");
    Serial.println(">>> Direct Web Trigger: http://" + WiFi.localIP().toString() + "/trigger <<<\n");
    
    if (MDNS.begin("smartfinder")) {
      MDNS.addService("http", "tcp", 80);
    }
    
    udp.begin(UDP_PORT);
    Serial.println("[UDP] Auto-discovery listener started on port " + String(UDP_PORT));
  } else {
    Serial.println("\n[Wi-Fi] Reconnecting in background...");
  }
  
  server.on("/", handleRoot);
  server.on("/trigger", handleTrigger);
  server.on("/beep", handleTrigger);
  server.on("/status", handleStatus);
  server.begin();
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    static unsigned long lastReconnect = 0;
    if (millis() - lastReconnect > 5000) {
      lastReconnect = millis();
      WiFi.reconnect();
    }
  } else {
    // 1. Process UDP Auto-discovery beacon / queries
    handleUdpDiscovery();

    // 2. Poll Firebase Realtime Database
    if (millis() - lastFirebasePoll > FIREBASE_POLL_INTERVAL) {
      lastFirebasePoll = millis();
      checkFirebase();
    }
  }
  
  handleSerialCli();
  server.handleClient();
}

