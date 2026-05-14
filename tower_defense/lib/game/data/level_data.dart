import 'package:flame/components.dart';
import 'enemy_data.dart';

class WaveConfig {
  final List<WaveSpawn> spawns;
  final double spawnInterval;

  const WaveConfig({required this.spawns, required this.spawnInterval});
}

class WaveSpawn {
  final EnemyType type;
  final int count;
  final double hpMultiplier;
  final double speedMultiplier;

  const WaveSpawn({
    required this.type,
    required this.count,
    this.hpMultiplier = 1.0,
    this.speedMultiplier = 1.0,
  });
}

class LevelData {
  final int id;
  final String name;
  final List<Vector2> pathCells;
  final List<WaveConfig> waves;
  final Set<String> blockedCells;

  const LevelData({
    required this.id,
    required this.name,
    required this.pathCells,
    required this.waves,
    required this.blockedCells,
  });

  Vector2 get spawnCell => pathCells.first;
  Vector2 get exitCell => pathCells.last;
}

// Grid: 10 columns (x 0-9), 18 rows (y 0-17). Path is a list of sequential grid cells.
// Blocked cells (neither path nor placeable) are the decorative border.

final level1 = LevelData(
  id: 1,
  name: 'Forest Pass',
  pathCells: [
    Vector2(0, 3), Vector2(1, 3), Vector2(2, 3), Vector2(3, 3),
    Vector2(3, 4), Vector2(3, 5), Vector2(3, 6), Vector2(3, 7),
    Vector2(4, 7), Vector2(5, 7), Vector2(6, 7),
    Vector2(6, 8), Vector2(6, 9), Vector2(6, 10),
    Vector2(5, 10), Vector2(4, 10), Vector2(3, 10),
    Vector2(3, 11), Vector2(3, 12), Vector2(3, 13),
    Vector2(4, 13), Vector2(5, 13), Vector2(6, 13), Vector2(7, 13),
    Vector2(7, 14), Vector2(7, 15), Vector2(7, 16), Vector2(7, 17),
  ],
  blockedCells: {},
  waves: [
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 6)], spawnInterval: 1.5),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 8)], spawnInterval: 1.3),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 6), WaveSpawn(type: EnemyType.fast, count: 3)], spawnInterval: 1.2),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 8), WaveSpawn(type: EnemyType.fast, count: 4)], spawnInterval: 1.1),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 10), WaveSpawn(type: EnemyType.fast, count: 5)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 10), WaveSpawn(type: EnemyType.tank, count: 1)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 12), WaveSpawn(type: EnemyType.fast, count: 6)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 10), WaveSpawn(type: EnemyType.tank, count: 2)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14), WaveSpawn(type: EnemyType.fast, count: 6), WaveSpawn(type: EnemyType.tank, count: 1)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 12), WaveSpawn(type: EnemyType.fast, count: 8), WaveSpawn(type: EnemyType.tank, count: 2)], spawnInterval: 0.8),
  ],
);

