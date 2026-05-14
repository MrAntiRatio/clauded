import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../game/tower_defense_game.dart';
import '../game/data/level_data.dart';
import '../game/data/tower_data.dart';
import '../game/components/tower_component.dart';
import '../state/providers.dart';
import '../services/persistence_service.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;
  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late TowerDefenseGame _game;
  TowerType _selectedTower = TowerType.archer;
  Vector2? _selectedCell;
  TowerComponent? _towerAtSelected;

  // Mirrors game-internal currency shown in the bottom panel.
  int _displayGold = 0;

  @override
  void initState() {
    super.initState();
    final player = ref.read(playerNotifierProvider);
    _displayGold = player.gold;

    final level = levelDataFor(widget.levelId);

    _game = TowerDefenseGame(
      levelData: level,
      initialLives: player.lives,
      initialGold: player.gold,
      onGoldChanged: (g) {
        if (mounted) setState(() => _displayGold = g);
      },
      onLivesChanged: (l) {
        ref.read(playerNotifierProvider.notifier).loseLife();
      },
      onWaveChanged: (wave, total) {
        if (mounted) setState(() {});
      },
      onWon: _handleWin,
      onLost: _handleLose,
      onCellTapped: (cell) {
        if (!mounted) return;
        setState(() {
          _selectedCell = cell;
          _towerAtSelected = _game.getTowerAt(cell);
        });
      },
    );
  }

  void _handleWin() async {
    final notifier = ref.read(playerNotifierProvider.notifier);
    // Sync final gold back to persistent state by computing the net change.
    final storedGold = ref.read(playerNotifierProvider).gold;
    final gameFinalGold = _game.currentGold;
    if (gameFinalGold > storedGold) {
      await notifier.addGold(gameFinalGold - storedGold);
    } else if (gameFinalGold < storedGold) {
      await notifier.spendGold(storedGold - gameFinalGold);
    }
    await notifier.unlockLevel(widget.levelId + 1);
    await PersistenceService.instance.incrementLevelsCompleted();

    if (!mounted) return;
    context.go('/game-over', extra: {
      'levelId': widget.levelId,
      'wavesReached': _game.currentWave,
      'won': true,
    });
  }

  void _handleLose() {
    if (!mounted) return;
    context.go('/game-over', extra: {
      'levelId': widget.levelId,
      'wavesReached': _game.currentWave,
      'won': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GameWidget(game: _game),
            ),
            _TowerPanel(
              selectedType: _selectedTower,
              gold: _displayGold,
              selectedCell: _selectedCell,
              towerAtCell: _towerAtSelected,
              game: _game,
              onSelectTower: (type) => setState(() => _selectedTower = type),
              onPlaceTower: () {
                if (_selectedCell != null) {
                  _game.placeTower(_selectedCell!, _selectedTower);
                  setState(() {
                    _towerAtSelected = _game.getTowerAt(_selectedCell!);
                  });
                }
              },
              onUpgradeTower: () {
                if (_selectedCell != null) {
                  final upgraded = _game.upgradeTower(_selectedCell!);
                  if (upgraded) {
                    setState(() {
                      _towerAtSelected = _game.getTowerAt(_selectedCell!);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TowerPanel extends StatelessWidget {
  final TowerType selectedType;
  final int gold;
  final Vector2? selectedCell;
  final TowerComponent? towerAtCell;
  final TowerDefenseGame game;
  final void Function(TowerType) onSelectTower;
  final VoidCallback onPlaceTower;
  final VoidCallback onUpgradeTower;

  const _TowerPanel({
    required this.selectedType,
    required this.gold,
    required this.selectedCell,
    required this.towerAtCell,
    required this.game,
    required this.onSelectTower,
    required this.onPlaceTower,
    required this.onUpgradeTower,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: TowerType.values.map((type) {
              final data = towerDataFor(type);
              final cost = data.baseLevel.cost;
              return _TowerButton(
                type: type,
                cost: cost,
                canAfford: gold >= cost,
                selected: selectedType == type,
                onTap: () => onSelectTower(type),
              );
            }).toList(),
          ),
          if (selectedCell != null) ...[
            const SizedBox(height: 8),
            _ActionBar(
              cell: selectedCell!,
              towerAtCell: towerAtCell,
              gold: gold,
              selectedType: selectedType,
              game: game,
              onPlace: onPlaceTower,
              onUpgrade: onUpgradeTower,
            ),
          ],
        ],
      ),
    );
  }
}

class _TowerButton extends StatelessWidget {
  final TowerType type;
  final int cost;
  final bool canAfford;
  final bool selected;
  final VoidCallback onTap;

  const _TowerButton({
    required this.type,
    required this.cost,
    required this.canAfford,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const names = {TowerType.archer: 'Archer', TowerType.cannon: 'Cannon', TowerType.mage: 'Mage'};
    const icons = {
      TowerType.archer: Icons.person,
      TowerType.cannon: Icons.circle,
      TowerType.mage: Icons.auto_fix_high,
    };
    final colors = {
      TowerType.archer: Colors.green.shade400,
      TowerType.cannon: Colors.grey.shade400,
      TowerType.mage: Colors.purple.shade400,
    };

    final color = colors[type]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade700,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icons[type], color: canAfford ? color : Colors.grey.shade600, size: 24),
            const SizedBox(height: 2),
            Text(
              names[type]!,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, size: 10, color: canAfford ? Colors.amber : Colors.grey.shade600),
                const SizedBox(width: 2),
                Text(
                  '$cost',
                  style: TextStyle(color: canAfford ? Colors.amber : Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final Vector2 cell;
  final TowerComponent? towerAtCell;
  final int gold;
  final TowerType selectedType;
  final TowerDefenseGame game;
  final VoidCallback onPlace;
  final VoidCallback onUpgrade;

  const _ActionBar({
    required this.cell,
    required this.towerAtCell,
    required this.gold,
    required this.selectedType,
    required this.game,
    required this.onPlace,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    if (towerAtCell != null) {
      final tower = towerAtCell!;
      final canUpgrade = tower.canUpgrade;
      final upgradeCost = tower.upgradeCost;
      final canAfford = gold >= upgradeCost;
      return Row(
        children: [
          Expanded(
            child: Text(
              '${tower.towerData.name} (Lv ${tower.level + 1})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          if (canUpgrade)
            ElevatedButton.icon(
              onPressed: canAfford ? onUpgrade : null,
              icon: const Icon(Icons.upgrade, size: 16),
              label: Text('Upgrade ($upgradeCost g)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            )
          else
            const Text('MAX LEVEL', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      );
    }

    final isPlaceable = game.canPlaceTower(cell);
    if (!isPlaceable) {
      return const Text('Cannot place here', style: TextStyle(color: Colors.red));
    }

    final data = towerDataFor(selectedType);
    final cost = data.baseLevel.cost;
    final canAfford = gold >= cost;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Place ${data.name} at (${cell.x.toInt()},${cell.y.toInt()})',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton.icon(
          onPressed: canAfford ? onPlace : null,
          icon: const Icon(Icons.add, size: 16),
          label: Text('Place ($cost g)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
      ],
    );
  }
}
