import 'package:flame/components.dart';
import '../data/level_data.dart';
import '../data/enemy_data.dart';
import 'enemy.dart';

class WaveManager extends Component {
  final LevelData levelData;
  final void Function(Enemy) onEnemySpawned;
  final void Function() onWaveComplete;
  final void Function() onAllWavesComplete;

  int _currentWave = 0;
  bool _waveInProgress = false;
  bool _allWavesDone = false;

  double _spawnTimer = 0;
  int _spawnIndex = 0;
  List<_SpawnEntry> _spawnQueue = [];
  int _activeEnemyCount = 0;

  double _wavePauseTimer = 0;
  static const double wavePauseDuration = 5.0;

  bool get allWavesDone => _allWavesDone;
  int get currentWave => _currentWave;
  int get totalWaves => levelData.waves.length;

  WaveManager({
    required this.levelData,
    required this.onEnemySpawned,
    required this.onWaveComplete,
    required this.onAllWavesComplete,
  });

  void startWaves() {
    _startNextWave();
  }

  void _startNextWave() {
    if (_currentWave >= levelData.waves.length) return;
    final waveConfig = levelData.waves[_currentWave];
    _spawnQueue = _buildSpawnQueue(waveConfig);
    _spawnIndex = 0;
    _spawnTimer = 0;
    _waveInProgress = true;
    _activeEnemyCount = 0;
    _currentWave++;
  }

  List<_SpawnEntry> _buildSpawnQueue(WaveConfig config) {
    final queue = <_SpawnEntry>[];
    for (final spawn in config.spawns) {
      for (int i = 0; i < spawn.count; i++) {
        queue.add(_SpawnEntry(
          type: spawn.type,
          hpMultiplier: spawn.hpMultiplier,
          speedMultiplier: spawn.speedMultiplier,
          interval: config.spawnInterval,
        ));
      }
    }
    queue.shuffle();
    return queue;
  }

  @override
  void update(double dt) {
    if (_allWavesDone) return;

    if (!_waveInProgress) {
      _wavePauseTimer += dt;
      if (_wavePauseTimer >= wavePauseDuration && _currentWave < levelData.waves.length) {
        _wavePauseTimer = 0;
        _startNextWave();
      }
      return;
    }

    _spawnTimer += dt;
    while (_spawnIndex < _spawnQueue.length) {
      final entry = _spawnQueue[_spawnIndex];
      if (_spawnTimer < entry.interval) break;
      _spawnTimer -= entry.interval;
      _spawnEnemy(entry);
      _spawnIndex++;
    }
  }

  void _spawnEnemy(_SpawnEntry entry) {
    _activeEnemyCount++;
    final data = enemyDataFor(entry.type);
    final enemy = Enemy(
      data: data,
      path: levelData.pathCells,
      hpMultiplier: entry.hpMultiplier,
      speedMultiplier: entry.speedMultiplier,
      onReachedEnd: (e) {
        _activeEnemyCount--;
        _checkWaveComplete();
      },
      onDied: (e, gold) {
        _activeEnemyCount--;
        _checkWaveComplete();
      },
    );
    onEnemySpawned(enemy);
  }

  void _checkWaveComplete() {
    if (!_waveInProgress) return;
    if (_spawnIndex < _spawnQueue.length) return;
    if (_activeEnemyCount > 0) return;

    _waveInProgress = false;
    onWaveComplete();

    if (_currentWave >= levelData.waves.length) {
      _allWavesDone = true;
      onAllWavesComplete();
    } else {
      _wavePauseTimer = 0;
    }
  }

  double get nextWaveCountdown =>
      _waveInProgress ? 0 : (wavePauseDuration - _wavePauseTimer).clamp(0, wavePauseDuration);

  bool get hasActiveWave => _waveInProgress;
}

class _SpawnEntry {
  final EnemyType type;
  final double hpMultiplier;
  final double speedMultiplier;
  final double interval;

  _SpawnEntry({
    required this.type,
    required this.hpMultiplier,
    required this.speedMultiplier,
    required this.interval,
  });
}
