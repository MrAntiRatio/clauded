// PRODUCTION CONFIGURATION:
// 1. Replace all test ad unit IDs below with real ad unit IDs from your AdMob console.
// 2. Replace the AdMob App ID in AndroidManifest.xml.
// 3. Remove test device IDs from RequestConfiguration.
// 4. Set RequestConfiguration.testDeviceIds to empty list [] in production builds.
//
// Test ad unit IDs (safe for development — never charge real users):
//   Banner:       ca-app-pub-3940256099942544/6300978111
//   Interstitial: ca-app-pub-3940256099942544/1033173712
//   Rewarded:     ca-app-pub-3940256099942544/5224354917

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final instance = AdService._();

  // TODO: Replace with real ad unit IDs from AdMob console before publishing.
  static const _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _bannerLoaded = false;
  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;

  bool get isBannerLoaded => _bannerLoaded;
  BannerAd? get bannerAd => _bannerLoaded ? _bannerAd : null;

  Future<void> loadBannerAd({VoidCallback? onLoaded}) async {
    _bannerAd?.dispose();
    _bannerLoaded = false;
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _bannerLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerLoaded = false;
        },
      ),
    );
    await _bannerAd!.load();
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialLoaded = false;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoaded = false;
        },
      ),
    );
  }

  Future<bool> showInterstitialAd() async {
    if (!_interstitialLoaded || _interstitialAd == null) return false;
    await _interstitialAd!.show();
    return true;
  }

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _rewardedLoaded = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _rewardedLoaded = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedLoaded = false;
        },
      ),
    );
  }

  Future<bool> showRewardedAd({required void Function(RewardItem reward) onUserEarnedReward}) async {
    if (!_rewardedLoaded || _rewardedAd == null) return false;
    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onUserEarnedReward(reward);
    });
    return true;
  }

  bool get isInterstitialReady => _interstitialLoaded;
  bool get isRewardedReady => _rewardedLoaded;

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
