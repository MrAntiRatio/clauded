import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/enemy.dart';
import 'components/grid_map.dart';
import 'components/projectile.dart';
import 'components/tower_component.dart';
import 'components/wave_manager.dart';
import 'data/level_data.dart';
import 'data/tower_data.dart';
import 'hud/game_hud.dart';

enum GameStatus { playing, paused, won, lost }

class TowerDefenseGame extends FlameGame {
  final LevelData levelData;
  final int initialLives;
  final int initialGold;

  final void Function(int gold) onGoldChanged;
  final void Function(int lives) onLivesChanged;
  final void Function(int wave, int total) onWaveChanged;
  final void Function() onWon;
  final void Function() onLost;
  final void Function(Vector2 cell) onCellTapped;

  GameStatus status = GameStatus.playing;
  int _gold;
  int _lives;

  static const double hudHeight = GameHud.hudHeight;
  static const double tileSize = 40.0;

  late GridMap _gridMap;
  late WaveManager _waveManager;
  late GameHud _hud;

  final List<Enemy> _activeEnemies = [];
  bool _pendingWinCheck = false;

  TowerDefenseGame({
    required this.levelData,
    required this.initialLives,
    required this.initialGold,
    required this.onGoldChanged,
    required this.onLivesChanged,
    required this.onWaveChanged,
    required this.onWon,
    required this.onLost,
    required this.onCellTapped,
  })  : _gold = initialGold,
        _lives = initialLives;

  @override
  Color backgroundColor() => const Color(0xFF1B5E20);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    _gridMap = GridMap(
      levelData: levelData,
      onCellTapped: (cell) {
        if (status != GameStatus.playing) return;
        onCellTapped(cell);
      },
    );

    _waveManager = WaveManager(
      levelData: levelData,
      onEnemySpawned: _receiveEnemy,
      onWaveComplete: () {
        _updateHud();
        onWaveChanged(_waveManager.currentWave, _waveManager.totalWaves);
      },
      onAllWavesComplete: _handleAllWavesComplete,
    );

    _hud = GameHud(
      lives: _lives,
      gold: _gold,
      currentWave: 0,
      totalWaves: _waveManager.totalWaves,
      nextWaveCountdown: 0,
      waveInProgress: false,
    );

    camera.viewfinder.visibleGameSize = Vector2(
      GridMap.cols * tileSize,
      GridMap.rows * tileSize + hudHeight,
    );

    world.add(_gridMap);
    world.add(_waveManager);
    _gridMap.position = Vector2(0, hudHeight);
    camera.viewport.add(_HudOverlay(hud: _hud));

    _waveManager.startWaves();
  }

  // WaveManager hands us an enemy whose callbacks are already wired for wave
  // tracking. We replace those callbacks with wrappers that also handle
  // gold/lives, then chain back to the originals for wave-completion counting.
  void _receiveEnemy(Enemy enemy) {
    final waveOnDied = enemy.onDied;
    final waveOnReachedEnd = enemy.onReachedEnd;

    enemy.onDied = (e, gold) {
      _activeEnemies.remove(e);
      _grantGold(gold);
      waveOnDied(e, gold);
      _checkPendingWin();
    };

    enemy.onReachedEnd = (e) {
      _activeEnemies.remove(e);
      _subtractLife();
      waveOnReachedEnd(e);
      _checkPendingWin();
    };

    _activeEnemies.add(enemy);
    _gridMap.add(enemy);
  }

  void _addProjectile(Projectile projectile) {
    _gridMap.add(projectile);
  }

  void _grantGold(int amount) {
    _gold += amount;
    onGoldChanged(_gold);
    _updateHud();
  }

  void _subtractLife() {
    if (status != GameStatus.playing) return;
    _lives = (_lives - 1).clamp(0, 999);
    onLivesChanged(_lives);
    _updateHud();
    if (_lives <= 0) {
      status = GameStatus.lost;
      onLost();
    }
  }

  void _handleAllWavesComplete() {
    _pendingWinCheck = true;
    _checkPendingWin();
  }

  void _checkPendingWin() {
    if (!_pendingWinCheck) return;
    if (_activeEnemies.isEmpty) {
      _pendingWinCheck = false;
      if (status == GameStatus.playing) {
        status = GameStatus.won;
        onWon();
      }
    }
  }

  void placeTower(Vector2 cell, TowerType type) {
    if (status != GameStatus.playing) return;
    if (!_gridMap.isPlaceable(cell)) return;

    final data = towerDataFor(type);
    final cost = data.baseLevel.cost;
    if (_gold < cost) return;

    _gold -= cost;
    onGoldChanged(_gold);

    final tower = TowerComponent(
      type: type,
      gridCell: cell,
      level: 0,
      getEnemies: () => List<Enemy>.unmodifiable(_activeEnemies),
      spawnProjectile: _addProjectile,
    );
    _gridMap.placeTower(tower);
    _updateHud();
  }

  bool upgradeTower(Vector2 cell) {
    if (status != GameStatus.playing) return false;
    final tower = _gridMap.getTower(cell);
    if (tower == null || !tower.canUpgrade) return false;

    final cost = tower.upgradeCost;
    if (_gold < cost) return false;

    _gold -= cost;
    onGoldChanged(_gold);
    tower.upgrade();
    _updateHud();
    return true;
  }

  bool canPlaceTower(Vector2 cell) => _gridMap.isPlaceable(cell);
  TowerComponent? getTowerAt(Vector2 cell) => _gridMap.getTower(cell);

  void gainExtraLife() {
    _lives++;
    onLivesChanged(_lives);
    _updateHud();
  }

  @override
  void update(double dt) {
    if (status == GameStatus.paused || status == GameStatus.won || status == GameStatus.lost) return;
    super.update(dt);
    _updateHud();
  }

  void _updateHud() {
    _hud.lives = _lives;
    _hud.gold = _gold;
    _hud.currentWave = _waveManager.currentWave;
    _hud.totalWaves = _waveManager.totalWaves;
    _hud.nextWaveCountdown = _waveManager.nextWaveCountdown;
    _hud.waveInProgress = _waveManager.hasActiveWave;
  }

  int get currentGold => _gold;
  int get currentLives => _lives;
  int get currentWave => _waveManager.currentWave;
}

class _HudOverlay extends PositionComponent {
  final GameHud hud;

  _HudOverlay({required this.hud})
      : super(position: Vector2.zero(), anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    hud.render(canvas);
  }

  @override
  void update(double dt) {}
}
