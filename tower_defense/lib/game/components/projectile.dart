import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';

class Projectile extends PositionComponent {
  final Enemy? target;
  final Vector2? targetPosition;
  final int damage;
  final Color color;
  final double speed;
  final bool isSplash;
  final double splashRadius;
  final bool hasSlow;
  final double slowFactor;
  final List<Enemy> Function()? getAllEnemies;
  final void Function(Enemy, int)? onHit;
  final void Function(Vector2, double, int)? onSplashHit;

  Vector2 _velocity = Vector2.zero();
  bool _hasHit = false;

  static const double _tileSize = 40.0;

  Projectile({
    required Vector2 startPosition,
    this.target,
    this.targetPosition,
    required this.damage,
    required this.color,
    this.speed = 300.0,
    this.isSplash = false,
    this.splashRadius = 0,
    this.hasSlow = false,
    this.slowFactor = 1.0,
    this.getAllEnemies,
    this.onHit,
    this.onSplashHit,
  }) : super(
          position: startPosition,
          size: Vector2.all(8),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    _updateVelocity();
  }

  void _updateVelocity() {
    final dest = target?.worldCenter ?? targetPosition;
    if (dest == null) {
      removeFromParent();
      return;
    }
    final delta = dest - position;
    if (delta.length > 0) {
      _velocity = delta.normalized() * speed;
    }
  }

  @override
  void update(double dt) {
    if (_hasHit) return;

    if (target != null && !target!.isActive) {
      removeFromParent();
      return;
    }

    _updateVelocity();
    position += _velocity * dt;

    final dest = target?.worldCenter ?? targetPosition;
    if (dest != null) {
      final distToTarget = (dest - position).length;
      if (distToTarget < 10) {
        _hitTarget(dest);
      }
    }
  }

  void _hitTarget(Vector2 hitPos) {
    if (_hasHit) return;
    _hasHit = true;

    if (isSplash) {
      final splashWorldRadius = splashRadius * _tileSize;
      final enemies = getAllEnemies?.call() ?? [];
      for (final enemy in enemies) {
        if (!enemy.isActive) continue;
        final dist = (enemy.worldCenter - hitPos).length;
        if (dist <= splashWorldRadius) {
          enemy.takeDamage(damage);
          if (hasSlow) {
            enemy.applySlow(slowFactor, 1.5);
          }
        }
      }
      onSplashHit?.call(hitPos, splashWorldRadius, damage);
    } else {
      if (target != null && target!.isActive) {
        target!.takeDamage(damage);
        if (hasSlow) {
          target!.applySlow(slowFactor, 1.5);
        }
        onHit?.call(target!, damage);
      }
    }

    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = color,
    );
  }
}
