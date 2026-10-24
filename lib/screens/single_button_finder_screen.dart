import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_iot_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_container.dart';
import 'iot_hardware_hub_screen.dart';

class SingleButtonFinderScreen extends StatefulWidget {
  const SingleButtonFinderScreen({super.key});

  @override
  State<SingleButtonFinderScreen> createState() => _SingleButtonFinderScreenState();
}

class _SingleButtonFinderScreenState extends State<SingleButtonFinderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iotService = context.watch<FirebaseIotService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Lost Finder',
                        style: AppTypography.displayMedium(context, isDark: isDark).copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () => _showEditIpDialog(context, iotService),
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: iotService.isEspOnline ? AppColors.primary : Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ESP32: ${iotService.esp32LanIp}',
                              style: AppTypography.monoLabel(
                                fontSize: 11,
                                color: iotService.isEspOnline ? AppColors.primary : Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit_outlined,
                              size: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IotHardwareHubScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 🎯 HUGE CENTRAL 1-TAP FIND BUTTON
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: iotService.isSending
                        ? null
                        : () {
                            iotService.sendFindCommand(active: true);
                          },
                    child: AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Pulsating Sonar Ring 1
                            Container(
                              width: 280 + (_rippleController.value * 50),
                              height: 280 + (_rippleController.value * 50),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withValues(
                                  alpha: (1.0 - _rippleController.value) * 0.25,
                                ),
                              ),
                            ),
                            // Outer Pulsating Sonar Ring 2
                            Container(
                              width: 250 + (_rippleController.value * 30),
                              height: 250 + (_rippleController.value * 30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF10B981).withValues(
                                    alpha: (1.0 - _rippleController.value) * 0.6,
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),

                            // Main Big Glowing Button
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (iotService.isSending) ...[
                                      const SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'BEEPING...',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ] else ...[
                                      const Icon(
                                        Icons.campaign_rounded,
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'FIND ITEM',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'BEEP BUZZER',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Status Card Below Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      borderRadius: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iotService.isSending
                                ? Icons.volume_up_rounded
                                : Icons.sensors_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              iotService.lastStatusMessage,
                              style: AppTypography.monoLabel(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom Info Banner
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Tap the button to send 433 MHz RF signal to your buzzer',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(context, isDark: isDark).copyWith(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditIpDialog(BuildContext context, FirebaseIotService iotService) {
    final controller = TextEditingController(text: iotService.esp32LanIp);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ESP32 Hotspot IP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the IP address of your ESP32 on your hotspot (e.g. 10.60.64.113):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'ESP32 IP',
                hintText: '10.60.64.113',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                iotService.updateConfig(esp32LanIp: controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save IP'),
          ),
        ],
      ),
    );
  }
}

