import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/coin_repository.dart';
import '../../../data/level_repository.dart';
import '../../../data/progress_repository.dart';
import '../../settings/controllers/settings_controller.dart';
import '../models/game_state.dart';
import '../models/level.dart';

class GameplayController extends GetxController {
  final SettingsController _settings = Get.find<SettingsController>();
  final CoinRepository _coins = CoinRepository.to;
  GameState? gameState;
  bool isInitialized = false;
  var moves = 0.obs;
  var isCompleted = false.obs;
  var timeRemaining = 0.obs;
  var isTimeUp = false.obs;
  var attemptsThisSession = 0.obs;
  var freeRearrangesLeft = 5.obs;

  List<Offset> freePath = [];
  Map<String, List<Offset>> freeDotPairs = {};
  String? _activeFreeColor;
  int? _activeStartDotIndex;
  Map<String, List<Offset>> completedFreePaths = {};
  var isGameOver = false.obs;

  double _boardSize = 0;
  Timer? _timer;
  bool _levelStartedRecorded = false;

  String? get activeFreeColor => _activeFreeColor;

  double get _hitRadius {
    if (gameState == null) return 22;
    final (chapter, levelInChapter) = LevelRepository.parseLevelId(
      gameState!.currentLevel.id,
    );
    return LevelRepository.dotHitRadius(chapter, levelInChapter);
  }

  double get _minDotSeparation {
    if (gameState == null) return 48;
    final (chapter, levelInChapter) = LevelRepository.parseLevelId(
      gameState!.currentLevel.id,
    );
    return LevelRepository.minDotSeparation(chapter, levelInChapter);
  }

  double get _boardPadding {
    if (gameState == null) return 28;
    final (chapter, levelInChapter) = LevelRepository.parseLevelId(
      gameState!.currentLevel.id,
    );
    return LevelRepository.boardPadding(chapter, levelInChapter);
  }

  List<Obstacle> get currentObstacles =>
      gameState?.currentLevel.obstacles ?? const [];
  int get currentGridSize => gameState?.currentLevel.gridSize ?? 5;

  void initLevel(Level level) {
    _timer?.cancel();
    gameState = GameState(currentLevel: level);
    isInitialized = true;
    moves.value = 0;
    isCompleted.value = false;
    isTimeUp.value = false;
    _activeFreeColor = null;
    _activeStartDotIndex = null;
    freeRearrangesLeft.value = 5;
    freePath.clear();
    freeDotPairs.clear();
    completedFreePaths.clear();
    if (!_levelStartedRecorded) {
      attemptsThisSession.value = ProgressRepository.incrementAttempts(
        level.id,
      );
      _levelStartedRecorded = true;
    }
    if (level.timeLimit > 0) {
      timeRemaining.value = level.timeLimit;
      _startTimer();
    } else {
      timeRemaining.value = 0;
    }
    if (_boardSize > 0) {
      _generateFreeDots(_boardSize);
    }
    update();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isCompleted.value || isGameOver.value) {
        timer.cancel();
        return;
      }
      timeRemaining.value--;
      if (timeRemaining.value <= 0) {
        timer.cancel();
        isTimeUp.value = true;
        _triggerGameOver();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setBoardSize(double size) {
    if (size <= 0 || size == _boardSize) return;
    _boardSize = size;
    _generateFreeDots(size);
    update();
  }

  Rect _obstacleRect(Obstacle o, double boardSize) {
    final padding = _boardPadding;
    final usable = boardSize - padding * 2;
    final gridSize = currentGridSize.toDouble();
    final cellSize = usable / gridSize;
    final left = padding + o.x * cellSize;
    final top = padding + o.y * cellSize;
    return Rect.fromLTWH(left, top, cellSize, cellSize);
  }

  bool _pointHitsAnyObstacle(Offset p, double boardSize) {
    for (final o in currentObstacles) {
      final rect = _obstacleRect(o, boardSize);
      final shrink = 4.0;
      final inner = rect.deflate(shrink);
      if (inner.contains(p)) return true;
    }
    return false;
  }

  bool _lineHitsAnyObstacle(Offset a, Offset b, double boardSize) {
    for (final o in currentObstacles) {
      final rect = _obstacleRect(o, boardSize);
      if (_lineIntersectsRect(a, b, rect)) return true;
    }
    return false;
  }

  bool _lineIntersectsRect(Offset a, Offset b, Rect rect) {
    if (rect.contains(a) || rect.contains(b)) return true;
    final tl = rect.topLeft;
    final tr = rect.topRight;
    final bl = rect.bottomLeft;
    final br = rect.bottomRight;
    return _linesIntersect(a, b, tl, tr) ||
        _linesIntersect(a, b, tr, br) ||
        _linesIntersect(a, b, br, bl) ||
        _linesIntersect(a, b, bl, tl);
  }

  bool _linesIntersect(Offset a1, Offset a2, Offset b1, Offset b2) {
    double ccw(Offset p1, Offset p2, Offset p3) {
      return (p3.dy - p1.dy) * (p2.dx - p1.dx) -
          (p2.dy - p1.dy) * (p3.dx - p1.dx);
    }

    final d1 = ccw(b1, b2, a1);
    final d2 = ccw(b1, b2, a2);
    final d3 = ccw(a1, a2, b1);
    final d4 = ccw(a1, a2, b2);
    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }
    return false;
  }

