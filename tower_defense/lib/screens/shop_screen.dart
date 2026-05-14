import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';
import '../services/iap_service.dart';
import '../state/providers.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  bool _loadingIap = true;
  bool _showingAd = false;

  @override
  void initState() {
    super.initState();
    _initIap();
  }

  Future<void> _initIap() async {
    IAPService.instance.onPurchaseSuccess = (gems, removesAds) async {
      final notifier = ref.read(playerNotifierProvider.notifier);
      if (gems > 0) await notifier.addGems(gems);
      if (removesAds) await notifier.setRemoveAds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase complete! ${gems > 0 ? '+$gems gems' : ''} ${removesAds ? '• Ads removed' : ''}'), backgroundColor: Colors.green),
        );
      }
    };
    IAPService.instance.onPurchaseError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $error'), backgroundColor: Colors.red),
        );
      }
    };
    await IAPService.instance.init();
    if (mounted) setState(() => _loadingIap = false);
  }

  Future<void> _watchAdForGold() async {
    setState(() => _showingAd = true);
    final earned = await AdService.instance.showRewardedAd(
      onUserEarnedReward: (reward) {
        ref.read(playerNotifierProvider.notifier).addGold(50);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('+50 Gold earned!'), backgroundColor: Colors.amber),
          );
        }
      },
    );
    if (!earned && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready yet. Try again shortly.'), backgroundColor: Colors.orange),
      );
    }
    if (mounted) setState(() => _showingAd = false);
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.blue, size: 18),
                const SizedBox(width: 4),
                Text('${player.gems}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('${player.gold}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(label: 'Free Gold'),
            _AdRewardCard(
              onWatchAd: _showingAd ? null : _watchAdForGold,
              loading: _showingAd,
            ),
            const SizedBox(height: 24),
            _SectionHeader(label: 'Gem Packs'),
            if (_loadingIap)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (!IAPService.instance.isAvailable)
              const _UnavailableMessage()
            else ...[
              _buildGemProduct(IAPProductId.gemsSmall, '100 Gems', Icons.diamond_outlined, Colors.blue.shade300),
              _buildGemProduct(IAPProductId.gemsMedium, '550 Gems', Icons.diamond, Colors.blue),
              _buildGemProduct(IAPProductId.gemsLarge, '1200 Gems', Icons.diamond, Colors.indigo),
            ],
            const SizedBox(height: 24),
            _SectionHeader(label: 'Special Offers'),
            if (!_loadingIap && IAPService.instance.isAvailable) ...[
              if (!player.removeAdsPurchased)
                _buildSpecialProduct(IAPProductId.removeAds, 'Remove Ads', 'Permanently remove all banner & interstitial ads', Icons.block, Colors.red.shade400),
              _buildSpecialProduct(IAPProductId.starterPack, 'Starter Pack', '200 Gems + Remove Ads — Best Value!', Icons.star, Colors.amber),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGemProduct(IAPProductId id, String label, IconData icon, Color color) {
    final product = IAPService.instance.findProduct(id);
    if (product == null) return const SizedBox.shrink();
    return _ProductCard(
      icon: icon,
      color: color,
      title: label,
      price: product.details.price,
      onBuy: () => IAPService.instance.buyProduct(product),
    );
  }

  Widget _buildSpecialProduct(IAPProductId id, String title, String subtitle, IconData icon, Color color) {
    final product = IAPService.instance.findProduct(id);
    if (product == null) return const SizedBox.shrink();
    return _ProductCard(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      price: product.details.price,
      onBuy: () => IAPService.instance.buyProduct(product),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _AdRewardCard extends StatelessWidget {
  final VoidCallback? onWatchAd;
  final bool loading;
  const _AdRewardCard({this.onWatchAd, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.play_circle_filled, color: Colors.amber, size: 40),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Watch Ad for +50 Gold', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Free! Available after each viewing.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                : ElevatedButton(
                    onPressed: onWatchAd,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
                    child: const Text('Watch'),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String price;
  final VoidCallback onBuy;

  const _ProductCard({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.price,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableMessage extends StatelessWidget {
  const _UnavailableMessage();

  @override
  Widget build(BuildContext context) {
    return const Card(
      color: Color(0xFF2A2A3E),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'In-app purchases are not available on this device.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
