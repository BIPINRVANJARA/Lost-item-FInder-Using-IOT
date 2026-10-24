import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tracked_item.dart';
import '../models/item_category.dart';
import '../models/item_status.dart';
import 'audio_feedback_service.dart';

class ItemProvider extends ChangeNotifier {
  final List<TrackedItem> _items = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  ItemStatus? _selectedStatus;
  bool _onlyFavorites = false;

  // Active Finding session state
  TrackedItem? _activeFindItem;
  bool _isFindingActive = false;
  double _simulatedDistance = 4.2;
  int _simulatedRssi = -65;
  bool _isAlarmRinging = false;
  bool _isFlashlightOn = false;
  bool _isItemFound = false;
  double _radarBearingAngle = 45.0; // In degrees
  Timer? _telemetrySimulationTimer;

  static const String _storageKey = 'tracked_items_storage_v1';

  List<TrackedItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  ItemCategory? get selectedCategory => _selectedCategory;
  ItemStatus? get selectedStatus => _selectedStatus;
  bool get onlyFavorites => _onlyFavorites;

  TrackedItem? get activeFindItem => _activeFindItem;
  bool get isFindingActive => _isFindingActive;
  double get simulatedDistance => _simulatedDistance;
  int get simulatedRssi => _simulatedRssi;
  bool get isAlarmRinging => _isAlarmRinging;
  bool get isFlashlightOn => _isFlashlightOn;
  bool get isItemFound => _isItemFound;
  double get radarBearingAngle => _radarBearingAngle;

  ItemProvider() {
    _loadItemsFromStorage();
  }