  static const double _visualDotRadius = 10.0;

  double get _borderInnerTolerance {
    final hr = _hitRadius;
    return (_visualDotRadius - (hr * 0.4)).clamp(2.0, 8.0);
  }

  double get _borderOuterTolerance {
    final hr = _hitRadius;
    return (_visualDotRadius + (hr * 0.9)).clamp(
      _visualDotRadius + 3.0,
      _visualDotRadius + 14.0,
    );
  }

  (String? color, int? dotIndex) _findDotOnBorder(Offset p) {
    final outer = _borderOuterTolerance;

    for (final entry in freeDotPairs.entries) {
      if (completedFreePaths.containsKey(entry.key)) continue;
      for (var i = 0; i < entry.value.length; i++) {
        final d = (entry.value[i] - p).distance;
        if (d <= outer) {
          return (entry.key, i);
        }
      }
    }
    return (null, null);
  }

  (String? color, int? dotIndex) _findDotOnBorderExact(Offset p) {
    final outer = (_borderOuterTolerance + 1.0).clamp(
      _visualDotRadius + 4.0,
      _visualDotRadius + 15.0,
    );

    for (final entry in freeDotPairs.entries) {
      if (completedFreePaths.containsKey(entry.key)) continue;
      for (var i = 0; i < entry.value.length; i++) {
        final d = (entry.value[i] - p).distance;
        if (d <= outer) {
          return (entry.key, i);
        }
      }
    }
    return (null, null);
  }

  void startFreePath(Offset p) {
    if (isGameOver.value || (gameState?.isCompleted ?? false)) return;
    if (_pointHitsAnyObstacle(p, _boardSize)) return;

    freePath = [];
    _activeFreeColor = null;
    _activeStartDotIndex = null;

    final found = _findDotOnBorder(p);
    if (found.$1 != null && found.$2 != null) {
      _activeFreeColor = found.$1;
      _activeStartDotIndex = found.$2;
      final dotCenter = freeDotPairs[found.$1]![found.$2!];
      freePath = [dotCenter];
    }
    update();
  }

  Offset _clampInsidePlayArea(Offset p, double boardSize) {
    final padding = _boardPadding + _hitRadius * 0.5;
    final minX = padding;
    final maxX = boardSize - padding;
    final minY = padding;
    final maxY = boardSize - padding;
    final x = p.dx.clamp(minX, maxX);
    final y = p.dy.clamp(minY, maxY);
    return Offset(x.toDouble(), y.toDouble());
  }

  static const double _visualEdgeTolerance = 2.5;

  bool _lineTouchesBoundary(Offset a, Offset b, double boardSize) {
    const edgeTol = _visualEdgeTolerance;
    final left = 0.0;
    final top = 0.0;
    final right = boardSize;
    final bottom = boardSize;

    bool nearBoundary(Offset p) {
      return (p.dx < left - edgeTol) ||
          (p.dx > right + edgeTol) ||
          (p.dy < top - edgeTol) ||
          (p.dy > bottom + edgeTol);
    }

    bool hitsBorderLine(Offset p) {
      return (p.dx <= left + edgeTol && p.dx >= left - edgeTol) ||
          (p.dx >= right - edgeTol && p.dx <= right + edgeTol) ||
          (p.dy <= top + edgeTol && p.dy >= top - edgeTol) ||
          (p.dy >= bottom - edgeTol && p.dy <= bottom + edgeTol);
    }

    return nearBoundary(a) ||
        nearBoundary(b) ||
        hitsBorderLine(a) ||
        hitsBorderLine(b);
  }

