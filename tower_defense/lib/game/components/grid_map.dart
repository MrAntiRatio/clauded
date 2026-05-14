import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../data/level_data.dart';
import 'tower_component.dart';

class GridMap extends PositionComponent with TapCallbacks {
  final LevelData levelData;
  final void Function(Vector2 cell) onCellTapped;
  final Map<String, TowerComponent> towers = {};

  static const int cols = 10;
  static const int rows = 18;
  static const double tileSize = 40.0;

  late Set<String> _pathCells;
  String? _selectedCell;

  GridMap({
    required this.levelData,
    required this.onCellTapped,
  }) : super(
          size: Vector2(cols * tileSize, rows * tileSize),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    _pathCells = levelData.pathCells.map(_cellKey).toSet();
  }

  static String _cellKey(Vector2 cell) => '${cell.x.toInt()},${cell.y.toInt()}';

  bool isPathCell(Vector2 cell) => _pathCells.contains(_cellKey(cell));
  bool hasTower(Vector2 cell) => towers.containsKey(_cellKey(cell));
  bool isPlaceable(Vector2 cell) =>
      !isPathCell(cell) &&
      !hasTower(cell) &&
      !levelData.blockedCells.contains(_cellKey(cell)) &&
      cell.x >= 0 &&
      cell.x < cols &&
      cell.y >= 0 &&
      cell.y < rows;

  void placeTower(TowerComponent tower) {
    towers[_cellKey(tower.gridCell)] = tower;
    add(tower);
  }

  TowerComponent? getTower(Vector2 cell) => towers[_cellKey(cell)];

  @override
  void onTapDown(TapDownEvent event) {
    final localPos = event.localPosition;
    final col = (localPos.x / tileSize).floor();
    final row = (localPos.y / tileSize).floor();
    if (col >= 0 && col < cols && row >= 0 && row < rows) {
      final cell = Vector2(col.toDouble(), row.toDouble());
      _selectedCell = _cellKey(cell);
      onCellTapped(cell);
    }
  }

  @override
  void render(Canvas canvas) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final cell = Vector2(col.toDouble(), row.toDouble());
        final key = _cellKey(cell);
        final rect = Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);

        Color tileColor;
        if (_pathCells.contains(key)) {
          tileColor = const Color(0xFFD2B48C);
        } else if (levelData.blockedCells.contains(key)) {
          tileColor = const Color(0xFF424242);
        } else {
          tileColor = (col + row) % 2 == 0
              ? const Color(0xFF388E3C)
              : const Color(0xFF2E7D32);
        }

        canvas.drawRect(rect, Paint()..color = tileColor);
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.black26
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );

        if (_selectedCell == key && !_pathCells.contains(key)) {
          canvas.drawRect(rect, Paint()..color = Colors.yellow.withOpacity(0.3));
          canvas.drawRect(
            rect,
            Paint()
              ..color = Colors.yellow
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    _renderPathArrows(canvas);
    super.render(canvas);
  }

  void _renderPathArrows(Canvas canvas) {
    final arrowPaint = Paint()
      ..color = Colors.brown.shade900.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < levelData.pathCells.length - 1; i++) {
      final from = levelData.pathCells[i];
      final to = levelData.pathCells[i + 1];

      final midX = (from.x + to.x) / 2 * tileSize + tileSize / 2;
      final midY = (from.y + to.y) / 2 * tileSize + tileSize / 2;
      final dx = (to.x - from.x).toDouble();
      final dy = (to.y - from.y).toDouble();
      final angle = math.atan2(dy, dx);

      canvas.save();
      canvas.translate(midX, midY);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(-5, -4)
        ..lineTo(5, 0)
        ..lineTo(-5, 4)
        ..close();
      canvas.drawPath(path, arrowPaint);
      canvas.restore();
    }
  }
}