  Future<void> _loadItemsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);
      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(savedData);
        _items.clear();
        for (final itemJson in jsonList) {
          _items.add(TrackedItem.fromJson(itemJson as Map<String, dynamic>));
        }
      }
    } catch (e) {
      debugPrint('Error loading items from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveItemsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _items.map((i) => i.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving items to storage: $e');
    }
  }

  // Telemetry Counts
  int get totalCount => _items.length;
  int get connectedCount => _items.where((i) => i.status == ItemStatus.connected).length;
  int get nearbyCount => _items.where((i) => i.status == ItemStatus.nearby).length;
  int get disconnectedCount => _items.where((i) => i.status == ItemStatus.disconnected).length;
  int get lowBatteryCount => _items.where((i) => i.batteryLevel <= 20).length;

  List<TrackedItem> get filteredItems {
    return _items.where((item) {
      // Search text filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchLocation = item.lastSeenLocation.toLowerCase().contains(query);
        final matchCategory = item.category.displayName.toLowerCase().contains(query);
        if (!matchName && !matchLocation && !matchCategory) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && item.status != _selectedStatus) {
        return false;
      }

      // Favorites filter
      if (_onlyFavorites && !item.isFavorite) {
        return false;
      }

      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(ItemCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedStatus(ItemStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setOnlyFavorites(bool only) {
    _onlyFavorites = only;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStatus = null;
    _onlyFavorites = false;
    notifyListeners();
  }

  // Item Management CRUD with Storage Persistence
  void addItem(TrackedItem item) {
    _items.insert(0, item);
    _saveItemsToStorage();
    notifyListeners();
  }

  void updateItem(TrackedItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      if (_activeFindItem?.id == item.id) {
        _activeFindItem = item;
      }
      _saveItemsToStorage();
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    if (_activeFindItem?.id == id) {
      stopFinding();
    }
    _saveItemsToStorage();
    notifyListeners();
  }

  void clearAllItems() {
    _items.clear();
    stopFinding();
    _saveItemsToStorage();
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isFavorite = !_items[index].isFavorite;
      _saveItemsToStorage();
      notifyListeners();
    }
  }

  void toggleSeparationAlert(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].separationAlertEnabled = !_items[index].separationAlertEnabled;
      _saveItemsToStorage();
      notifyListeners();
    }
  }

  void toggleLostMode(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isLostModeActive = !_items[index].isLostModeActive;
      _saveItemsToStorage();
      notifyListeners();
    }
  }

  // Active Find Item Radar Session
  void startFinding(TrackedItem item) {
    _activeFindItem = item;
    _isFindingActive = true;
    _simulatedDistance = item.distanceMeters.clamp(0.4, 25.0);
    _simulatedRssi = item.rssi;
    _isAlarmRinging = true;
    _isFlashlightOn = false;
    _isItemFound = false;
    _radarBearingAngle = (math.Random().nextDouble() * 360);

    // Start acoustic sound and haptic alert loop
    AudioFeedbackService.startFindingAlarm(
      distanceMeters: _simulatedDistance,
      onBeep: () {},
    );

    // Start dynamic subtle telemetry fluctuation
    _startTelemetryDrift();

    notifyListeners();
  }

  void _startTelemetryDrift() {
    _telemetrySimulationTimer?.cancel();
    _telemetrySimulationTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!_isFindingActive || _isItemFound) {
        timer.cancel();
        return;
      }

      // Small natural wander to simulate live BLE RSSI telemetry
      final randomDelta = (math.Random().nextDouble() - 0.5) * 0.2;
      _simulatedDistance = (_simulatedDistance + randomDelta).clamp(0.2, 30.0);
      _simulatedRssi = (-40 - (_simulatedDistance * 3.2)).round().clamp(-95, -30);
      
      // Update item distance
      if (_activeFindItem != null) {
        _activeFindItem!.distanceMeters = _simulatedDistance;
        _activeFindItem!.rssi = _simulatedRssi;
      }

      notifyListeners();
    });
  }

  void setSimulatedDistance(double newDistance) {
    _simulatedDistance = newDistance.clamp(0.1, 30.0);
    _simulatedRssi = (-40 - (_simulatedDistance * 3.2)).round().clamp(-95, -30);
    
    if (_activeFindItem != null) {
      _activeFindItem!.distanceMeters = _simulatedDistance;
      _activeFindItem!.rssi = _simulatedRssi;
      
      if (_simulatedDistance <= 1.0) {
        _activeFindItem!.status = ItemStatus.connected;
      } else if (_simulatedDistance <= 10.0) {
        _activeFindItem!.status = ItemStatus.nearby;
      }
    }

    if (_isAlarmRinging) {
      AudioFeedbackService.updateProximityInterval(_simulatedDistance, () {});
    }

    notifyListeners();
  }

  void toggleAlarmRinging() {
    _isAlarmRinging = !_isAlarmRinging;
    if (_isAlarmRinging) {
      AudioFeedbackService.startFindingAlarm(
        distanceMeters: _simulatedDistance,
        onBeep: () {},
      );
    } else {
      AudioFeedbackService.stopFindingAlarm();
    }
    notifyListeners();
  }

  void toggleFlashlight() {
    _isFlashlightOn = !_isFlashlightOn;
    AudioFeedbackService.triggerHapticClick();
    notifyListeners();
  }

  void markItemFound() {
    _isItemFound = true;
    _simulatedDistance = 0.2;
    _isAlarmRinging = false;
    AudioFeedbackService.stopFindingAlarm();
    AudioFeedbackService.triggerHapticSuccess();

    if (_activeFindItem != null) {
      _activeFindItem!.status = ItemStatus.connected;
      _activeFindItem!.lastSeenTime = DateTime.now();
      _activeFindItem!.distanceMeters = 0.2;
      _saveItemsToStorage();
    }

    notifyListeners();
  }

  void stopFinding() {
    _isFindingActive = false;
    _isAlarmRinging = false;
    _isFlashlightOn = false;
    _isItemFound = false;
    _activeFindItem = null;
    _telemetrySimulationTimer?.cancel();
    _telemetrySimulationTimer = null;
    AudioFeedbackService.stopFindingAlarm();
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetrySimulationTimer?.cancel();
    AudioFeedbackService.stopFindingAlarm();
    super.dispose();
  }
}
