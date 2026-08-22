import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../data/coin_repository.dart';
import '../../settings/controllers/settings_controller.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late final AnimationController _playBtnCtrl;
  final SettingsController _settings = SettingsController.to;

  @override
  void initState() {
    super.initState();
    _playBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _playBtnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coins = CoinRepository.to;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar (Settings, Coins)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  unawaited(_settings.selectionClick());
                  Get.toNamed(AppRoutes.settings);
                },
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.yellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${coins.balance.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.add, color: AppTheme.success, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Logo Area
          AnimatedBuilder(
            animation: _playBtnCtrl,
            builder: (context, _) {
              final glow = 15 + _playBtnCtrl.value * 15;
              return Text(
                'GRID\nRUSH',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  shadows: [
                    Shadow(color: AppTheme.primary, blurRadius: glow),
                    Shadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: glow * 2,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'CHAPTER 5',
                    style: TextStyle(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('YOUR PROGRESS'),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _playBtnCtrl,
                    builder: (_, __) {
                      return LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: Colors.white24,
                        color: Color.lerp(
                          AppTheme.warning,
                          Colors.amberAccent,
                          _playBtnCtrl.value * 0.4,
                        ),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('5 / 10'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Main Buttons
          AnimatedBuilder(
            animation: _playBtnCtrl,
            builder: (context, _) {
              final btnPulse =
                  1.0 + 0.035 * (1.0 - (_playBtnCtrl.value - 0.5).abs() * 2);
              final glowIntensity = 8 + _playBtnCtrl.value * 14;
              return Transform.scale(
                scale: btnPulse,
                child: ElevatedButton(
                  onPressed: () {
                    unawaited(_settings.feedbackStartAction());
                    Get.toNamed(AppRoutes.gameplay);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shadowColor: AppTheme.success.withOpacity(0.7),
                    elevation: glowIntensity,
                  ),
                  child: const Text('PLAY', style: TextStyle(fontSize: 20)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              unawaited(_settings.selectionClick());
              Get.toNamed(AppRoutes.chapters);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('LEVELS', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              unawaited(_settings.selectionClick());
            }, // Daily Reward
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('DAILY REWARD', style: TextStyle(fontSize: 20)),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
