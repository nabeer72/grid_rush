import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/chapter_themes.dart';
import '../../app/routes.dart';
import '../../data/level_repository.dart';
import '../../data/progress_repository.dart';
import '../settings/controllers/settings_controller.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _idleCtrl;
  final SettingsController _settings = SettingsController.to;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final chapter = args?['chapter'] ?? 1;
    final levels = LevelRepository.getLevelsForChapter(chapter);
    final theme = ChapterThemes.forChapter(chapter);
    final borderRadius = BorderRadius.circular(theme.borderRadius - 4);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          theme.name,
          style: ChapterThemes.resolveFont(
            theme.fontFamily,
            TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: theme.textPrimary,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.textPrimary),
          onPressed: () => Get.back(),
        ),
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
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    theme.description.toUpperCase(),
                    style: ChapterThemes.resolveFont(
                      theme.fontFamily,
                      TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: theme.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final levelNum = index + 1;
                      final isUnlocked =
                          ProgressRepository.isLevelUnlocked(chapter, levelNum);
                      final completed = ProgressRepository.isCompleted(level.id);
                      final bestStars =
                          ProgressRepository.bestStarsFor(level.id);
                      final attempts =
                          ProgressRepository.attemptsFor(level.id);
                      final attemptsColor = !isUnlocked
                          ? Colors.white38
                          : attempts == 0
                              ? theme.textMuted
                              : attempts == 1
                                  ? theme.success
                                  : (attempts <= 3
                                      ? Colors.yellow
                                      : (attempts <= 5
                                          ? Colors.orangeAccent
                                          : theme.error));

                      return AnimatedBuilder(
                        animation: _idleCtrl,
                        builder: (context, _) {
                          final wave =
                              (1.0 - ((_idleCtrl.value - 0.5).abs() * 2));
                          final stagger = ((index % 6) / 6) * 0.4;
                          final effective =
                              (wave + stagger).clamp(0.0, 1.0).toDouble();
                          final lift = 1.0 + effective * 0.025;
                          final borderGlow = isUnlocked && !completed
                              ? Color.lerp(
                                    theme.cardBorder,
                                    theme.success,
                                    effective * 0.45,
                                  ) ??
                                  theme.cardBorder
                              : null;

                          return GestureDetector(
                            onTap: isUnlocked
                                ? () {
                                    unawaited(_settings.feedbackStartAction());
                                    Get.toNamed(AppRoutes.gameplay, arguments: {
                                      'chapter': chapter,
                                      'level': levelNum,
                                    });
                                  }
                                : null,
                            child: Transform.scale(
                              scale: lift,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  gradient: isUnlocked
                                      ? LinearGradient(
                                          colors: [
                                            theme.cardBackground,
                                            theme.cardBackground
                                                .withOpacity(0.85),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isUnlocked
                                      ? null
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: borderRadius,
                                  border: Border.all(
                                    color: isUnlocked
                                        ? (completed
                                            ? theme.success
                                            : (borderGlow ?? theme.cardBorder))
                                        : Colors.white10,
                                    width: 2,
                                  ),
                                  boxShadow: isUnlocked
                                      ? [
                                          BoxShadow(
                                            color: (borderGlow ??
                                                    theme.cardBorder)
                                                .withOpacity(
                                                  0.15 + effective * 0.15,
                                                ),
                                            blurRadius: 8 + effective * 6,
                                            spreadRadius: 0.5,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isUnlocked)
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            '$levelNum',
                                            style:
                                                ChapterThemes.resolveFont(
                                              theme.fontFamily,
                                              TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w900,
                                                color: theme.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (completed)
                                            Positioned(
                                              right: -4,
                                              top: -4,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: theme.success,
                                                size: 20,
                                              ),
                                            ),
                                        ],
                                      )
                                    else
                                      Icon(Icons.lock,
                                          color: theme.textMuted, size: 32),
                                    if (isUnlocked) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        '${level.pairs} pairs',
                                        style: TextStyle(
                                          color: theme.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (attempts > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            attempts == 1
                                                ? '1 attempt'
                                                : '$attempts attempts',
                                            style: TextStyle(
                                              color: attemptsColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children:
                                            List.generate(3, (starIndex) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 1),
                                            child: Icon(
                                              Icons.star,
                                              color: starIndex < bestStars
                                                  ? Colors.yellow
                                                  : Colors.grey.shade700,
                                              size: 16,
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
