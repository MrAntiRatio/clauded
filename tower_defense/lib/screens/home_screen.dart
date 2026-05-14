import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../state/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    final player = ref.read(playerNotifierProvider);
    if (!player.removeAdsPurchased) {
      AdService.instance.loadBannerAd(onLoaded: () {
        if (mounted) setState(() => _bannerLoaded = true);
      });
    }
    AdService.instance.loadInterstitialAd();
    AdService.instance.loadRewardedAd();
  }

  @override
  void dispose() {
    AdService.instance.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF0D2B12)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (!player.removeAdsPurchased && _bannerLoaded)
                _BannerAdWidget(ad: AdService.instance.bannerAd!),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.castle,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TOWER DEFENSE',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Defend your realm',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade200,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _ResourceRow(gold: player.gold, gems: player.gems),
                      const SizedBox(height: 40),
                      _MenuButton(
                        label: 'PLAY',
                        icon: Icons.play_arrow_rounded,
                        color: Colors.green.shade600,
                        onTap: () => context.push('/levels'),
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        label: 'SHOP',
                        icon: Icons.store_rounded,
                        color: Colors.amber.shade700,
                        onTap: () => context.push('/shop'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final int gold;
  final int gems;
  const _ResourceRow({required this.gold, required this.gems});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ResourceChip(icon: Icons.monetization_on, value: gold, color: Colors.amber),
        const SizedBox(width: 24),
        _ResourceChip(icon: Icons.diamond, value: gems, color: Colors.blue.shade300),
      ],
    );
  }
}

class _ResourceChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  const _ResourceChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _BannerAdWidget extends StatelessWidget {
  final BannerAd ad;
  const _BannerAdWidget({required this.ad});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
