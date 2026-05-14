import 'package:riverpod/riverpod.dart';
import '../services/persistence_service.dart';

class PlayerState {
  final int gold;
  final int gems;
  final int lives;
  final List<int> unlockedLevels;
  final bool removeAdsPurchased;

  const PlayerState({
    required this.gold,
    required this.gems,
    required this.lives,
    required this.unlockedLevels,
    required this.removeAdsPurchased,
  });

  PlayerState copyWith({
    int? gold,
    int? gems,
    int? lives,
    List<int>? unlockedLevels,
    bool? removeAdsPurchased,
  }) {
    return PlayerState(
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      lives: lives ?? this.lives,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      removeAdsPurchased: removeAdsPurchased ?? this.removeAdsPurchased,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PersistenceService _persistence;

  PlayerNotifier(this._persistence)
      : super(PlayerState(
          gold: _persistence.gold,
          gems: _persistence.gems,
          lives: _persistence.lives,
          unlockedLevels: _persistence.unlockedLevels,
          removeAdsPurchased: _persistence.removeAdsPurchased,
        ));

  Future<void> addGold(int amount) async {
    final newGold = state.gold + amount;
    state = state.copyWith(gold: newGold);
    await _persistence.saveGold(newGold);
  }

  Future<bool> spendGold(int amount) async {
    if (state.gold < amount) return false;
    final newGold = state.gold - amount;
    state = state.copyWith(gold: newGold);
    await _persistence.saveGold(newGold);
    return true;
  }

  Future<void> addGems(int amount) async {
    final newGems = state.gems + amount;
    state = state.copyWith(gems: newGems);
    await _persistence.saveGems(newGems);
  }

  Future<bool> spendGems(int amount) async {
    if (state.gems < amount) return false;
    final newGems = state.gems - amount;
    state = state.copyWith(gems: newGems);
    await _persistence.saveGems(newGems);
    return true;
  }

  Future<void> loseLife() async {
    final newLives = (state.lives - 1).clamp(0, 999);
    state = state.copyWith(lives: newLives);
    await _persistence.saveLives(newLives);
  }

  Future<void> gainLife() async {
    final newLives = state.lives + 1;
    state = state.copyWith(lives: newLives);
    await _persistence.saveLives(newLives);
  }

  Future<void> resetLivesForGame() async {
    state = state.copyWith(lives: 20);
    await _persistence.saveLives(20);
  }

  Future<void> unlockLevel(int levelId) async {
    if (state.unlockedLevels.contains(levelId)) return;
    final updated = [...state.unlockedLevels, levelId];
    state = state.copyWith(unlockedLevels: updated);
    await _persistence.saveUnlockedLevels(updated);
  }

  Future<void> setRemoveAds() async {
    state = state.copyWith(removeAdsPurchased: true);
    await _persistence.saveRemoveAds(true);
  }

  bool isLevelUnlocked(int levelId) => state.unlockedLevels.contains(levelId);
}
