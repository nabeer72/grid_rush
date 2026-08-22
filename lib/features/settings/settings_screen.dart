import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme.dart';
import '../../../data/coin_repository.dart';
import '../../../data/progress_repository.dart';
import 'controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'AUDIO & HAPTICS',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Sound Effects',
              Icons.volume_up,
              controller.soundEnabled.value,
              controller.toggleSound,
              controller.sfxVolume.value,
              controller.setSfxVolume,
              enabled: controller.soundEnabled.value,
            ),
            _buildSwitchTile(
              'Background Music',
              Icons.music_note,
              controller.musicEnabled.value,
              controller.toggleMusic,
              controller.musicVolume.value,
              controller.setMusicVolume,
              enabled: controller.musicEnabled.value,
            ),
            _buildSwitchTile(
              'Vibration / Haptic Feedback',
              Icons.vibration,
              controller.hapticsEnabled.value,
              controller.toggleHaptics,
              null,
              null,
              enabled: controller.hapticsEnabled.value,
            ),

            const SizedBox(height: 32),
            const Text(
              'PREFERENCES',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Dark Theme',
              Icons.dark_mode,
              controller.darkTheme.value,
              controller.toggleTheme,
              null,
              null,
              enabled: true,
            ),

            Card(
              color: AppTheme.cardBackground,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.language, color: AppTheme.accent),
                title: const Text(
                  'Language',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Text(
                  'English',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'SUPPORTED ON',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppTheme.cardBackground,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up,
                            color: AppTheme.success, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Sound Effects',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          controller.soundEnabled.value ? 'ACTIVE' : 'OFF',
                          style: TextStyle(
                            color: controller.soundEnabled.value
                                ? AppTheme.success
                                : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'System click/alert sounds play on line complete, game over, and win. Toggle via the switch above.',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.music_note,
                            color: AppTheme.accent, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Background Music',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          controller.musicEnabled.value ? 'LOOPING' : 'OFF',
                          style: TextStyle(
                            color: controller.musicEnabled.value
                                ? AppTheme.accent
                                : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Each chapter plays its own looping ambient track via audioplayers. Tracks expected at assets/audio/trackXX.mp3 (per ChapterTheme.trackAsset).',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.vibration,
                            color: AppTheme.warning, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Vibration (Haptics)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          controller.hapticsEnabled.value
                              ? 'ACTIVE'
                              : 'OFF',
                          style: TextStyle(
                            color: controller.hapticsEnabled.value
                                ? AppTheme.warning
                                : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uses Flutter HapticFeedback: light/medium/heavy impacts plus selectionClick. Works on all modern iOS/Android devices that support haptics.',
                      style: TextStyle(
                          color: Colors.white54, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'OTHER',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              color: AppTheme.cardBackground,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading:
                    const Icon(Icons.privacy_tip, color: AppTheme.primary),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),

            Card(
              color: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: AppTheme.error,
                ),
                title: const Text(
                  'Reset Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.error,
                  ),
                ),
                subtitle: Text(
                  'Stars, unlocked levels and coins will be lost',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onTap: () => _showResetDialog(context),
              ),
            ),

            const SizedBox(height: 32),
            const Center(
              child: Text(
                'GRID RUSH · v1.0.0',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    double? volume,
    Function(double)? onVolumeChanged, {
    required bool enabled,
  }) {
    final showVolume = volume != null && onVolumeChanged != null;
    return Card(
      color: AppTheme.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(6, 4, 12, showVolume ? 4 : 0),
        child: Column(
          children: [
            SwitchListTile(
              activeColor: AppTheme.success,
              secondary: Icon(
                icon,
                color: enabled ? AppTheme.accent : Colors.white30,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.white38,
                ),
              ),
              value: value,
              onChanged: onChanged,
            ),
            if (showVolume)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Opacity(
                  opacity: enabled ? 1 : 0.25,
                  child: Row(
                    children: [
                      Icon(Icons.volume_mute,
                          color: AppTheme.accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Slider(
                          value: volume,
                          onChanged: enabled ? onVolumeChanged : null,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          activeColor: AppTheme.accent,
                          label: '${(volume * 100).round()}%',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(volume * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will delete all unlocked levels, stars, and coins. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Get.back();
              await ProgressRepository.resetAll();
              await CoinRepository.to.resetAll();
              Get.snackbar(
                'Progress Reset',
                'Your progress has been cleared.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
