# 🛰️ Smart Item Lost Finder — Complete Hardware & Circuit Setup Guide

This guide provides the complete blueprint for your IoT Item Tracker using:
**Mobile App → Firebase Realtime DB → ESP32 → MOSFET Switch → 433 MHz RF Remote → 433 MHz Receiver → Buzzer Alert**

---

## 📐 System Architecture Diagram

```
┌────────────────────────────────┐
│   Flutter Mobile Application   │
│       [ FIND ITEM (BEEP) ]     │
└───────────────┬────────────────┘
                │
                │ Internet (HTTPS REST)
                ▼
┌────────────────────────────────┐
│   Firebase Realtime Database   │
│   /smart_item_finder/device_01 │
│      { "findCommand": true }   │
└───────────────┬────────────────┘
                │
                │ Wi-Fi Poll / Stream
                ▼
┌────────────────────────────────┐
│      ESP32 Wi-Fi Controller    │
│      (GPIO 25 Trigger Pin)     │
└───────────────┬────────────────┘
                │
                │ 3.3V Pulse (Gate)
                ▼
┌────────────────────────────────┐
│   MOSFET / Electronic Switch   │
│   (Shorts Forward Button)      │
└───────────────┬────────────────┘
                │
                │ Closes T1 & T2 Terminals
                ▼
┌────────────────────────────────┐
│    433 MHz RF Toy Remote       │
│    (Transmits Forward Burst)   │
└───────────────┬────────────────┘
                │
                │ 433 MHz RF Over-the-Air
                ▼
┌────────────────────────────────┐
│    433 MHz RF Toy Receiver     │
│    (Motor Output H-Bridge)     │
└───────────────┬────────────────┘
                │
                │ Voltage Output
                ▼
┌────────────────────────────────┐
│      5V Active Buzzer          │
│    🔊 LOUD AUDIBLE BEEP! 🔊    │
└────────────────────────────────┘
```

---

## ⚡ Circuit Wiring & Connections

### 1. ESP32 to 433 MHz RF Remote Button
| ESP32 Pin | Component | Target Connection |
| :--- | :--- | :--- |
| **GPIO 25** | 1 kΩ Resistor | **Gate (G)** of 2N7000 / BS170 MOSFET (or Base of 2N2222) |
| **GND** | Direct Jumper Wire | **RF Remote GND / Battery (-)** |
| — | **MOSFET Drain (D)** | **Forward Button Terminal 1 (T1)** |
| — | **MOSFET Source (S)** | **Forward Button Terminal 2 (T2)** |
| **GPIO 2** | Built-in Blue LED | Visual indicator on ESP32 |

> 💡 *Note: The MOSFET acts as a voltage-controlled electronic switch. When ESP32 GPIO 25 goes HIGH (3.3V), the Drain and Source conduct, electronically simulating a physical press on the forward button!*

---

### 2. 433 MHz RF Receiver to Buzzer
| Receiver Output | Buzzer Connection |
| :--- | :--- |
| **Motor Forward (+) Wire** | **Buzzer Red Positive (+) Wire** |
| **Motor Forward (-) Wire** | **Buzzer Black Negative (-) Wire** |

> 💡 *Note: In toy-car receivers, pressing "Forward" supplies positive voltage to the forward motor channel. Connecting the buzzer across these wires makes the buzzer beep whenever the forward command is active!*

---

## 💻 ESP32 Firmware Instructions

The firmware sketch is located at [`esp32_firmware/smart_item_finder_esp32.ino`](file:///c:/Users/Bipin/Desktop/HEERU%20APP/esp32_firmware/smart_item_finder_esp32.ino).

### Steps to Flash:
1. Open **Arduino IDE**.
2. Install **ESP32 Board Package** via *Tools → Board Manager → esp32 by Espressif*.
3. Install **ArduinoJson** library via *Tools → Manage Libraries → ArduinoJson (by Benoit Blanchon)*.
4. Open `esp32_firmware/smart_item_finder_esp32.ino`.
5. Update your Wi-Fi credentials:
   ```cpp
   const char* WIFI_SSID     = "YOUR_WIFI_NAME";
   const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
   ```
6. Update your Firebase Realtime Database URL:
   ```cpp
   const char* FIREBASE_HOST = "https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com";
   const char* DEVICE_ID     = "device_01";
   ```
7. Select your ESP32 board in Arduino IDE and click **Upload**.
8. Open the Serial Monitor at `115200 baud` to see live Wi-Fi connection and trigger logs!

---

## 📱 Mobile App Usage

1. Open the **Smart Item Lost Finder** app.
2. In **Settings → ESP32 & RF Remote Hub**, enter your Firebase Database URL or switch to **Direct LAN Mode** if using local Wi-Fi.
3. Tap **"TEST TRIGGER (BEEP BUZZER)"** to test your setup anytime.
4. On any tracked item, tap **"Find Item"** to launch the Sonar Radar HUD and automatically trigger the 433 MHz remote via ESP32!
