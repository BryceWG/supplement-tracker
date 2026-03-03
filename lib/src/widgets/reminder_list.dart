import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/supplement.dart';

class ReminderList extends StatelessWidget {
  const ReminderList({super.key, required this.supplements});

  final List<Supplement> supplements;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reminders = <_Reminder>[];
    for (final s in supplements) {
      final days = s.remainingDays;
      if (days <= 14) {
        reminders.add(
          _Reminder(
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444),
            title: l10n.reminderLowStockTitle(s.name),
            message: l10n.reminderLowStockMessage(days),
            time: l10n.reminderJustNow,
          ),
        );
      }
    }

    if (reminders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reminderSectionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (final r in reminders) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: r.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(r.icon, color: r.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(r.message, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(r.time, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Reminder {
  _Reminder({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;
}
