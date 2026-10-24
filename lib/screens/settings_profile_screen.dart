import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/item_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_container.dart';
import 'onboarding_screen.dart';
import 'iot_hardware_hub_screen.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  bool _audioFeedbackEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _separationAlertsGlobal = true;
  String _userName = 'My Profile';
  String _userEmail = 'user@finder.app';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_profile_name') ?? 'My Device';
      _userEmail = prefs.getString('user_profile_email') ?? 'active@trackr.app';
      _audioFeedbackEnabled = prefs.getBool('pref_audio') ?? true;
      _hapticFeedbackEnabled = prefs.getBool('pref_haptic') ?? true;
      _separationAlertsGlobal = prefs.getBool('pref_separation') ?? true;
    });
  }

  Future<void> _saveUserProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_name', name);
    await prefs.setString('user_profile_email', email);
    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'Enter your name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', hintText: 'Enter your email'),
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
              _saveUserProfile(nameCtrl.text.trim(), emailCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All App Data?'),
        content: const Text('This will remove all registered tracked items and notifications from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ItemProvider>().clearAllItems();
              context.read<NotificationProvider>().clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDisconnected),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // User Profile Header Card
          GlassContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _userName.isNotEmpty ? _userName.substring(0, 1).toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: AppTypography.title(context, isDark: isDark).copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userEmail,
                        style: AppTypography.bodySmall(context, isDark: isDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ESP32 + 433 MHz RF SYNCED',
                          style: AppTypography.monoLabel(
                            fontSize: 8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: _showEditProfileDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // IOT HARDWARE HUB
          Text(
            'HARDWARE & IOT SYSTEM',
            style: AppTypography.monoLabel(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: 20,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_input_antenna_rounded, color: AppColors.primary, size: 22),
              ),
              title: Text('ESP32 & RF Remote Hub', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15)),
              subtitle: Text('Configure Firebase DB, test buzzer & view circuit diagram', style: AppTypography.bodySmall(context, isDark: isDark)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IotHardwareHubScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // APPEARANCE & DISPLAY
          Text(
            'APPEARANCE & THEME',
            style: AppTypography.monoLabel(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: 20,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.secondary,
                  ),
                  title: Text('Dark Mode', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15)),
                  subtitle: Text('High contrast dark radar interface', style: AppTypography.bodySmall(context, isDark: isDark)),
                  value: themeProvider.isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SENSORS & ALERTS
          Text(
            'RADAR & TRACKING PREFERENCES',
            style: AppTypography.monoLabel(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: 20,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                  title: Text('Acoustic Beepers', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15)),
                  subtitle: Text('Play cadence tone on proximity approach', style: AppTypography.bodySmall(context, isDark: isDark)),
                  value: _audioFeedbackEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('pref_audio', val);
                    setState(() => _audioFeedbackEnabled = val);
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.vibration_rounded, color: AppColors.secondary),
                  title: Text('Haptic Pulses', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15)),
                  subtitle: Text('Vibrate phone as you approach target', style: AppTypography.bodySmall(context, isDark: isDark)),
                  value: _hapticFeedbackEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('pref_haptic', val);
                    setState(() => _hapticFeedbackEnabled = val);
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.warning_amber_rounded, color: AppColors.statusWarning),
                  title: Text('Separation Alerts', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15)),
                  subtitle: Text('Warn when leaving tracked belongings behind', style: AppTypography.bodySmall(context, isDark: isDark)),
                  value: _separationAlertsGlobal,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('pref_separation', val);
                    setState(() => _separationAlertsGlobal = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SYSTEM & DATA MANAGEMENT
          Text(
            'DATA MANAGEMENT & SUPPORT',
            style: AppTypography.monoLabel(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),

          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: 20,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                  title: Text('Replay Onboarding Guide', style: AppTypography.title(context, isDark: isDark).copyWith(fontSize: 15)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.statusDisconnected),
                  title: const Text('Clear All App Data', style: TextStyle(color: AppColors.statusDisconnected, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.statusDisconnected),
                  onTap: _confirmClearData,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
