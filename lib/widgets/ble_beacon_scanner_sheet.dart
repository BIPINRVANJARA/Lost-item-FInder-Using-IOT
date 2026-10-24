import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'glass_container.dart';

class DiscoveredBeacon {
  final String name;
  final String macAddress;
  final int rssi;
  final String model;

  DiscoveredBeacon({
    required this.name,
    required this.macAddress,
    required this.rssi,
    required this.model,
  });
}

class BleBeaconScannerSheet extends StatefulWidget {
  final Function(DiscoveredBeacon) onBeaconSelected;

  const BleBeaconScannerSheet({
    super.key,
    required this.onBeaconSelected,
  });

  @override
  State<BleBeaconScannerSheet> createState() => _BleBeaconScannerSheetState();
}

class _BleBeaconScannerSheetState extends State<BleBeaconScannerSheet> {
  bool _isScanning = true;
  final List<DiscoveredBeacon> _discoveredBeacons = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _startSimulatedScan();
  }

  void _startSimulatedScan() {
    _discoveredBeacons.clear();
    _isScanning = true;

    // Simulate finding beacons incrementally
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _discoveredBeacons.add(
            DiscoveredBeacon(
              name: 'AirBeacon Pro Tag',
              macAddress: 'F4:84:4C:99:A1:10',
              rssi: -45,
              model: 'Ultra-Wideband BLE 5.3',
            ),
          );
        });
      }
    });

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _discoveredBeacons.add(
            DiscoveredBeacon(
              name: 'Smart Slim Card #028',
              macAddress: 'E2:15:7A:B2:44:88',
              rssi: -58,
              model: 'Rechargeable Wallet Tracker',
            ),
          );
        });
      }
    });

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _discoveredBeacons.add(
            DiscoveredBeacon(
              name: 'Pebble Mini Tag #901',
              macAddress: 'D8:3B:90:77:21:66',
              rssi: -72,
              model: 'Key Ring Audio Beacon',
            ),
          );
          _isScanning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nearby Beacons',
                    style: AppTypography.headline(context, isDark: isDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isScanning
                        ? 'Scanning for unclaimed Bluetooth tags...'
                        : 'Found ${_discoveredBeacons.length} available beacons',
                    style: AppTypography.bodySmall(context, isDark: isDark),
                  ),
                ],
              ),
              if (_isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _startSimulatedScan,
                  color: AppColors.primary,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Beacons List
          Expanded(
            child: _discoveredBeacons.isEmpty && _isScanning
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.radar_rounded,
                          size: 48,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hold your tracker near your device',
                          style: AppTypography.bodyMedium(context, isDark: isDark),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _discoveredBeacons.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final beacon = _discoveredBeacons[index];
                      return GlassContainer(
                        onTap: () {
                          widget.onBeaconSelected(beacon);
                          Navigator.pop(context);
                        },
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bluetooth_searching_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    beacon.name,
                                    style: AppTypography.title(context, isDark: isDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    beacon.model,
                                    style: AppTypography.bodySmall(context, isDark: isDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    beacon.macAddress,
                                    style: AppTypography.monoLabel(
                                      fontSize: 10,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${beacon.rssi} dBm',
                                  style: AppTypography.monoLabel(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap to Pair',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
