import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme.dart';
import '../../../data/coin_repository.dart';

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = CoinRepository.to;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SHOP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.yellow, size: 20),
                        const SizedBox(width: 8),
                        Text('${coins.balance.value}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                const Text('HINT PACKS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                const SizedBox(height: 12),
                _buildShopItem('3 Hints Pack', 'Get past tricky levels', '300', Icons.lightbulb, AppTheme.accent),
                const SizedBox(height: 8),
                _buildShopItem('10 Hints Pack', 'Best value!', '800', Icons.lightbulb, AppTheme.warning),
                
                const SizedBox(height: 24),
                const Text('COSMETICS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                const SizedBox(height: 12),
                _buildShopItem('Neon Theme', 'Cyberpunk vibes', '1500', Icons.color_lens, Colors.pink),
                const SizedBox(height: 8),
                _buildShopItem('Nature Board', 'Wooden grid style', '2000', Icons.forest, Colors.green),
                
                const SizedBox(height: 24),
                const Text('PREMIUM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white54)),
                const SizedBox(height: 12),
                Card(
                  color: AppTheme.primary,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.block, color: Colors.white, size: 32),
                    title: const Text('Remove Ads', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: const Text('Enjoy uninterrupted gameplay forever.'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                      ),
                      child: const Text('\$2.99'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(String title, String subtitle, String price, IconData icon, Color iconColor) {
    return Card(
      color: AppTheme.cardBackground,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: Colors.yellow, size: 16),
              const SizedBox(width: 4),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
