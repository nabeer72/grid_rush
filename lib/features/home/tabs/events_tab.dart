import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ACTIVE EVENTS',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildEventCard(
                  title: 'Weekend Puzzle Rush',
                  description: 'Complete 10 levels this weekend to earn an exclusive trail effect!',
                  timeLeft: '2 Days Left',
                  color: AppTheme.primary,
                  icon: Icons.timer,
                ),
                const SizedBox(height: 16),
                _buildEventCard(
                  title: 'Daily Challenge',
                  description: 'Solve today\'s master puzzle for 500 coins.',
                  timeLeft: '14 Hours Left',
                  color: AppTheme.accent,
                  icon: Icons.star,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String description,
    required String timeLeft,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: AppTheme.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(timeLeft, style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: const Text('VIEW EVENT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
