import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/chapter_themes.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/level_repository.dart';
import '../../data/progress_repository.dart';
import '../settings/controllers/settings_controller.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  final SettingsController _settings = SettingsController.to;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHAPTERS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: LevelRepository.totalChapters,
          itemBuilder: (context, index) {
            final chapterNum = index + 1;
            final theme = ChapterThemes.forChapter(chapterNum);
            final isUnlocked =
                chapterNum <= 3 ||
                ProgressRepository.isChapterUnlocked(chapterNum);
            final levelIds = List.generate(
              LevelRepository.levelsPerChapter,
              (i) =>
                  (chapterNum - 1) * LevelRepository.levelsPerChapter + (i + 1),
            );
            final totalStars = ProgressRepository.totalStarsForChapter(
              chapterNum,
              levelIds,
            );
            final maxStars = LevelRepository.levelsPerChapter * 3;
            final firstLevel = LevelRepository.getLevelForChapter(
              chapterNum,
              1,
            );
            final lastLevel = LevelRepository.getLevelForChapter(
              chapterNum,
              LevelRepository.levelsPerChapter,
            );
            final borderRadius = BorderRadius.circular(theme.borderRadius);

            final gradientColors = isUnlocked
                ? theme.backgroundGradient
                : [
                    theme.background.withOpacity(0.5),
                    theme.backgroundAccent.withOpacity(0.3),
                  ];

            final cardBorderColor = isUnlocked
                ? theme.cardBorder
                : Colors.white10;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  final pulse = isUnlocked
                      ? 1.0 + 0.08 * (1.0 - (_pulseCtrl.value - 0.5).abs() * 2)
                      : 1.0;
                  return InkWell(
                    onTap: isUnlocked
                        ? () {
                            unawaited(_settings.feedbackStartAction());
                            Get.toNamed(
                              AppRoutes.levelSelect,
                              arguments: {'chapter': chapterNum},
                            );
                          }
                        : null,
                    borderRadius: borderRadius,
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isUnlocked
                              ? Color.lerp(
                                      cardBorderColor,
                                      theme.success,
                                      _pulseCtrl.value * 0.35,
                                    ) ??
                                    cardBorderColor
                              : Colors.white10,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isUnlocked
                                ? theme.success.withOpacity(
                                    0.08 + _pulseCtrl.value * 0.10,
                                  )
                                : Colors.transparent,
                            blurRadius: theme.cardElevation,
                            spreadRadius: 0.5,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: theme.cardBackground.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(
                                  (theme.borderRadius - 4).toDouble(),
                                ),
                                border: Border.all(color: theme.cardBorder),
                              ),
                              child: Center(
                                child: Text(
                                  '$chapterNum',
                                  style: ChapterThemes.resolveFont(
                                    theme.fontFamily,
                                    TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: isUnlocked
                                          ? theme.primary
                                          : Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    theme.name,
                                    style: ChapterThemes.resolveFont(
                                      theme.fontFamily,
                                      TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isUnlocked
                                            ? theme.textPrimary
                                            : Colors.white54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    theme.description,
                                    style: TextStyle(
                                      color: isUnlocked
                                          ? theme.textMuted
                                          : Colors.white30,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (firstLevel != null && lastLevel != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${firstLevel.pairs}-${lastLevel.pairs} pairs · Difficulty ${firstLevel.difficulty}-${lastLevel.difficulty}',
                                        style: TextStyle(
                                          color: isUnlocked
                                              ? theme.textMuted
                                              : Colors.white30,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(3, (starIndex) {
                                          final threshold = [
                                            30,
                                            100,
                                            120,
                                          ][starIndex];
                                          return Icon(
                                            Icons.star,
                                            color: isUnlocked
                                                ? (totalStars >= threshold
                                                      ? Colors.yellow
                                                      : Colors.grey.shade600)
                                                : Colors.grey.withOpacity(0.3),
                                            size: 18,
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '$totalStars / $maxStars ⭐',
                                        style: TextStyle(
                                          color: isUnlocked
                                              ? theme.textPrimary
                                              : Colors.white38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            isUnlocked
                                ? Transform.scale(
                                    scale: pulse,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.success.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.success.withOpacity(
                                              0.15 + _pulseCtrl.value * 0.25,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: theme.success,
                                        size: 36,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.lock,
                                    color: theme.textMuted,
                                    size: 26,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
