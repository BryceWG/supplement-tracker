import 'package:flutter/material.dart';

class StatCardData {
  StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final Color color;
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.data});

  final StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(height: 12),
            Text(
              data.label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A8A), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              data.value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              data.trend,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
            ),
          ],
        ),
      ),
    );
  }
}
