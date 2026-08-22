import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PROFILE',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Guest_4815',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          _buildStatRow('Total Stars', '45', Icons.star, Colors.yellow),
          const SizedBox(height: 16),
          _buildStatRow('Levels Completed', '15', Icons.check_circle, AppTheme.success),
          const SizedBox(height: 16),
          _buildStatRow('Best Time', '12s', Icons.timer, AppTheme.accent),
          
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cloud_upload),
            label: const Text('SIGN IN TO SYNC PROGRESS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cardBackground,
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
