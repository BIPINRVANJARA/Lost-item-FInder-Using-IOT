import 'item_category.dart';
import 'item_status.dart';

class TrackedItem {
  final String id;
  String name;
  ItemCategory category;
  ItemStatus status;
  int batteryLevel; // 0 - 100
  String lastSeenLocation;
  DateTime lastSeenTime;
  int rssi; // Signal strength in dBm (-30 to -95)
  double distanceMeters; // Estimated distance in meters
  bool isFavorite;
  bool separationAlertEnabled;
  String ringtone;
  String notes;
  bool isLostModeActive;
  double latitude;
  double longitude;
  String macAddress;
  int? customIconCode;

  TrackedItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    this.batteryLevel = 85,
    required this.lastSeenLocation,
    required this.lastSeenTime,
    this.rssi = -60,
    this.distanceMeters = 3.5,
    this.isFavorite = false,
    this.separationAlertEnabled = true,
    this.ringtone = 'Sonar Pulse',
    this.notes = '',
    this.isLostModeActive = false,
    this.latitude = 37.7749,
    this.longitude = -122.4194,
    this.macAddress = 'AA:BB:CC:DD:EE:01',
    this.customIconCode,
  });

  TrackedItem copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    ItemStatus? status,
    int? batteryLevel,
    String? lastSeenLocation,
    DateTime? lastSeenTime,
    int? rssi,
    double? distanceMeters,
    bool? isFavorite,
    bool? separationAlertEnabled,
    String? ringtone,
    String? notes,
    bool? isLostModeActive,
    double? latitude,
    double? longitude,
    String? macAddress,
    int? customIconCode,
  }) {
    return TrackedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSeenLocation: lastSeenLocation ?? this.lastSeenLocation,
      lastSeenTime: lastSeenTime ?? this.lastSeenTime,
      rssi: rssi ?? this.rssi,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isFavorite: isFavorite ?? this.isFavorite,
      separationAlertEnabled: separationAlertEnabled ?? this.separationAlertEnabled,
      ringtone: ringtone ?? this.ringtone,
      notes: notes ?? this.notes,
      isLostModeActive: isLostModeActive ?? this.isLostModeActive,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      macAddress: macAddress ?? this.macAddress,
      customIconCode: customIconCode ?? this.customIconCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'status': status.name,
      'batteryLevel': batteryLevel,
      'lastSeenLocation': lastSeenLocation,
      'lastSeenTime': lastSeenTime.toIso8601String(),
      'rssi': rssi,
      'distanceMeters': distanceMeters,
      'isFavorite': isFavorite,
      'separationAlertEnabled': separationAlertEnabled,
      'ringtone': ringtone,
      'notes': notes,
      'isLostModeActive': isLostModeActive,
      'latitude': latitude,
      'longitude': longitude,
      'macAddress': macAddress,
      'customIconCode': customIconCode,
    };
  }

  factory TrackedItem.fromJson(Map<String, dynamic> json) {
    return TrackedItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ItemCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ItemCategory.other,
      ),
      status: ItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ItemStatus.unknown,
      ),
      batteryLevel: json['batteryLevel'] as int? ?? 80,
      lastSeenLocation: json['lastSeenLocation'] as String? ?? 'Nearby',
      lastSeenTime: DateTime.tryParse(json['lastSeenTime'] as String? ?? '') ?? DateTime.now(),
      rssi: json['rssi'] as int? ?? -65,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 2.5,
      isFavorite: json['isFavorite'] as bool? ?? false,
      separationAlertEnabled: json['separationAlertEnabled'] as bool? ?? true,
      ringtone: json['ringtone'] as String? ?? 'Sonar Pulse',
      notes: json['notes'] as String? ?? '',
      isLostModeActive: json['isLostModeActive'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 37.7749,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -122.4194,
      macAddress: json['macAddress'] as String? ?? '00:00:00:00:00:00',
      customIconCode: json['customIconCode'] as int?,
    );
  }
}
