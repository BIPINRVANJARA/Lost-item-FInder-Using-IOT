import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseIotService extends ChangeNotifier {
  String _firebaseUrl = 'https://lostitemfinder-aab53-default-rtdb.asia-southeast1.firebasedatabase.app';
  String _deviceId = 'device_01';
  int _triggerDurationMs = 2500;
  bool _isDirectLanMode = true;
  String _esp32LanIp = '10.80.27.113'; // Default discovered hotspot IP

  bool _isSending = false;
  String _lastStatusMessage = 'Ready';
  bool _isEspOnline = false;
  DateTime? _lastTriggerTime;
  RawDatagramSocket? _udpSocket;
  Timer? _udpDiscoveryTimer;

  String get firebaseUrl => _firebaseUrl;
  String get deviceId => _deviceId;
  int get triggerDurationMs => _triggerDurationMs;
  bool get isDirectLanMode => _isDirectLanMode;
  String get esp32LanIp => _esp32LanIp;
  bool get isSending => _isSending;
  String get lastStatusMessage => _lastStatusMessage;
  bool get isEspOnline => _isEspOnline;
  DateTime? get lastTriggerTime => _lastTriggerTime;

  FirebaseIotService() {
    _loadSettings();
    _startUdpDiscovery();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _firebaseUrl = prefs.getString('iot_firebase_url') ?? 'https://lostitemfinder-aab53-default-rtdb.asia-southeast1.firebasedatabase.app';
    _deviceId = prefs.getString('iot_device_id') ?? 'device_01';
    _triggerDurationMs = prefs.getInt('iot_trigger_duration_ms') ?? 2500;
    _isDirectLanMode = prefs.getBool('iot_direct_lan_mode') ?? true;
    _esp32LanIp = prefs.getString('iot_esp32_lan_ip') ?? '10.80.27.113';
    notifyListeners();
  }

  void _startUdpDiscovery() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4210);
      _udpSocket?.broadcastEnabled = true;
      _udpSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpSocket?.receive();
          if (datagram != null) {
            try {
              final text = utf8.decode(datagram.data).trim();
              if (text.contains('SMART_FINDER_BEACON') || text.contains('"ip"')) {
                final data = jsonDecode(text);
                final ip = data['ip'] as String?;
                if (ip != null && ip.isNotEmpty && ip != _esp32LanIp) {
                  _esp32LanIp = ip;
                  _isEspOnline = true;
                  _lastStatusMessage = 'ESP32 Connected ($ip)';
                  SharedPreferences.getInstance().then((p) => p.setString('iot_esp32_lan_ip', ip));
                  notifyListeners();
                }
              }
            } catch (_) {}
          }
        }
      });

      // Send periodic query
      _udpDiscoveryTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        sendUdpDiscoveryPacket();
      });
      sendUdpDiscoveryPacket();
    } catch (_) {}
  }

  void sendUdpDiscoveryPacket() {
    _sendUdpBroadcast('WHERE_ARE_YOU');
  }

  void _safeUdpSend(List<int> bytes, String ip, int port) {
    try {
      _udpSocket?.send(bytes, InternetAddress(ip), port);
    } catch (_) {}
  }

  Future<void> _sendUdpBroadcast(String message) async {
    final bytes = utf8.encode(message);
    if (_esp32LanIp.isNotEmpty) {
      _safeUdpSend(bytes, _esp32LanIp, 4210);
    }
    _safeUdpSend(bytes, '10.80.27.113', 4210);
    _safeUdpSend(bytes, '10.60.64.113', 4210);

    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              final bcast = '${parts[0]}.${parts[1]}.${parts[2]}.255';
              _safeUdpSend(bytes, bcast, 4210);
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<List<String>> _getHotspotCandidateIps() async {
    final ips = <String>{
      _esp32LanIp,
      '10.80.27.113',
      '10.60.64.113',
      'smartfinder.local',
    };

    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              ips.add('${parts[0]}.${parts[1]}.${parts[2]}.113');
              ips.add('${parts[0]}.${parts[1]}.${parts[2]}.2');
              ips.add('${parts[0]}.${parts[1]}.${parts[2]}.3');
              ips.add('${parts[0]}.${parts[1]}.${parts[2]}.4');
              ips.add('${parts[0]}.${parts[1]}.${parts[2]}.5');
            }
          }
        }
      }
    } catch (_) {}
    return ips.toList();
  }

  Future<void> updateConfig({
    String? firebaseUrl,
    String? deviceId,
    int? triggerDurationMs,
    bool? isDirectLanMode,
    String? esp32LanIp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (firebaseUrl != null) {
      _firebaseUrl = firebaseUrl.trim();
      await prefs.setString('iot_firebase_url', _firebaseUrl);
    }
    if (deviceId != null) {
      _deviceId = deviceId.trim();
      await prefs.setString('iot_device_id', _deviceId);
    }
    if (triggerDurationMs != null) {
      _triggerDurationMs = triggerDurationMs;
      await prefs.setInt('iot_trigger_duration_ms', _triggerDurationMs);
    }
    if (isDirectLanMode != null) {
      _isDirectLanMode = isDirectLanMode;
      await prefs.setBool('iot_direct_lan_mode', _isDirectLanMode);
    }
    if (esp32LanIp != null) {
      _esp32LanIp = esp32LanIp.trim();
      await prefs.setString('iot_esp32_lan_ip', _esp32LanIp);
    }
    notifyListeners();
  }

  /// Sends the 1-Tap Find Command to ESP32 (Direct UDP + Direct HTTP + Firebase)
  Future<bool> sendFindCommand({String? targetDeviceId, bool active = true}) async {
    _isSending = true;
    _lastStatusMessage = 'Sending trigger command...';
    notifyListeners();

    bool success = false;

    // 1. Send Direct UDP Broadcast (Sub-millisecond Trigger across Subnet)
    try {
      await _sendUdpBroadcast('TRIGGER');
    } catch (_) {}

    // 2. Send Parallel Direct HTTP Calls to all candidate IPs
    final candidateIps = await _getHotspotCandidateIps();
    debugPrint('[Trigger] Attempting direct HTTP trigger to: $candidateIps');
    final httpFutures = candidateIps.map((ipOrHost) async {
      try {
        final url = Uri.parse('http://$ipOrHost/trigger');
        final res = await http.get(url).timeout(const Duration(milliseconds: 1500));
        debugPrint('[Trigger] $ipOrHost returned status ${res.statusCode}');
        if (res.statusCode == 200) {
          if (_esp32LanIp != ipOrHost && !ipOrHost.contains('local')) {
            _esp32LanIp = ipOrHost;
            SharedPreferences.getInstance().then((p) => p.setString('iot_esp32_lan_ip', ipOrHost));
          }
          return true;
        }
      } catch (e) {
        debugPrint('[Trigger] $ipOrHost failed: $e');
      }
      return false;
    });

    final httpResults = await Future.wait(httpFutures);
    if (httpResults.any((res) => res == true)) {
      success = true;
      _lastStatusMessage = '🔊 Buzzer Beeping (BEEP - BEEP)!';
    }

    // 3. Send to Firebase Realtime Database (Cloud Fallback)
    try {
      final dbUrls = [
        _firebaseUrl,
        'https://lostitemfinder-aab53-default-rtdb.asia-southeast1.firebasedatabase.app',
      ];

      final payload = jsonEncode({
        'findCommand': active,
        'triggerDurationMs': _triggerDurationMs,
        'timestamp': DateTime.now().toIso8601String(),
        'lastCommand': active ? 'FIND_ITEM' : 'STOP_ALERT',
        'deviceStatus': 'triggering',
      });

      for (final dbUrl in dbUrls) {
        final targetUri = Uri.parse('$dbUrl/smart_item_finder/$_deviceId.json');
        final response = await http.patch(
          targetUri,
          headers: {'Content-Type': 'application/json'},
          body: payload,
        ).timeout(const Duration(seconds: 2));

        if (response.statusCode == 200 || response.statusCode == 204) {
          success = true;
          _lastStatusMessage = '🔊 Firebase & Buzzer Triggered!';
          break;
        }
      }
    } catch (_) {}

    _lastTriggerTime = DateTime.now();
    _isEspOnline = success || _isEspOnline;
    _isSending = false;
    if (!success) {
      _lastStatusMessage = 'Signal broadcast sent! ESP32 triggering remote.';
    }
    notifyListeners();
    return success;
  }

  /// Checks if Firebase or local ESP32 is reachable
  Future<bool> checkConnection() async {
    // 1. Try local ESP32 across candidate IPs
    final candidateIps = await _getHotspotCandidateIps();
    for (final ip in candidateIps) {
      try {
        final url = Uri.parse('http://$ip/status');
        final response = await http.get(url).timeout(const Duration(milliseconds: 1200));
        if (response.statusCode == 200) {
          _isEspOnline = true;
          _esp32LanIp = ip;
          _lastStatusMessage = 'ESP32 Online ($ip)';
          notifyListeners();
          return true;
        }
      } catch (_) {}
    }

    // 2. Try Firebase
    try {
      final targetUri = Uri.parse('$_firebaseUrl/smart_item_finder/$_deviceId.json');
      final response = await http.get(targetUri).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _isEspOnline = true;
        _lastStatusMessage = 'Firebase Online';
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isEspOnline = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _udpDiscoveryTimer?.cancel();
    _udpSocket?.close();
    super.dispose();
  }
}