final level2 = LevelData(
  id: 2,
  name: 'Stone Bridge',
  pathCells: [
    Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
    Vector2(2, 2), Vector2(2, 3), Vector2(2, 4), Vector2(2, 5),
    Vector2(3, 5), Vector2(4, 5), Vector2(5, 5), Vector2(6, 5),
    Vector2(6, 6), Vector2(6, 7), Vector2(6, 8), Vector2(6, 9),
    Vector2(5, 9), Vector2(4, 9), Vector2(3, 9),
    Vector2(3, 10), Vector2(3, 11), Vector2(3, 12),
    Vector2(4, 12), Vector2(5, 12), Vector2(6, 12), Vector2(7, 12), Vector2(8, 12),
    Vector2(8, 13), Vector2(8, 14), Vector2(8, 15), Vector2(8, 16), Vector2(8, 17),
  ],
  blockedCells: {},
  waves: [
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 8, hpMultiplier: 1.1)], spawnInterval: 1.4),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 8, hpMultiplier: 1.1), WaveSpawn(type: EnemyType.fast, count: 4)], spawnInterval: 1.2),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 8, speedMultiplier: 1.1)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 10, hpMultiplier: 1.2), WaveSpawn(type: EnemyType.tank, count: 1)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 10, hpMultiplier: 1.2), WaveSpawn(type: EnemyType.fast, count: 6)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 3, hpMultiplier: 1.1)], spawnInterval: 2.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14, hpMultiplier: 1.2), WaveSpawn(type: EnemyType.fast, count: 6)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 12, hpMultiplier: 1.3), WaveSpawn(type: EnemyType.tank, count: 2)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 12, speedMultiplier: 1.2), WaveSpawn(type: EnemyType.tank, count: 2)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 15, hpMultiplier: 1.3), WaveSpawn(type: EnemyType.fast, count: 8), WaveSpawn(type: EnemyType.tank, count: 3)], spawnInterval: 0.7),
  ],
);

final level3 = LevelData(
  id: 3,
  name: 'Desert Ruins',
  pathCells: [
    Vector2(0, 8),
    Vector2(1, 8), Vector2(2, 8),
    Vector2(2, 7), Vector2(2, 6), Vector2(2, 5), Vector2(2, 4), Vector2(2, 3),
    Vector2(3, 3), Vector2(4, 3), Vector2(5, 3), Vector2(6, 3), Vector2(7, 3),
    Vector2(7, 4), Vector2(7, 5), Vector2(7, 6), Vector2(7, 7), Vector2(7, 8), Vector2(7, 9),
    Vector2(6, 9), Vector2(5, 9), Vector2(4, 9),
    Vector2(4, 10), Vector2(4, 11), Vector2(4, 12), Vector2(4, 13),
    Vector2(5, 13), Vector2(6, 13), Vector2(7, 13), Vector2(8, 13), Vector2(9, 13),
  ],
  blockedCells: {},
  waves: [
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 10, hpMultiplier: 1.2)], spawnInterval: 1.2),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 8, speedMultiplier: 1.1)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 12, hpMultiplier: 1.2), WaveSpawn(type: EnemyType.fast, count: 6)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 3, hpMultiplier: 1.2)], spawnInterval: 1.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14, hpMultiplier: 1.3), WaveSpawn(type: EnemyType.fast, count: 7)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 10, speedMultiplier: 1.2), WaveSpawn(type: EnemyType.tank, count: 2)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 16, hpMultiplier: 1.3), WaveSpawn(type: EnemyType.tank, count: 3)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14, hpMultiplier: 1.4), WaveSpawn(type: EnemyType.fast, count: 10)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 5, hpMultiplier: 1.3)], spawnInterval: 1.5),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 16, hpMultiplier: 1.5), WaveSpawn(type: EnemyType.fast, count: 10), WaveSpawn(type: EnemyType.tank, count: 4)], spawnInterval: 0.6),
  ],
);

