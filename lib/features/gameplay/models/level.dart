class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(json['x'], json['y']);
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

class Level {
  final int id;
  final int chapter;
  final int gridSize;
  final int pairs; // number of color pairs
  final List<String> colors; // Hex or identifier for colors
  final Map<String, List<Point>> pairPoints; // start and end points for each color
  final List<Obstacle> obstacles;
  final List<String> specialTiles;
  final int moveLimit;
  final int timeLimit; // in seconds
  final int difficulty; // 1-100
  final String objective;

  Level({
    required this.id,
    required this.chapter,
    required this.gridSize,
    required this.pairs,
    required this.colors,
    required this.pairPoints,
    this.obstacles = const [],
    this.specialTiles = const [],
    this.moveLimit = 0,
    this.timeLimit = 0,
    required this.difficulty,
    this.objective = 'connect_all',
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    var pairPointsJson = json['pairPoints'] as Map<String, dynamic>? ?? {};
    Map<String, List<Point>> parsedPairPoints = {};
    pairPointsJson.forEach((key, value) {
      if (value is List) {
        parsedPairPoints[key] = value.map((p) => Point.fromJson(p)).toList();
      }
    });

    return Level(
      id: json['id'],
      chapter: json['chapter'] ?? 1,
      gridSize: json['gridSize'],
      pairs: json['pairs'],
      colors: List<String>.from(json['colors'] ?? []),
      pairPoints: parsedPairPoints,
      obstacles: (json['obstacles'] as List?)?.map((o) => Obstacle.fromJson(o)).toList() ?? [],
      specialTiles: List<String>.from(json['specialTiles'] ?? []),
      moveLimit: json['moveLimit'] ?? 0,
      timeLimit: json['timeLimit'] ?? 0,
      difficulty: json['difficulty'],
      objective: json['objective'] ?? 'connect_all',
    );
  }
}

class Obstacle {
  final int x;
  final int y;
  final String type; // e.g., 'wall', 'rock'

  Obstacle({required this.x, required this.y, required this.type});

  factory Obstacle.fromJson(Map<String, dynamic> json) {
    return Obstacle(
      x: json['x'],
      y: json['y'],
      type: json['type'],
    );
  }
}
