import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_iot_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_container.dart';

class IotHardwareHubScreen extends StatefulWidget {
  const IotHardwareHubScreen({super.key});

  @override
  State<IotHardwareHubScreen> createState() => _IotHardwareHubScreenState();
}

class _IotHardwareHubScreenState extends State<IotHardwareHubScreen> {
  late TextEditingController _firebaseUrlController;
  late TextEditingController _deviceIdController;
  late TextEditingController _lanIpController;

  @override
  void initState() {
    super.initState();
    final iotService = context.read<FirebaseIotService>();
    _firebaseUrlController = TextEditingController(text: iotService.firebaseUrl);
    _deviceIdController = TextEditingController(text: iotService.deviceId);
    _lanIpController = TextEditingController(text: iotService.esp32LanIp);
  }

  @override
  void dispose() {
    _firebaseUrlController.dispose();
    _deviceIdController.dispose();
    _lanIpController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    context.read<FirebaseIotService>().updateConfig(
      firebaseUrl: _firebaseUrlController.text.trim(),
      deviceId: _deviceIdController.text.trim(),
      esp32LanIp: _lanIpController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hardware & Firebase settings updated!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iotService = context.watch<FirebaseIotService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('ESP32 & RF Hardware Hub'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Architecture Hero Card
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '433 MHz RF Trigger Link',
                            style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 16),
                          ),
                          Text(
                            'App → Firebase → ESP32 → RF Remote → Buzzer',
                            style: AppTypography.monoLabel(fontSize: 10, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildFlowStep('1. Mobile App', 'Sends Find Command', Icons.phone_android_rounded, AppColors.primary),
                      _buildFlowDivider(),
                      _buildFlowStep('2. Firebase / ESP32', 'Receives cloud signal via Wi-Fi', Icons.cloud_done_rounded, AppColors.secondary),
                      _buildFlowDivider(),
                      _buildFlowStep('3. MOSFET Switch', 'Shorts RF remote forward button terminals', Icons.toggle_on_rounded, const Color(0xFFF59E0B)),
                      _buildFlowDivider(),
                      _buildFlowStep('4. RF Receiver & Buzzer', 'Outputs voltage to buzzer on lost item', Icons.volume_up_rounded, const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LIVE TEST TRIGGER PANEL
          Text(
            'HARDWARE TEST CONTROLS',
            style: AppTypography.monoLabel(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status: ${iotService.lastStatusMessage}', style: AppTypography.bodySmall(context, isDark: isDark)),
                    if (iotService.isSending)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Primary Trigger Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: iotService.isSending
                        ? null
                        : () {
                            iotService.sendFindCommand(active: true);
                          },
                    icon: const Icon(Icons.campaign_rounded, size: 22),
                    label: const Text('TEST TRIGGER (BEEP BUZZER)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Ping Check Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await iotService.checkConnection();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'ESP32 / Firebase is ONLINE!' : 'Could not reach ESP32 / Firebase.'),
                            backgroundColor: ok ? AppColors.primary : AppColors.statusDisconnected,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.wifi_find_rounded, size: 18),
                    label: const Text('Test Connection Ping'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // CONFIGURATION
          Text(
            'COMMUNICATION CONFIGURATION',
            style: AppTypography.monoLabel(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Direct LAN Mode Switch
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Direct LAN IP Mode', style: AppTypography.title(context, isDark: isDark)),
                  subtitle: Text('Direct HTTP to ESP32 without Internet', style: AppTypography.bodySmall(context, isDark: isDark)),
                  value: iotService.isDirectLanMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    iotService.updateConfig(isDirectLanMode: val);
                  },
                ),
                const Divider(),

                if (!iotService.isDirectLanMode) ...[
                  // Firebase Database URL
                  Text('Firebase Database URL', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _firebaseUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://your-project-default-rtdb.firebaseio.com',
                      prefixIcon: Icon(Icons.cloud_queue_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Device Node ID
                  Text('Target Device ID Node', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. device_01',
                      prefixIcon: Icon(Icons.developer_board_rounded),
                    ),
                  ),
                ] else ...[
                  // ESP32 LAN IP
                  Text('ESP32 Wi-Fi IP Address', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _lanIpController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 192.168.1.100',
                      prefixIcon: Icon(Icons.router_rounded),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Trigger Duration Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RF Pulse Duration', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 14)),
                    Text('${(iotService.triggerDurationMs / 1000).toStringAsFixed(1)} seconds', style: AppTypography.monoLabel(fontSize: 12)),
                  ],
                ),
                Slider(
                  value: iotService.triggerDurationMs.toDouble(),
                  min: 500,
                  max: 5000,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    iotService.updateConfig(triggerDurationMs: val.round());
                  },
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDarkElevated,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Configuration'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // WIRING & HARDWARE PINOUT GUIDE
          Text(
            'CIRCUIT CONNECTIONS GUIDE',
            style: AppTypography.monoLabel(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPinRow('ESP32 GPIO 25', 'MOSFET Gate (via 1k Resistor)'),
                _buildPinRow('MOSFET Drain', 'RF Remote Forward Button (Terminal 1)'),
                _buildPinRow('MOSFET Source', 'RF Remote Forward Button (Terminal 2)'),
                _buildPinRow('ESP32 GND', 'RF Remote Ground (Common Ground)'),
                _buildPinRow('Receiver Motor (+)', 'Buzzer Positive (+) Red Wire'),
                _buildPinRow('Receiver Motor (-)', 'Buzzer Negative (-) Black Wire'),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFlowStep(String title, String desc, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlowDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 2,
          height: 12,
          color: Colors.grey.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildPinRow(String pin, String target) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(pin, style: AppTypography.monoLabel(fontSize: 10, color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(target, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
