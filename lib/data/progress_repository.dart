import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'level_repository.dart';

/// Persistent progress storage: per‑level attempts, best stars, completion.
class ProgressRepository {
  static const _kPrefix = 'grid_rush_progress_v1';
  static const _kAttemptsKey = '$_kPrefix/attempts';
  static const _kStarsKey = '$_kPrefix/best_stars';
  static const _kCompletedKey = '$_kPrefix/completed';

  static SharedPreferences? _prefs;
  static final Map<int, int> _attemptsCache = {};
  static final Map<int, int> _bestStarsCache = {};
  static final Set<int> _completedCache = {};
  static bool _initialized = false;

  static int starsForAttempts(int attempts) {
    if (attempts <= 1) return 3;
    if (attempts <= 3) return 2;
    if (attempts <= 5) return 1;
    return 0;
  }

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final attemptsJson = _prefs?.getString(_kAttemptsKey);
    final starsJson = _prefs?.getString(_kStarsKey);
    final completedJson = _prefs?.getString(_kCompletedKey);

    _attemptsCache.clear();
    _bestStarsCache.clear();
    _completedCache.clear();

    if (attemptsJson != null && attemptsJson.isNotEmpty) {
      final Map<String, dynamic> m = jsonDecode(attemptsJson);
      m.forEach((k, v) {
        final id = int.tryParse(k);
        if (id != null && v is int) _attemptsCache[id] = v;
      });
    }
    if (starsJson != null && starsJson.isNotEmpty) {
      final Map<String, dynamic> m = jsonDecode(starsJson);
      m.forEach((k, v) {
        final id = int.tryParse(k);
        if (id != null && v is int) _bestStarsCache[id] = v;
      });
    }
    if (completedJson != null && completedJson.isNotEmpty) {
      final list = jsonDecode(completedJson) as List;
      for (final e in list) {
        if (e is int) _completedCache.add(e);
        if (e is String) {
          final id = int.tryParse(e);
          if (id != null) _completedCache.add(id);
        }
      }
    }
    _initialized = true;
  }

  static Future<void> _persist() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final a = <String, int>{};
    _attemptsCache.forEach((k, v) => a['$k'] = v);
    final s = <String, int>{};
    _bestStarsCache.forEach((k, v) => s['$k'] = v);
    await prefs.setString(_kAttemptsKey, jsonEncode(a));
    await prefs.setString(_kStarsKey, jsonEncode(s));
    await prefs.setString(
      _kCompletedKey,
      jsonEncode(_completedCache.toList()..sort()),
    );
  }

  static int attemptsFor(int levelId) => _attemptsCache[levelId] ?? 0;

  static int incrementAttempts(int levelId) {
    final next = (attemptsFor(levelId)) + 1;
    _attemptsCache[levelId] = next;
    _persist();
    return next;
  }

  static int bestStarsFor(int levelId) => _bestStarsCache[levelId] ?? 0;

  static int starsEarnedOn(int levelId, int attemptsAtCompletion) {
    final earned = starsForAttempts(attemptsAtCompletion);
    final best = bestStarsFor(levelId);
    if (earned > best) {
      _bestStarsCache[levelId] = earned;
      _persist();
    }
    return best > earned ? best : earned;
  }

  static bool isCompleted(int levelId) => _completedCache.contains(levelId);

  static void markCompleted(int levelId) {
    _completedCache.add(levelId);
    _persist();
  }

  static int totalStarsForChapter(int chapter, List<int> levelIds) {
    var total = 0;
    for (final id in levelIds) {
      total += bestStarsFor(id);
    }
    return total;
  }

  static bool isChapterUnlocked(int chapter) {
    if (chapter <= 1) return true;
    final prev = chapter - 1;
    final lv = LevelRepository.levelsPerChapter;
    for (var i = 1; i <= lv; i++) {
      final lastId = (prev - 1) * LevelRepository.levelsPerChapter + i;
      if (isCompleted(lastId)) return true;
    }
    return false;
  }

  static bool isLevelUnlocked(int chapter, int levelInChapter) {
    if (chapter <= 1 && levelInChapter <= 1) return true;
    if (levelInChapter == 1) {
      if (chapter <= 1) return true;
      final prevLastId =
          (chapter - 2) * LevelRepository.levelsPerChapter +
          LevelRepository.levelsPerChapter;
      return isCompleted(prevLastId);
    }
    final prevLevelId =
        (chapter - 1) * LevelRepository.levelsPerChapter + (levelInChapter - 1);
    return isCompleted(prevLevelId);
  }

  static Future<void> resetAll() async {
    _attemptsCache.clear();
    _bestStarsCache.clear();
    _completedCache.clear();
    await _persist();
  }
}
