import 'dart:math';

import '../features/gameplay/models/level.dart';

class LevelRepository {
  static const int totalChapters = 20;
  static const int levelsPerChapter = 50;

  static const List<String> colorPalette = [
    'red',
    'blue',
    'green',
    'yellow',
    'orange',
    'purple',
    'cyan',
    'pink',
    'brown',
    'teal',
    'lime',
    'indigo',
    'amber',
    'deepOrange',
    'lightBlue',
    'lightGreen',
    'deepPurple',
    'amberDeep',
    'rose',
    'sky',
  ];

  static const List<String> obstacleTypes = ['wall', 'rock', 'void', 'block'];

  static double progress(int chapter, int levelInChapter) {
    final index = (chapter - 1) * levelsPerChapter + (levelInChapter - 1);
    final maxIndex = totalChapters * levelsPerChapter - 1;
    return index / maxIndex;
  }

  static int globalLevelId(int chapter, int levelInChapter) {
    return (chapter - 1) * levelsPerChapter + levelInChapter;
  }

  static (int chapter, int levelInChapter) parseLevelId(int id) {
    final chapter = ((id - 1) ~/ levelsPerChapter) + 1;
    final levelInChapter = ((id - 1) % levelsPerChapter) + 1;
    return (chapter, levelInChapter);
  }

  static int difficultyScore(int chapter, int levelInChapter) {
    final p = progress(chapter, levelInChapter);
    final steep = (p * p * 0.55 + p * 0.45);
    return (1 + steep * 99).round();
  }

  static int pairsFor(int chapter, int levelInChapter) {
    final chapterJump = (chapter - 1) * 2;
    final levelBump = (levelInChapter - 1) ~/ 2;
    return (3 + chapterJump + levelBump).clamp(3, 20);
  }

  static double minDotSeparation(int chapter, int levelInChapter) {
    final p = progress(chapter, levelInChapter);
    return 35 - p * 30;
  }

  static double dotHitRadius(int chapter, int levelInChapter) {
    final p = progress(chapter, levelInChapter);
    return 16 - p * 12;
  }

  static double boardPadding(int chapter, int levelInChapter) {
    final p = progress(chapter, levelInChapter);
    return 16 - p * 14;
  }

  static int chapterDifficultyStars(int chapter) {
    if (chapter <= 3) return 1;
    if (chapter <= 8) return 2;
    return 3;
  }

  static int levelDifficultyStars(int chapter, int levelInChapter) {
    final withinChapter = (levelInChapter - 1) / (levelsPerChapter - 1);
    final chapterWeight = (chapter - 1) / (totalChapters - 1);
    final combined = (chapterWeight * 0.75) + (withinChapter * 0.25);
    if (combined < 0.50) return 1;
    if (combined < 0.85) return 2;
    return 3;
  }

  static int timeLimitFor(int chapter, int levelInChapter) {
    final p = progress(chapter, levelInChapter);
    final withinChapter = (levelInChapter - 1) / (levelsPerChapter - 1);
    final base = 120 - (p * 110).round();
    return (base - withinChapter * 10).round().clamp(10, 120);
  }

  static int moveLimitFor(int chapter, int levelInChapter) {
    final pairs = pairsFor(chapter, levelInChapter);
    final p = progress(chapter, levelInChapter);
    final withinChapter = (levelInChapter - 1) / (levelsPerChapter - 1);
    final baseMult = 2.5 - p * 1.3;
    final multiplier = (baseMult - withinChapter * 0.5).clamp(1.2, 2.5);
    return max(pairs + 1, (pairs * multiplier).round());
  }

  static List<Obstacle> _buildObstacles(
    int chapter,
    int levelInChapter,
    int gridSize,
  ) {
    final obstacles = <Obstacle>[];
    final rand = Random(7777 + chapter * 1000 + levelInChapter * 31);

    final withinChapter = (levelInChapter - 1) / (levelsPerChapter - 1);
    final chapterFactor = (chapter - 1) / (totalChapters - 1);

    final minDensity = 0.04 + chapterFactor * 0.03 + withinChapter * 0.03;
    final maxDensity = 0.08 + chapterFactor * 0.20 + withinChapter * 0.08;
    final density = minDensity + rand.nextDouble() * (maxDensity - minDensity);

    final totalCells = gridSize * gridSize;
    final targetCount = (totalCells * density).round();
    final placed = <Point>{};

    final cornerMargin = (gridSize <= 5) ? 1 : 2;

    for (
      var i = 0;
      i < targetCount * 4 && obstacles.length < targetCount;
      i++
    ) {
      final ox = rand.nextInt(gridSize);
      final oy = rand.nextInt(gridSize);

      if (ox < cornerMargin && oy < cornerMargin) continue;
      if (ox < cornerMargin && oy >= gridSize - cornerMargin) continue;
      if (ox >= gridSize - cornerMargin && oy < cornerMargin) continue;
      if (ox >= gridSize - cornerMargin && oy >= gridSize - cornerMargin)
        continue;

      final candidate = Point(ox, oy);
      if (placed.contains(candidate)) continue;

      bool tooClose = false;
      for (final p in placed) {
        final dx = (p.x - ox).abs();
        final dy = (p.y - oy).abs();
        if (dx <= 1 && dy <= 1) {
          tooClose = true;
          break;
        }
      }
      if (tooClose && obstacles.length > targetCount ~/ 2) continue;

      placed.add(candidate);
      final type = obstacleTypes[rand.nextInt(obstacleTypes.length)];
      obstacles.add(Obstacle(x: ox, y: oy, type: type));
    }

    return obstacles;
  }

  static Level buildLevel(int chapter, int levelInChapter) {
    final pairs = pairsFor(chapter, levelInChapter);
    final gridSize = (5 + (chapter - 1) ~/ 3).clamp(5, 10);
    final obstacles = _buildObstacles(chapter, levelInChapter, gridSize);

    return Level(
      id: globalLevelId(chapter, levelInChapter),
      chapter: chapter,
      gridSize: gridSize,
      pairs: pairs,
      difficulty: difficultyScore(chapter, levelInChapter),
      colors: colorPalette.take(pairs).toList(),
      pairPoints: const {},
      obstacles: obstacles,
      timeLimit: timeLimitFor(chapter, levelInChapter),
      moveLimit: moveLimitFor(chapter, levelInChapter),
    );
  }

  static Level? getLevel(int id) {
    final (chapter, levelInChapter) = parseLevelId(id);
    if (chapter < 1 || chapter > totalChapters) return null;
    return buildLevel(chapter, levelInChapter);
  }

  static Level? getLevelForChapter(int chapter, int levelInChapter) {
    if (chapter < 1 ||
        chapter > totalChapters ||
        levelInChapter < 1 ||
        levelInChapter > levelsPerChapter) {
      return null;
    }
    return buildLevel(chapter, levelInChapter);
  }

  static List<Level> getLevelsForChapter(int chapter) {
    if (chapter < 1 || chapter > totalChapters) return [];
    return List.generate(
      levelsPerChapter,
      (index) => buildLevel(chapter, index + 1),
    );
  }

  static (int chapter, int levelInChapter)? nextLevel(int currentId) {
    final (chapter, levelInChapter) = parseLevelId(currentId);
    if (levelInChapter < levelsPerChapter) {
      return (chapter, levelInChapter + 1);
    }
    if (chapter < totalChapters) {
      return (chapter + 1, 1);
    }
    return null;
  }
}
