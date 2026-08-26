import 'package:flutter/material.dart';
import '../../../app/chapter_themes.dart';
import '../../../data/level_repository.dart';
import '../controllers/gameplay_controller.dart';

class GridBoardWidget extends StatelessWidget {
  final GameplayController controller;
  final ChapterTheme? theme;

  const GridBoardWidget({super.key, required this.controller, this.theme});

  // Use more visually distinct colors for free dots
  static const Map<String, Color> colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'cyan': Colors.cyan,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'teal': Colors.teal,
    'lime': Colors.lime,
    'indigo': Colors.indigo,
    'amber': Colors.amber,
    'deepOrange': Colors.deepOrange,
    'lightBlue': Colors.lightBlue,
    'lightGreen': Colors.lightGreen,
    'deepPurple': Colors.deepPurple,
    'amberDeep': Color(0xFFFF8F00),
    'rose': Color(0xFFE91E63),
    'sky': Color(0xFF4FC3F7),
  };

  Map<String, _ObstacleStyle> _buildObstacleStyles() {
    final t = theme;
    final fallback = t?.accent ?? const Color(0xFF00F5D4);
    final errorC = t?.error ?? const Color(0xFFF72585);
    final borderC = t?.cardBorder ?? const Color(0xFF6C5CE7);
    final muted = t?.textMuted ?? Colors.white70;
    return {
      'wall': _ObstacleStyle(
        fill:
            Color.lerp(
              borderC.withOpacity(0.35),
              const Color(0xFF3C2F61),
              0.55,
            ) ??
            const Color(0xFF4E4276),
        border: borderC,
        pattern: true,
        accent: fallback,
      ),
      'rock': _ObstacleStyle(
        fill:
            Color.lerp(
              errorC.withOpacity(0.25),
              const Color(0xFF6D3A2F),
              0.6,
            ) ??
            const Color(0xFF6D4C41),
        border: errorC,
        pattern: false,
        accent: const Color(0xFFD7A86E),
      ),
      'void': _ObstacleStyle(
        fill: const Color(0xFF0D0B2B).withOpacity(0.85),
        border: borderC,
        pattern: true,
        accent: fallback,
      ),
      'block': _ObstacleStyle(
        fill: errorC.withOpacity(0.28),
        border: errorC,
        pattern: false,
        accent: muted,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final obstacleStyles = _buildObstacleStyles();
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!controller.isInitialized || controller.gameState == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final boardWidth = constraints.maxWidth;
        final boardHeight = constraints.maxHeight;
        controller.setScreenSize(Size(boardWidth, boardHeight));

        return GestureDetector(
          onPanStart: (details) =>
              controller.startFreePath(details.localPosition),
          onPanUpdate: (details) =>
              controller.extendFreePath(details.localPosition),
          onPanEnd: (_) => controller.endFreePath(),
          child: CustomPaint(
            size: Size(boardWidth, boardHeight),
            painter: FreeDrawPainter(
              controller: controller,
              colorMap: colorMap,
              obstacleStyles: obstacleStyles,
              theme: theme,
            ),
          ),
        );
      },
    );
  }
}

class _ObstacleStyle {
  final Color fill;
  final Color border;
  final bool pattern;
  final Color? accent;

  const _ObstacleStyle({
    required this.fill,
    required this.border,
    required this.pattern,
    this.accent,
  });
}

class FreeDrawPainter extends CustomPainter {
  final GameplayController controller;
  final Map<String, Color> colorMap;
  final Map<String, _ObstacleStyle> obstacleStyles;
  final ChapterTheme? theme;

