import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/ad_service.dart';
import '../state/providers.dart';

class GameOverScreen extends ConsumerStatefulWidget {
  final int levelId;
  final int wavesReached;
  final bool won;

  const GameOverScreen({
    super.key,
    required this.levelId,
    required this.wavesReached,
    required this.won,
  });

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  bool _continuedOnce = false;
  bool _showingAd = false;

  @override
  void initState() {
    super.initState();
    // Show interstitial if it was queued (checked in game_screen after win)
    if (widget.won) {
      _maybeShowInterstitial();
    }
  }

  Future<void> _maybeShowInterstitial() async {
    final player = ref.read(playerNotifierProvider);
    if (player.removeAdsPurchased) return;
    // Small delay so screen renders first
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await AdService.instance.showInterstitialAd();
    }
  }

  Future<void> _watchAdToContinue() async {
    setState(() => _showingAd = true);
    final earned = await AdService.instance.showRewardedAd(
      onUserEarnedReward: (reward) {
        setState(() => _continuedOnce = true);
        // Go back into the game — in a full implementation this would resume
        // the game state; here we restart the level with boosted lives.
        if (mounted) {
          context.go('/game/${widget.levelId}');
        }
      },
    );
    if (!earned && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready. Please wait a moment.'), backgroundColor: Colors.orange),
      );
    }
    if (mounted) setState(() => _showingAd = false);
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.won
                ? [const Color(0xFF1B5E20), const Color(0xFF33691E)]
                : [const Color(0xFF4A0000), const Color(0xFF1A0000)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.won ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied_rounded,
                  size: 80,
                  color: widget.won ? Colors.amber : Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.won ? 'VICTORY!' : 'GAME OVER',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: widget.won ? Colors.amber : Colors.red.shade300,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.won
                      ? 'Level ${widget.levelId} Complete!'
                      : 'You reached wave ${widget.wavesReached}',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 48),
                // Continue with ad (only for losses, only once)
                if (!widget.won && !_continuedOnce && !player.removeAdsPurchased) ...[
                  _ActionButton(
                    label: _showingAd ? 'Loading Ad...' : 'Watch Ad to Continue',
                    icon: Icons.play_circle_filled,
                    color: Colors.amber.shade700,
                    onTap: _showingAd ? null : _watchAdToContinue,
                  ),
                  const SizedBox(height: 12),
                ],
                _ActionButton(
                  label: 'Retry Level',
                  icon: Icons.refresh_rounded,
                  color: Colors.blue.shade700,
                  onTap: () => context.go('/game/${widget.levelId}'),
                ),
                const SizedBox(height: 12),
                if (widget.won)
                  _ActionButton(
                    label: 'Next Level',
                    icon: Icons.arrow_forward_rounded,
                    color: Colors.green.shade700,
                    onTap: player.isLevelUnlocked(widget.levelId + 1)
                        ? () => context.go('/game/${widget.levelId + 1}')
                        : null,
                  ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Main Menu',
                  icon: Icons.home_rounded,
                  color: Colors.grey.shade700,
                  onTap: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: onTap != null ? color : Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
