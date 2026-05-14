import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  PersistenceService._();
  static final instance = PersistenceService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyGold = 'gold';
  static const _keyGems = 'gems';
  static const _keyLives = 'lives';
  static const _keyUnlockedLevels = 'unlocked_levels';
  static const _keyRemoveAds = 'remove_ads';
  static const _keyLevelsCompleted = 'levels_completed';
  static const _keyInterstitialCount = 'interstitial_count';

  int get gold => _prefs.getInt(_keyGold) ?? 150;
  int get gems => _prefs.getInt(_keyGems) ?? 0;
  int get lives => _prefs.getInt(_keyLives) ?? 20;
  List<int> get unlockedLevels {
    final raw = _prefs.getStringList(_keyUnlockedLevels);
    if (raw == null) return [1];
    return raw.map(int.parse).toList();
  }

  bool get removeAdsPurchased => _prefs.getBool(_keyRemoveAds) ?? false;
  int get levelsCompleted => _prefs.getInt(_keyLevelsCompleted) ?? 0;
  int get interstitialCount => _prefs.getInt(_keyInterstitialCount) ?? 0;

  Future<void> saveGold(int value) => _prefs.setInt(_keyGold, value);
  Future<void> saveGems(int value) => _prefs.setInt(_keyGems, value);
  Future<void> saveLives(int value) => _prefs.setInt(_keyLives, value);

  Future<void> saveUnlockedLevels(List<int> levels) =>
      _prefs.setStringList(_keyUnlockedLevels, levels.map((e) => e.toString()).toList());

  Future<void> saveRemoveAds(bool value) => _prefs.setBool(_keyRemoveAds, value);

  Future<void> incrementLevelsCompleted() =>
      _prefs.setInt(_keyLevelsCompleted, levelsCompleted + 1);

  Future<void> incrementInterstitialCount() =>
      _prefs.setInt(_keyInterstitialCount, interstitialCount + 1);

  Future<void> resetInterstitialCount() =>
      _prefs.setInt(_keyInterstitialCount, 0);

  Future<void> resetForNewGame(int levelId) async {
    await saveLives(20);
  }
}
