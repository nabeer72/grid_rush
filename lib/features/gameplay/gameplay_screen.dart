import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/chapter_themes.dart';
import '../../../app/theme.dart';
import '../../../data/coin_repository.dart';
import '../../../data/level_repository.dart';
import '../settings/controllers/settings_controller.dart';
import 'controllers/gameplay_controller.dart';
import 'widgets/grid_board.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  @override
  Widget build(BuildContext context) {
    final GameplayController controller = Get.put(GameplayController());
    final CoinRepository coins = CoinRepository.to;
    final SettingsController settings = SettingsController.to;

    final args = Get.arguments as Map<String, dynamic>?;
    final chapter = args?['chapter'] ?? 1;
    final levelInChapter = args?['level'] ?? 1;

    final theme = ChapterThemes.forChapter(chapter);
    unawaited(settings.playChapterMusic(chapter));

    final level = LevelRepository.getLevelForChapter(chapter, levelInChapter);
    if (level == null) {
      return const Scaffold(body: Center(child: Text('Level not found')));
    }

    if (!controller.isInitialized ||
        controller.gameState?.currentLevel.id != level.id) {
      controller.initLevel(level);
    }

    final borderRadius = BorderRadius.circular(theme.borderRadius);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${theme.name}',
          style: ChapterThemes.resolveFont(
            theme.fontFamily,
            TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: theme.textPrimary,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardBackground.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.yellow,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${coins.balance.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.freeRearrangesLeft.value > 0
                      ? '${controller.freeRearrangesLeft.value} Free'
                      : '30 Coins',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: controller.freeRearrangesLeft.value > 0
                        ? theme.success
                        : Colors.yellowAccent,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: theme.textPrimary),
                  onPressed: () => controller.manualRearrange(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'CH $chapter · LV $levelInChapter  ·  ${theme.description}',
                    style: ChapterThemes.resolveFont(
                      theme.fontFamily,
                      TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: theme.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Header Stats
                Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.cardBorder.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final limit = level.moveLimit > 0
                            ? '/${level.moveLimit}'
                            : '';
                        final over =
                            level.moveLimit > 0 &&
                            controller.moves.value >= level.moveLimit;
                        return _buildStatBox(
                          'MOVES',
                          '${controller.moves.value}$limit',
                          theme,
                          valueColor: over ? theme.error : theme.textPrimary,
                        );
                      }),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (level.timeLimit > 0) {
                          final t = controller.timeRemaining.value;
                          final mins = (t ~/ 60).toString().padLeft(2, '0');
                          final secs = (t % 60).toString().padLeft(2, '0');
                          final low = t <= 10;
                          return _buildStatBox(
                            'TIME',
                            '$mins:$secs',
                            theme,
                            valueColor: low ? theme.error : theme.textPrimary,
                          );
                        } else {
                          return _buildStatBox(
                            'PAIRS',
                            '${level.pairs}',
                            theme,
                          );
                        }
                      }),
                    ),
                    Expanded(
                      child: _buildStatBox(
                        level.timeLimit > 0 ? 'PAIRS' : 'TARGET',
                        '${level.pairs}',
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildStatBox(
                        'DIFF',
                        '${level.difficulty}',
                        theme,
                      ),
                    ),
                  ],
                ),
                ),
                // The Grid
                Expanded(
                  child: GridBoardWidget(controller: controller, theme: theme),
                ),

                // Bottom tools
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.cardBorder.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolButton(
                      Icons.lightbulb,
                      theme.warning,
                      theme,
                      () {},
                    ),
                    if (level.timeLimit > 0)
                      Obx(() {
                        final affordable = controller.canBuyExtraTime;
                        return _buildToolButton(
                          Icons.timer_outlined,
                          affordable ? theme.success : theme.textMuted,
                          theme,
                          affordable
                              ? () async {
                                  final ok = await controller.buyExtraTime();
                                  if (ok) {
                                    Get.snackbar(
                                      '+30s Added!',
                                      '+${CoinRepository.extraTimeSeconds} seconds for ${CoinRepository.extraTimeCost} coins',
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: theme.success,
                                      colorText: theme.textPrimary,
                                      duration: const Duration(seconds: 1),
                                    );
                                  }
                                }
                              : null,
                          priceLabel:
                              '${CoinRepository.extraTimeCost} +${CoinRepository.extraTimeSeconds}s',
                        );
                      }),
                    _buildToolButton(
                      Icons.undo,
                      theme.textPrimary,
                      theme,
                      () => controller.undo(),
                    ),
                  ],
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    ChapterTheme theme, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: ChapterThemes.resolveFont(
            theme.fontFamily,
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: valueColor ?? theme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(
    IconData icon,
    Color color,
    ChapterTheme theme,
    VoidCallback? onTap, {
    String? priceLabel,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.borderRadius - 6),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(theme.borderRadius - 6),
            border: Border.all(color: theme.cardBorder.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: theme.cardBorder.withOpacity(0.15),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              if (priceLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: enabled ? Colors.yellowAccent : theme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
