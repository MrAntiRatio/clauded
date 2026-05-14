import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../state/providers.dart';
import '../game/data/level_data.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
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
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
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
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: allLevels.length,
                    itemBuilder: (context, index) {
                      final level = allLevels[index];
                      final unlocked = player.isLevelUnlocked(level.id);
                      return _LevelCard(
                        level: level,
                        unlocked: unlocked,
                        onTap: unlocked
                            ? () => context.push('/game/${level.id}')
                            : null,
                      );
                    },
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

class _LevelCard extends StatelessWidget {
  final LevelData level;
  final bool unlocked;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, required this.unlocked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF2E7D32) : const Color(0xFF424242),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? Colors.green.shade300 : Colors.grey,
            width: 2,
          ),
          boxShadow: unlocked
              ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.landscape_rounded : Icons.lock_rounded,
              size: 36,
              color: unlocked ? Colors.amber : Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              'Level ${level.id}',
              style: TextStyle(
                color: unlocked ? Colors.white : Colors.grey.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              level.name,
              style: TextStyle(
                color: unlocked ? Colors.green.shade200 : Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${level.waves.length} waves',
              style: TextStyle(
                color: unlocked ? Colors.amber.shade200 : Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
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
