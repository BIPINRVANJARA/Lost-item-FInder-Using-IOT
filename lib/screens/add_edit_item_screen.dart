import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tracked_item.dart';
import '../models/item_category.dart';
import '../models/item_status.dart';
import '../providers/item_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_container.dart';
import '../widgets/ble_beacon_scanner_sheet.dart';

class AddEditItemScreen extends StatefulWidget {
  final TrackedItem? itemToEdit;

  const AddEditItemScreen({
    super.key,
    this.itemToEdit,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  late ItemCategory _selectedCategory;
  late String _macAddress;
  late String _ringtone;
  late int _batteryLevel;
  late bool _separationAlert;
  String _beaconName = 'No Beacon Paired';
  bool _isBeaconPaired = false;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _locationController = TextEditingController(text: item?.lastSeenLocation ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _selectedCategory = item?.category ?? ItemCategory.keys;
    _macAddress = item?.macAddress ?? 'F4:84:4C:99:A1:10';
    _ringtone = item?.ringtone ?? 'Sonar Pulse';
    _batteryLevel = item?.batteryLevel ?? 95;
    _separationAlert = item?.separationAlertEnabled ?? true;
    _isBeaconPaired = item != null;
    if (item != null) {
      _beaconName = 'Paired Beacon (${item.macAddress.substring(0, 8)}...)';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _openBeaconScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BleBeaconScannerSheet(
        onBeaconSelected: (beacon) {
          setState(() {
            _macAddress = beacon.macAddress;
            _beaconName = '${beacon.name} (${beacon.macAddress})';
            _isBeaconPaired = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Paired with ${beacon.name}!'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<ItemProvider>();
      final isEditing = widget.itemToEdit != null;

      final newItem = TrackedItem(
        id: isEditing ? widget.itemToEdit!.id : 'item-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        status: ItemStatus.connected,
        batteryLevel: _batteryLevel,
        lastSeenLocation: _locationController.text.trim().isEmpty
            ? 'Home Office'
            : _locationController.text.trim(),
        lastSeenTime: DateTime.now(),
        rssi: -48,
        distanceMeters: 1.5,
        isFavorite: isEditing ? widget.itemToEdit!.isFavorite : false,
        separationAlertEnabled: _separationAlert,
        ringtone: _ringtone,
        notes: _notesController.text.trim(),
        macAddress: _macAddress,
      );

      if (isEditing) {
        provider.updateItem(newItem);
      } else {
        provider.addItem(newItem);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.itemToEdit != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tracked Item' : 'Add New Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Item Name Input
            Text(
              'ITEM NAME',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. House Keys, Leather Wallet, Work Bag',
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Category Selector
            Text(
              'SELECT CATEGORY',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ItemCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  avatar: Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : cat.color,
                  ),
                  label: Text(cat.displayName),
                  selected: isSelected,
                  selectedColor: cat.color,
                  backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Bluetooth Beacon Pairing Card
            Text(
              'HARDWARE BEACON PAIRING',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 8),

            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isBeaconPaired
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isBeaconPaired ? Icons.bluetooth_connected_rounded : Icons.bluetooth_searching_rounded,
                      color: _isBeaconPaired ? AppColors.primary : AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isBeaconPaired ? 'Paired Tracker' : 'Scan for Beacon Tag',
                          style: AppTypography.title(context, isDark: isDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isBeaconPaired ? _beaconName : 'Pair a BLE 5.0 / UWB tracker card',
                          style: AppTypography.bodySmall(context, isDark: isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _openBeaconScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBeaconPaired ? AppColors.surfaceDarkElevated : AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      _isBeaconPaired ? 'Change' : 'Scan',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Location Hint
            Text(
              'DEFAULT LOCATION HINT',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Living Room Key Rack, Study Table, Backpack Pocket',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),

            const SizedBox(height: 24),

            // Optional Notes
            Text(
              'NOTES & DETAILS (OPTIONAL)',
              style: AppTypography.monoLabel(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add description, keychain color, or serial notes...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveItem,
                icon: const Icon(Icons.check_rounded),
                label: Text(isEditing ? 'Save Changes' : 'Register Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
