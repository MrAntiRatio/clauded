import 'dart:ui';

enum EnemyType { basic, fast, tank }

class EnemyData {
  final EnemyType type;
  final String name;
  final int baseHp;
  final double baseSpeed;
  final int goldReward;
  final Color color;
  final double size;

  const EnemyData({
    required this.type,
    required this.name,
    required this.baseHp,
    required this.baseSpeed,
    required this.goldReward,
    required this.color,
    required this.size,
  });
}

const basicEnemy = EnemyData(
  type: EnemyType.basic,
  name: 'Basic',
  baseHp: 80,
  baseSpeed: 60.0,
  goldReward: 10,
  color: Color(0xFFE53935),
  size: 0.6,
);

const fastEnemy = EnemyData(
  type: EnemyType.fast,
  name: 'Fast',
  baseHp: 40,
  baseSpeed: 120.0,
  goldReward: 15,
  color: Color(0xFFFF9800),
  size: 0.45,
);

const tankEnemy = EnemyData(
  type: EnemyType.tank,
  name: 'Tank',
  baseHp: 320,
  baseSpeed: 24.0,
  goldReward: 30,
  color: Color(0xFF5D4037),
  size: 0.8,
);

const allEnemies = [basicEnemy, fastEnemy, tankEnemy];

EnemyData enemyDataFor(EnemyType type) {
  return allEnemies.firstWhere((e) => e.type == type);
}
