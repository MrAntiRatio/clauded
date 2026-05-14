import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../data/tower_data.dart';
import 'enemy.dart';
import 'projectile.dart';

class TowerComponent extends PositionComponent {
  TowerType type;
  int level;
  final Vector2 gridCell;
  List<Enemy> Function() getEnemies;
  void Function(Projectile) spawnProjectile;

  double _fireCooldown = 0;

  static const double _tileSize = 40.0;

  TowerComponent({
    required this.type,
    required this.gridCell,
    required this.getEnemies,
    required this.spawnProjectile,
    this.level = 0,
  }) : super(
          position: Vector2(gridCell.x * _tileSize, gridCell.y * _tileSize),
          size: Vector2.all(_tileSize),
          anchor: Anchor.topLeft,
        );

  TowerData get towerData => towerDataFor(type);
  TowerLevel get currentLevel => towerData.levels[level];

  bool get canUpgrade => level < towerData.levels.length - 1;
  int get upgradeCost => canUpgrade ? towerData.levels[level].upgradeCost : 0;

  @override
  void update(double dt) {
    _fireCooldown = max(0, _fireCooldown - dt);
    if (_fireCooldown > 0) return;

    final target = _findTarget();
    if (target == null) return;

    _fireCooldown = 1.0 / currentLevel.fireRate;
    _fire(target);
  }

  Enemy? _findTarget() {
    final rangePixels = currentLevel.range * _tileSize;
    final center = position + size / 2;

    Enemy? bestTarget;
    double bestProgress = -1;

    for (final enemy in getEnemies()) {
      if (!enemy.isActive) continue;
      final dist = (enemy.worldCenter - center).length;
      if (dist <= rangePixels && enemy.pathProgress > bestProgress) {
        bestProgress = enemy.pathProgress;
        bestTarget = enemy;
      }
    }
    return bestTarget;
  }

  void _fire(Enemy target) {
    final data = towerData;
    final center = position + size / 2;

    Color projectileColor;
    switch (type) {
      case TowerType.archer:
        projectileColor = Colors.yellow;
      case TowerType.cannon:
        projectileColor = Colors.grey;
      case TowerType.mage:
        projectileColor = Colors.purple;
    }

    final projectile = Projectile(
      startPosition: center.clone(),
      target: data.hasSplash ? null : target,
      targetPosition: data.hasSplash ? target.worldCenter.clone() : null,
      damage: currentLevel.damage,
      color: projectileColor,
      speed: data.hasSplash ? 200.0 : 350.0,
      isSplash: data.hasSplash,
      splashRadius: data.splashRadius,
      hasSlow: data.hasSlowEffect,
      slowFactor: data.slowFactor,
      getAllEnemies: getEnemies,
    );
    spawnProjectile(projectile);
  }

  void upgrade() {
    if (canUpgrade) level++;
  }

  @override
  void render(Canvas canvas) {
    final data = towerData;
    final levelColor = data.levels[level].color;

    // Base platform
    final basePaint = Paint()..color = Colors.brown.shade700;
    canvas.drawRect(
      Rect.fromLTWH(4, 4, size.x - 8, size.y - 8),
      basePaint,
    );

    // Tower body
    final bodyPaint = Paint()..color = levelColor;
    switch (type) {
      case TowerType.archer:
        canvas.drawRect(
          Rect.fromLTWH(10, 8, size.x - 20, size.y - 16),
          bodyPaint,
        );
        // Battlements
        for (int i = 0; i < 3; i++) {
          canvas.drawRect(
            Rect.fromLTWH(8 + i * 10.0, 4, 7, 8),
            bodyPaint,
          );
        }
      case TowerType.cannon:
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          size.x / 2 - 8,
          bodyPaint,
        );
        // Cannon barrel
        canvas.drawRect(
          Rect.fromLTWH(size.x / 2 - 3, 6, 6, 14),
          Paint()..color = Colors.black54,
        );
      case TowerType.mage:
        // Tower body
        canvas.drawRect(
          Rect.fromLTWH(12, 10, size.x - 24, size.y - 14),
          bodyPaint,
        );
        // Pointed top
        final path = Path()
          ..moveTo(12, 10)
          ..lineTo(size.x / 2, 2)
          ..lineTo(size.x - 12, 10)
          ..close();
        canvas.drawPath(path, bodyPaint);
    }

    // Level indicator dots
    for (int i = 0; i <= level; i++) {
      canvas.drawCircle(
        Offset(8.0 + i * 8, size.y - 6),
        3,
        Paint()..color = Colors.yellow,
      );
    }
  }
}
