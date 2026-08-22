import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/chapter_themes.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../data/coin_repository.dart';
import '../../../data/level_repository.dart';
import '../../../data/progress_repository.dart';
import '../settings/controllers/settings_controller.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _trophyCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _starBaseCtrl;
  late final AnimationController _starsGlowCtrl;
  late final AnimationController _coinCtrl;
  late final AnimationController _buttonsCtrl;
  final SettingsController _settings = SettingsController.to;
  final List<AnimationController> _starCtrls = [];
  Timer? _starTimer;
  Timer? _victoryTimer;
  bool _sfxLaid = false;

  @override
  void initState() {
    super.initState();
    _trophyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _starBaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _starsGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _coinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _buttonsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    for (var i = 0; i < 3; i++) {
      _starCtrls.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      ));
    }
    unawaited(_startTimeline());
  }

  Future<void> _startTimeline() async {
    final args = Get.arguments as Map<String, dynamic>?;
    final completedLevelId = args?['levelId'] ?? 1;
    final attempts =
        (args?['attempts'] as int?) ??
        ProgressRepository.attemptsFor(completedLevelId);
    final starsEarned = ProgressRepository.starsForAttempts(attempts);
    final bestStars = ProgressRepository.bestStarsFor(completedLevelId);
    final displayStars = bestStars > starsEarned ? bestStars : starsEarned;
    final (chapter, _) = LevelRepository.parseLevelId(completedLevelId);

    unawaited(_settings.playChapterMusic(chapter));

    await Future.wait<void>([
      _trophyCtrl.forward(),
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _titleCtrl.forward();
      }),
    ]);

    if (!mounted) return;
    unawaited(_settings.feedbackWin());

    _victoryTimer = Timer(const Duration(milliseconds: 120), () {
      unawaited(_settings.playVictory());
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    for (var i = 0; i < displayStars && mounted; i++) {
      final starDelay = Duration(milliseconds: 250 + i * 350);
      _starTimer = Timer(starDelay, () {
        if (!mounted) return;
        _starCtrls[i].forward(from: 0);
        unawaited(_settings.playStarChime());
      });
    }
    final totalStarAnimMs = 250 + (displayStars - 1).clamp(0, 2) * 350 + 750;

    await Future.delayed(Duration(milliseconds: totalStarAnimMs));
    if (!mounted) return;

    _coinCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _buttonsCtrl.forward();
    _sfxLaid = true;
  }

  @override
  void dispose() {
    _victoryTimer?.cancel();
    _starTimer?.cancel();
    _trophyCtrl.dispose();
    _titleCtrl.dispose();
    _starBaseCtrl.dispose();
    _starsGlowCtrl.dispose();
    _coinCtrl.dispose();
    _buttonsCtrl.dispose();
    for (final c in _starCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final completedLevelId = args?['levelId'] ?? 1;
    final attempts =
        (args?['attempts'] as int?) ??
        ProgressRepository.attemptsFor(completedLevelId);
    final coinsEarned = (args?['coinsEarned'] as int?) ?? 0;
    final (chapter, levelInChapter) = LevelRepository.parseLevelId(
      completedLevelId,
    );
    final next = LevelRepository.nextLevel(completedLevelId);
    final theme = ChapterThemes.forChapter(chapter);

    final starsEarned = ProgressRepository.starsForAttempts(attempts);
    final bestStars = ProgressRepository.bestStarsFor(completedLevelId);
    final displayStars = bestStars > starsEarned ? bestStars : starsEarned;
    final firstClearReward = coinsEarned;

    String attemptLabel;
    if (attempts == 1) {
      attemptLabel = '1st Attempt – Perfect!';
    } else {
      attemptLabel = 'Completed in $attempts attempts';
    }

    final borderRadius = BorderRadius.circular(theme.borderRadius);

    return Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Trophy / Top icon
                AnimatedBuilder(
                  animation: _trophyCtrl,
                  builder: (context, _) {
                    final t = Curves.elasticOut.transform(_trophyCtrl.value);
                    final rotation =
                        sin(_trophyCtrl.value * pi * 2) * 0.04 * (1 - t);
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(0.3 + t * 0.7)
                        ..rotateZ(rotation),
                      child: Opacity(
                        opacity: _trophyCtrl.value,
                        child: AnimatedBuilder(
                          animation: _starsGlowCtrl,
                          builder: (_, __) {
                            final glow = 20 + _starsGlowCtrl.value * 35;
                            final iconColor = displayStars >= 3
                                ? Colors.amber
                                : displayStars >= 2
                                ? theme.warning
                                : theme.primary;
                            return Icon(
                              displayStars >= 3
                                  ? Icons.emoji_events
                                  : displayStars >= 2
                                  ? Icons.stars
                                  : Icons.thumb_up,
                              color: iconColor,
                              size: 100,
                              shadows: [
                                Shadow(
                                  color: iconColor.withOpacity(
                                    0.35 + _starsGlowCtrl.value * 0.4,
                                  ),
                                  blurRadius: glow,
                                ),
                                Shadow(
                                  color: iconColor.withOpacity(0.3),
                                  blurRadius: glow / 1.8,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Title
                FadeTransition(
                  opacity: _titleCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _titleCtrl,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Text(
                      'LEVEL COMPLETE!',
                      textAlign: TextAlign.center,
                      style: ChapterThemes.resolveFont(
                        theme.fontFamily,
                        TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: theme.success,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: theme.success.withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _titleCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _titleCtrl,
                      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                    )),
                    child: Text(
                      '${theme.name}  ·  CH $chapter · LV $levelInChapter',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: theme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _titleCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _titleCtrl,
                      curve:
                          const Interval(0.35, 1.0, curve: Curves.easeOut),
                    )),
                    child: Text(
                      attemptLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Stars (3 with staggered animations)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final starLit = index < displayStars;
                    final ctrl = _starCtrls[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([ctrl, _starsGlowCtrl]),
                        builder: (_, __) {
                          final anim = Curves.elasticOut.transform(ctrl.value);
                          final enterScale = 0.1 + anim * 0.9;
                          final overshoot = ctrl.value < 0.55
                              ? 1.0 + (ctrl.value / 0.55) * 0.28
                              : 1.28 -
                                  ((ctrl.value - 0.55) / 0.45) * 0.28;
                          final scale =
                              ctrl.value == 0 ? 0.0 : enterScale * overshoot;
                          final rot =
                              sin(ctrl.value * pi * 2) * (0.35 * (1 - anim));
                          final alpha = ctrl.value == 0 ? 0.0 : ctrl.value;
                          final glow =
                              10 + _starsGlowCtrl.value * 18 + anim * 8;
                          return Opacity(
                            opacity: alpha,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scale(max(scale, 0.01))
                                ..rotateZ(rot),
                              child: starLit
                                  ? Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 56,
                                      shadows: [
                                        Shadow(
                                          color: Colors.amberAccent
                                              .withOpacity(0.45 + anim * 0.4),
                                          blurRadius: glow,
                                        ),
                                        Shadow(
                                          color:
                                              Colors.orange.withOpacity(0.35),
                                          blurRadius: glow / 2.2,
                                        ),
                                      ],
                                    )
                                  : Icon(
                                      Icons.star_border,
                                      color: Colors.grey.shade700,
                                      size: 56,
                                    ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                if (bestStars > 0 && bestStars != starsEarned)
                  FadeTransition(
                    opacity: _coinCtrl,
                    child: Text(
                      'Best: $bestStars ⭐  ·  This run: $starsEarned ⭐',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: theme.textMuted),
                    ),
                  ),
                const SizedBox(height: 24),

                // Coins card
                if (firstClearReward > 0)
                  AnimatedBuilder(
                    animation: _coinCtrl,
                    builder: (context, _) {
                      final t = Curves.elasticOut.transform(_coinCtrl.value);
                      final bounce = _coinCtrl.value < 0.45
                          ? 1.0 + (_coinCtrl.value / 0.45) * 0.06
                          : 1.06 -
                              ((_coinCtrl.value - 0.45) / 0.55) * 0.06;
                      return Opacity(
                        opacity: _coinCtrl.value,
                        child: Transform.scale(
                          scale: t * bounce,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withOpacity(0.35),
                                  Colors.yellowAccent.withOpacity(0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.7),
                              ),
                              borderRadius: borderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(
                                    0.1 + _starsGlowCtrl.value * 0.18,
                                  ),
                                  blurRadius: 12 + _starsGlowCtrl.value * 8,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _starsGlowCtrl,
                                  builder: (_, __) {
                                    final pulse = 1.0 +
                                        0.1 *
                                            (1.0 -
                                                (_starsGlowCtrl.value - 0.5)
                                                        .abs() *
                                                    2);
                                    return Transform.scale(
                                      scale: pulse,
                                      child: const Icon(
                                        Icons.monetization_on,
                                        color: Colors.yellow,
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '+$firstClearReward COINS EARNED!',
                                  style: ChapterThemes.resolveFont(
                                    theme.fontFamily,
                                    const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.yellow,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  FadeTransition(
                    opacity: _coinCtrl,
                    child: Text(
                      'Replay does not award coins',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const Spacer(),

                // Next level button + Row buttons
                FadeTransition(
                  opacity: _buttonsCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _buttonsCtrl,
                      curve: Curves.easeOutCubic,
                    )),
                    child: Column(
                      children: [
                        if (next != null)
                          ElevatedButton(
                            onPressed: () {
                              unawaited(_settings.feedbackStartAction());
                              Get.offNamed(
                                AppRoutes.gameplay,
                                arguments: {
                                  'chapter': next.$1,
                                  'level': next.$2,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.success,
                              foregroundColor: theme.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: borderRadius,
                              ),
                              shadowColor:
                                  theme.success.withOpacity(0.45),
                              elevation: 12,
                              textStyle: ChapterThemes.resolveFont(
                                theme.fontFamily,
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            child: const Text('NEXT LEVEL'),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  unawaited(_settings.selectionClick());
                                  Get.offNamed(
                                    AppRoutes.gameplay,
                                    arguments: {
                                      'chapter': chapter,
                                      'level': levelInChapter,
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.cardBackground,
                                  foregroundColor: theme.textPrimary,
                                  side: BorderSide(color: theme.cardBorder),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: borderRadius,
                                  ),
                                ),
                                child: Text(
                                  'REPLAY',
                                  style: ChapterThemes.resolveFont(
                                    theme.fontFamily,
                                    const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  unawaited(_settings.selectionClick());
                                  Get.offAllNamed(AppRoutes.home);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primary,
                                  foregroundColor: theme.textPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: borderRadius,
                                  ),
                                ),
                                child: Text(
                                  'HOME',
                                  style: ChapterThemes.resolveFont(
                                    theme.fontFamily,
                                    const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
