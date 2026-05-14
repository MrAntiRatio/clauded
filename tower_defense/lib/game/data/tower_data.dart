import 'dart:ui';

enum TowerType { archer, cannon, mage }

class TowerLevel {
  final int damage;
  final double range;
  final double fireRate;
  final int cost;
  final int upgradeCost;
  final Color color;

  const TowerLevel({
    required this.damage,
    required this.range,
    required this.fireRate,
    required this.cost,
    required this.upgradeCost,
    required this.color,
  });
}

class TowerData {
  final TowerType type;
  final String name;
  final List<TowerLevel> levels;
  final bool hasSplash;
  final double splashRadius;
  final bool hasSlowEffect;
  final double slowFactor;

  const TowerData({
    required this.type,
    required this.name,
    required this.levels,
    this.hasSplash = false,
    this.splashRadius = 0,
    this.hasSlowEffect = false,
    this.slowFactor = 1.0,
  });

  TowerLevel get baseLevel => levels[0];
}

const archerTower = TowerData(
  type: TowerType.archer,
  name: 'Archer',
  levels: [
    TowerLevel(damage: 15, range: 3.0, fireRate: 1.2, cost: 50, upgradeCost: 75, color: Color(0xFF8BC34A)),
    TowerLevel(damage: 25, range: 3.5, fireRate: 1.5, cost: 50, upgradeCost: 120, color: Color(0xFF558B2F)),
    TowerLevel(damage: 40, range: 4.0, fireRate: 2.0, cost: 50, upgradeCost: 0, color: Color(0xFF33691E)),
  ],
);

const cannonTower = TowerData(
  type: TowerType.cannon,
  name: 'Cannon',
  levels: [
    TowerLevel(damage: 40, range: 2.5, fireRate: 0.5, cost: 100, upgradeCost: 150, color: Color(0xFF9E9E9E)),
    TowerLevel(damage: 70, range: 3.0, fireRate: 0.7, cost: 100, upgradeCost: 200, color: Color(0xFF616161)),
    TowerLevel(damage: 110, range: 3.5, fireRate: 0.9, cost: 100, upgradeCost: 0, color: Color(0xFF212121)),
  ],
  hasSplash: true,
  splashRadius: 1.5,
);

const mageTower = TowerData(
  type: TowerType.mage,
  name: 'Mage',
  levels: [
    TowerLevel(damage: 20, range: 3.0, fireRate: 0.8, cost: 125, upgradeCost: 175, color: Color(0xFF9C27B0)),
    TowerLevel(damage: 35, range: 3.5, fireRate: 1.0, cost: 125, upgradeCost: 250, color: Color(0xFF6A1B9A)),
    TowerLevel(damage: 55, range: 4.0, fireRate: 1.2, cost: 125, upgradeCost: 0, color: Color(0xFF4A148C)),
  ],
  hasSlowEffect: true,
  slowFactor: 0.5,
);

const allTowers = [archerTower, cannonTower, mageTower];

TowerData towerDataFor(TowerType type) {
  return allTowers.firstWhere((t) => t.type == type);
}