final level4 = LevelData(
  id: 4,
  name: 'Ice Caverns',
  pathCells: [
    Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0), Vector2(4, 0),
    Vector2(4, 1), Vector2(4, 2), Vector2(4, 3),
    Vector2(3, 3), Vector2(2, 3), Vector2(1, 3),
    Vector2(1, 4), Vector2(1, 5), Vector2(1, 6), Vector2(1, 7), Vector2(1, 8),
    Vector2(2, 8), Vector2(3, 8), Vector2(4, 8), Vector2(5, 8), Vector2(6, 8),
    Vector2(6, 9), Vector2(6, 10), Vector2(6, 11), Vector2(6, 12),
    Vector2(7, 12), Vector2(8, 12), Vector2(9, 12),
    Vector2(9, 13), Vector2(9, 14), Vector2(9, 15), Vector2(9, 16), Vector2(9, 17),
  ],
  blockedCells: {},
  waves: [
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 12, hpMultiplier: 1.3)], spawnInterval: 1.1),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 10, speedMultiplier: 1.2)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 4, hpMultiplier: 1.3)], spawnInterval: 1.7),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14, hpMultiplier: 1.4), WaveSpawn(type: EnemyType.fast, count: 8)], spawnInterval: 0.9),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 12, speedMultiplier: 1.3), WaveSpawn(type: EnemyType.tank, count: 3)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 18, hpMultiplier: 1.4), WaveSpawn(type: EnemyType.tank, count: 3)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 15, speedMultiplier: 1.3), WaveSpawn(type: EnemyType.basic, count: 10, hpMultiplier: 1.4)], spawnInterval: 0.7),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 6, hpMultiplier: 1.4)], spawnInterval: 1.4),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 16, hpMultiplier: 1.5), WaveSpawn(type: EnemyType.fast, count: 12, speedMultiplier: 1.3)], spawnInterval: 0.7),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 18, hpMultiplier: 1.6), WaveSpawn(type: EnemyType.fast, count: 12, speedMultiplier: 1.4), WaveSpawn(type: EnemyType.tank, count: 5)], spawnInterval: 0.5),
  ],
);

final level5 = LevelData(
  id: 5,
  name: 'Dark Fortress',
  pathCells: [
    Vector2(0, 9),
    Vector2(1, 9), Vector2(2, 9),
    Vector2(2, 8), Vector2(2, 7), Vector2(2, 6), Vector2(2, 5), Vector2(2, 4), Vector2(2, 3), Vector2(2, 2),
    Vector2(3, 2), Vector2(4, 2), Vector2(5, 2), Vector2(6, 2), Vector2(7, 2),
    Vector2(7, 3), Vector2(7, 4), Vector2(7, 5), Vector2(7, 6), Vector2(7, 7), Vector2(7, 8), Vector2(7, 9), Vector2(7, 10), Vector2(7, 11),
    Vector2(6, 11), Vector2(5, 11), Vector2(4, 11), Vector2(3, 11),
    Vector2(3, 12), Vector2(3, 13), Vector2(3, 14), Vector2(3, 15),
    Vector2(4, 15), Vector2(5, 15), Vector2(6, 15), Vector2(7, 15), Vector2(8, 15), Vector2(9, 15),
  ],
  blockedCells: {},
  waves: [
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14, hpMultiplier: 1.5)], spawnInterval: 1.0),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 12, speedMultiplier: 1.3)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 14, hpMultiplier: 1.6), WaveSpawn(type: EnemyType.fast, count: 8)], spawnInterval: 0.8),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 5, hpMultiplier: 1.5)], spawnInterval: 1.5),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 16, hpMultiplier: 1.6), WaveSpawn(type: EnemyType.fast, count: 12, speedMultiplier: 1.3)], spawnInterval: 0.7),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.fast, count: 16, speedMultiplier: 1.4), WaveSpawn(type: EnemyType.tank, count: 4, hpMultiplier: 1.5)], spawnInterval: 0.7),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 20, hpMultiplier: 1.7), WaveSpawn(type: EnemyType.tank, count: 5)], spawnInterval: 0.7),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.tank, count: 8, hpMultiplier: 1.6)], spawnInterval: 1.2),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 18, hpMultiplier: 1.8), WaveSpawn(type: EnemyType.fast, count: 15, speedMultiplier: 1.5)], spawnInterval: 0.6),
    WaveConfig(spawns: [WaveSpawn(type: EnemyType.basic, count: 20, hpMultiplier: 2.0), WaveSpawn(type: EnemyType.fast, count: 16, speedMultiplier: 1.5), WaveSpawn(type: EnemyType.tank, count: 8, hpMultiplier: 1.8)], spawnInterval: 0.5),
  ],
);

final allLevels = [level1, level2, level3, level4, level5];

LevelData levelDataFor(int levelId) {
  return allLevels.firstWhere((l) => l.id == levelId);
}
