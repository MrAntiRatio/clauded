import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../data/enemy_data.dart';

class Enemy extends PositionComponent {
  final EnemyData data;
  final List<Vector2> path;
  final double hpMultiplier;
  final double speedMultiplier;

  // Called when enemy reaches the path exit (alive)
  void Function(Enemy enemy) onReachedEnd;
  // Called when enemy is killed; int is gold reward
  void Function(Enemy enemy, int goldReward) onDied;

  late int _maxHp;
  late int _currentHp;
  late double _speed;
  double _slowTimer = 0;
  double _slowFactor = 1.0;

  int _pathIndex = 0;
  Vector2 _position = Vector2.zero();
  bool _isDead = false;
  bool _reachedEnd = false;

  bool get isDead => _isDead;
  bool get reachedEnd => _reachedEnd;
  bool get isActive => !_isDead && !_reachedEnd;
  int get currentHp => _currentHp;
  int get maxHp => _maxHp;

  double _pathProgress = 0.0;
  double get pathProgress => _pathProgress;

  static const double tileSize = 40.0;

  Enemy({
    required this.data,
    required this.path,
    required this.hpMultiplier,
    required this.speedMultiplier,
    required this.onReachedEnd,
    required this.onDied,
  }) : super(size: Vector2.all(data.size * tileSize)) {
    _maxHp = (data.baseHp * hpMultiplier).round();
    _currentHp = _maxHp;
    _speed = data.baseSpeed * speedMultiplier;
  }

  @override
  Future<void> onLoad() async {
    _position = _tileToWorld(path[0]);
    position = _position - size / 2;
    anchor = Anchor.topLeft;
  }

  Vector2 _tileToWorld(Vector2 tile) =>
      Vector2(tile.x * tileSize + tileSize / 2, tile.y * tileSize + tileSize / 2);

  @override
  void update(double dt) {
    if (!isActive) return;

    if (_slowTimer > 0) {
      _slowTimer -= dt;
      if (_slowTimer <= 0) _slowFactor = 1.0;
    }

    final effectiveSpeed = _speed * _slowFactor;
    double remaining = effectiveSpeed * dt;

    while (remaining > 0 && _pathIndex < path.length - 1) {
      final target = _tileToWorld(path[_pathIndex + 1]);
      final delta = target - _position;
      final distance = delta.length;

      if (distance <= remaining) {
        remaining -= distance;
        _position.setFrom(target);
        _pathIndex++;
      } else {
        _position += delta.normalized() * remaining;
        remaining = 0;
      }
    }

    _pathProgress = path.length > 1 ? _pathIndex / (path.length - 1).toDouble() : 1.0;
    position = _position - size / 2;

    if (_pathIndex >= path.length - 1) {
      _reachedEnd = true;
      removeFromParent();
      onReachedEnd(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = data.color;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRoundRect(rect, const Radius.circular(4), paint);

    if (_currentHp < _maxHp) {
      const barHeight = 4.0;
      const barY = -6.0;
      canvas.drawRect(
        Rect.fromLTWH(0, barY, size.x, barHeight),
        Paint()..color = Colors.red,
      );
      final hpRatio = _currentHp / _maxHp;
      canvas.drawRect(
        Rect.fromLTWH(0, barY, size.x * hpRatio, barHeight),
        Paint()..color = Colors.green,
      );
    }

    if (_slowTimer > 0) {
      canvas.drawRoundRect(
        rect,
        const Radius.circular(4),
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void takeDamage(int damage) {
    if (_isDead) return;
    _currentHp -= damage;
    if (_currentHp <= 0) {
      _currentHp = 0;
      _isDead = true;
      removeFromParent();
      onDied(this, data.goldReward);
    }
  }

  void applySlow(double factor, double duration) {
    _slowFactor = min(_slowFactor, factor);
    _slowTimer = max(_slowTimer, duration);
  }

  Vector2 get worldCenter => _position;
}