  bool _lineCrossesExistingPaths(Offset a, Offset b, String? skipColor) {
    for (final entry in completedFreePaths.entries) {
      if (entry.key == skipColor) continue;
      final pts = entry.value;
      for (var i = 0; i < pts.length - 1; i++) {
        final c = pts[i];
        final d = pts[i + 1];
        if ((c - a).distance < 0.5 || (d - a).distance < 0.5) continue;
        if ((c - b).distance < 0.5 || (d - b).distance < 0.5) continue;
        if (_linesIntersect(a, b, c, d)) return true;
      }
    }
    for (var i = 0; i < freePath.length - 2; i++) {
      final c = freePath[i];
      final d = freePath[i + 1];
      if ((c - a).distance < 0.5 || (d - a).distance < 0.5) continue;
      if ((c - b).distance < 0.5 || (d - b).distance < 0.5) continue;
      if (_linesIntersect(a, b, c, d)) return true;
    }
    return false;
  }

  void extendFreePath(Offset p) {
    if (freePath.isEmpty || _activeFreeColor == null) return;
    if ((freePath.last - p).distance < 2) return;

    final last = freePath.last;
    if (_lineHitsAnyObstacle(last, p, _boardSize)) {
      _triggerGameOver();
      return;
    }
    if (_pointHitsAnyObstacle(p, _boardSize)) {
      _triggerGameOver();
      return;
    }

    if (_lineTouchesBoundary(last, p, _boardSize)) {
      return;
    }
    if (_lineCrossesExistingPaths(last, p, _activeFreeColor)) {
      _triggerGameOver();
      return;
    }

    final found = _findDotOnBorderExact(p);
    if (found.$1 != null && found.$2 != null) {
      final color = found.$1!;
      final i = found.$2!;

      if (color == _activeFreeColor && i != _activeStartDotIndex) {
        final dot = freeDotPairs[color]![i];
        freePath.add(dot);
        completedFreePaths[color] = List.from(freePath);
        moves.value++;
        _activeFreeColor = null;
        _activeStartDotIndex = null;
        freePath.clear();
        unawaited(_settings.feedbackLineComplete());
        _checkMoveLimit();
        _checkFreePlayWin();
        update();
        return;
      }

      if (color != _activeFreeColor) {
        final wrongDotCenter = freeDotPairs[color]![i];
        if ((wrongDotCenter - p).distance <= _visualDotRadius + 2.0) {
          _triggerGameOver();
          return;
        }
      }
    }

    freePath.add(p);
    update();
  }

  void endFreePath() {
    if (_activeFreeColor != null) {
      freePath.clear();
      _activeFreeColor = null;
      _activeStartDotIndex = null;
      update();
    }
  }

  void resetFreePath() {
    freePath.clear();
    _activeFreeColor = null;
    _activeStartDotIndex = null;
    update();
  }

  void _generateFreeDots(double boardSize) {
    freeDotPairs.clear();
    completedFreePaths.clear();
    if (gameState == null) return;

    final rand = Random();
    final padding = _boardPadding;
    final usable = boardSize - padding * 2;
    if (usable <= 0) return;

    final placedDots = <Offset>[];

    for (final color in gameState!.currentLevel.colors) {
      final dots = <Offset>[];
      for (var i = 0; i < 2; i++) {
        Offset? candidate;
        for (var attempt = 0; attempt < 250; attempt++) {
          final pos = Offset(
            padding + rand.nextDouble() * usable,
            padding + rand.nextDouble() * usable,
          );
          if (!_isFarEnough(pos, [...placedDots, ...dots])) continue;
          if (_pointHitsAnyObstacle(pos, boardSize)) continue;
          bool nearObstacle = false;
          for (final o in currentObstacles) {
            final r = _obstacleRect(o, boardSize).inflate(6);
            if (r.contains(pos)) {
              nearObstacle = true;
              break;
            }
          }
          if (nearObstacle) continue;
          candidate = pos;
          break;
        }
        candidate ??= Offset(
          padding + rand.nextDouble() * usable,
          padding + rand.nextDouble() * usable,
        );
        dots.add(candidate);
      }
      placedDots.addAll(dots);
      freeDotPairs[color] = dots;
    }
  }

