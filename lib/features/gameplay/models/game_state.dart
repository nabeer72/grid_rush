import 'level.dart';

class GameState {
  final Level currentLevel;
  
  // paths: map of color string to list of points (x,y)
  Map<String, List<Point>> paths;
  
  int moves;
  int elapsedTime; // in seconds
  int mistakes;
  int hintsUsed;
  bool isCompleted;

  GameState({
    required this.currentLevel,
    Map<String, List<Point>>? paths,
    this.moves = 0,
    this.elapsedTime = 0,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.isCompleted = false,
  }) : paths = paths ?? {};
}