  FreeDrawPainter({
    required this.controller,
    required this.colorMap,
    required this.obstacleStyles,
    this.theme,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    const thinStroke = 2.5;
    const dotRadius = 10.0;

    final t = theme;
    final borderColor = t?.cardBorder ?? const Color(0xFF6C5CE7);
    final cardBg = t?.cardBackground ?? Colors.transparent;

    final level = controller.gameState?.currentLevel;
    if (level != null) {
      _drawObstacles(canvas, size, level.gridSize);
    }

    final completedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thinStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    controller.completedFreePaths.forEach((colorStr, points) {
      if (points.length < 2) return;
      completedPaint.color = colorMap[colorStr] ?? Colors.white70;
      canvas.drawPath(_buildPath(points), completedPaint);
    });

    if (controller.freePath.length >= 2) {
      final activeColor = controller.activeFreeColor;
      final freePathPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thinStroke
        ..color = activeColor != null
            ? (colorMap[activeColor] ?? Colors.white70)
            : Colors.white70
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_buildPath(controller.freePath), freePathPaint);
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;

    controller.freeDotPairs.forEach((colorStr, dots) {
      dotPaint.color = colorMap[colorStr] ?? Colors.white70;
      for (final offset in dots) {
        canvas.drawCircle(offset, dotRadius, dotPaint);
      }
    });
  }

  void _drawBoardInnerBorder(
    Canvas canvas,
    Size size,
    Color borderColor,
    Color cardBg,
  ) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final Paint innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = borderColor.withOpacity(0.55);
    canvas.drawRRect(rrect, innerPaint);
  }

  void _drawObstacles(Canvas canvas, Size size, int gridSizeVal) {
    final obstacles = controller.currentObstacles;
    if (obstacles.isEmpty) return;

    final level = controller.gameState!.currentLevel;
    final args = _paddingAndUsable(size, level);
    final padding = args.$1;
    final usable = args.$2;
    final gridSize = gridSizeVal.toDouble();

    bool _isFarEnough(Offset pos, List<Offset> existing) {
      // Increase separation between free dots for clearer view
      const double separationFactor = 1.5;
      for (final other in existing) {
        const _minDotSeparation = 20.0;
        if ((pos - other).distance < _minDotSeparation * separationFactor) return false;
      }
      return true;
    }

    final cellSize = usable / gridSize;

    for (final o in obstacles) {
      final left = padding + o.x * cellSize;
      final top = padding + o.y * cellSize;
      final rect = Rect.fromLTWH(left, top, cellSize, cellSize);
      final style =
          obstacleStyles[o.type] ??
          _ObstacleStyle(
            fill: theme?.cardBorder.withOpacity(0.3) ?? const Color(0xFF424242),
            border: theme?.cardBorder ?? const Color(0xFF616161),
            pattern: false,
          );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      final fillPaint = Paint()..color = style.fill;
      canvas.drawRRect(rrect, fillPaint);

      final borderPaint = Paint()
        ..color = style.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawRRect(rrect, borderPaint);

      if (style.pattern) {
        final lineColor = (style.accent ?? style.border).withOpacity(0.55);
        final linePaint = Paint()
          ..color = lineColor
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        final step = cellSize / 3;
        for (var i = 1; i < 3; i++) {
          final offset = step * i;
          canvas.drawLine(
            Offset(left + offset, top + 2),
            Offset(left + offset, top + cellSize - 2),
            linePaint,
          );
          canvas.drawLine(
            Offset(left + 2, top + offset),
            Offset(left + cellSize - 2, top + offset),
            linePaint,
          );
        }
      } else {
        final inner = rect.deflate(5);
        final accentC = (style.accent ?? style.border).withOpacity(0.28);
        canvas.drawRRect(
          RRect.fromRectAndRadius(inner, const Radius.circular(4)),
          Paint()
            ..style = PaintingStyle.fill
            ..color = accentC,
        );
      }
    }
  }

  (double, double) _paddingAndUsable(Size size, dynamic level) {
    final boardSize = size.width;
    final c = controller;
    final gs = c.gameState;
    if (gs == null) return (28.0, boardSize - 56);
    final (ch, lv) = LevelRepository.parseLevelId(gs.currentLevel.id);
    final pad = LevelRepository.boardPadding(ch, lv);
    return (pad, boardSize - pad * 2);
  }

  Path _buildPath(List<Offset> points) {
    if (points.isEmpty) return Path();
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    if (points.length == 1) return path;

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

      if (i == 0) {
        path.lineTo(mid.dx, mid.dy);
      } else {
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant FreeDrawPainter oldDelegate) => true;
}