  bool _isFarEnough(Offset pos, List<Offset> existing) {
    for (final other in existing) {
      if ((pos - other).distance < _minDotSeparation) return false;
    }
    return true;
  }

  void _checkMoveLimit() {
    if (gameState == null) return;
    final limit = gameState!.currentLevel.moveLimit;
    if (limit > 0 && moves.value >= limit) {
      _triggerGameOver();
    }
  }

  void _checkFreePlayWin() {
    if (gameState == null) return;
    final allDone = gameState!.currentLevel.colors.every(
      (color) => completedFreePaths.containsKey(color),
    );
    if (!allDone) return;
    isCompleted.value = true;
    gameState!.isCompleted = true;
    _timer?.cancel();
    unawaited(_settings.feedbackWin());

    final levelId = gameState!.currentLevel.id;
    final wasCompletedBefore = ProgressRepository.isCompleted(levelId);
    final starsAtCompletion = ProgressRepository.starsForAttempts(
      attemptsThisSession.value,
    );
    ProgressRepository.markCompleted(levelId);
    ProgressRepository.starsEarnedOn(levelId, attemptsThisSession.value);

    int coinsEarned = 0;
    if (!wasCompletedBefore) {
      coinsEarned = CoinRepository.coinsForLevel(
        starsAtCompletion,
        gameState!.currentLevel.difficulty,
      );
      unawaited(_coins.addCoins(coinsEarned));
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offNamed(
        '/results',
        arguments: {
          'levelId': levelId,
          'attempts': attemptsThisSession.value,
          'coinsEarned': coinsEarned,
        },
      );
    });
  }

  bool get canBuyExtraTime {
    if (gameState == null) return false;
    if (gameState!.currentLevel.timeLimit <= 0) return false;
    if (isCompleted.value || isGameOver.value) return false;
    return _coins.canAfford(CoinRepository.extraTimeCost);
  }

  Future<bool> buyExtraTime() async {
    if (!canBuyExtraTime) return false;
    final ok = await _coins.spendCoins(CoinRepository.extraTimeCost);
    if (!ok) return false;
    timeRemaining.value += CoinRepository.extraTimeSeconds;
    unawaited(_settings.selectionClick());
    return true;
  }

  void _triggerGameOver() {
    if (isGameOver.value) return;
    isGameOver.value = true;
    _timer?.cancel();
    unawaited(_settings.feedbackGameOver());
    Future.delayed(const Duration(milliseconds: 800), () {
      reset();
      isGameOver.value = false;
    });
  }

  void undo() {
    resetFreePath();
  }

  Future<void> manualRearrange() async {
    if (freeRearrangesLeft.value > 0) {
      freeRearrangesLeft.value--;
      reset();
    } else {
      if (_coins.canAfford(30)) {
        final ok = await _coins.spendCoins(30);
        if (ok) {
          reset();
        }
      } else {
        Get.snackbar(
          'Not enough coins',
          'You need 30 coins to rearrange.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }

  void reset() {
    if (gameState != null && !isCompleted.value) {
      attemptsThisSession.value = ProgressRepository.incrementAttempts(
        gameState!.currentLevel.id,
      );
    }
    gameState?.paths.clear();
    moves.value = 0;
    if (gameState != null) gameState!.moves = 0;
    isCompleted.value = false;
    if (gameState != null) gameState!.isCompleted = false;
    isTimeUp.value = false;
    if (gameState != null && gameState!.currentLevel.timeLimit > 0) {
      timeRemaining.value = gameState!.currentLevel.timeLimit;
      _startTimer();
    } else {
      timeRemaining.value = 0;
    }
    resetFreePath();
    completedFreePaths.clear();
    if (_boardSize > 0) {
      _generateFreeDots(_boardSize);
    }
    update();
  }
}
