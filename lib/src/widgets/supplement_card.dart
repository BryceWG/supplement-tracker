import 'package:flutter/material.dart';

import '../models/supplement.dart';
import '../util/colors.dart';
import '../util/format.dart';

class SupplementCard extends StatelessWidget {
  const SupplementCard({
    super.key,
    required this.supplement,
    required this.onEdit,
    required this.onPostponeOneDay,
    required this.onReplenish,
    required this.onDelete,
  });

  final Supplement supplement;
  final VoidCallback onEdit;
  final VoidCallback onPostponeOneDay;
  final VoidCallback onReplenish;
  final VoidCallback onDelete;

  Color _progressColor(int remainingDays) {
    if (remainingDays <= 14) return const Color(0xFFEF4444);
    if (remainingDays <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  @override
  Widget build(BuildContext context) {
    final remainingDays = supplement.remainingDays;
    final progress = supplement.remainingPercent.clamp(0.0, 1.0);
    final estimatedRemainingQty = supplement.estimatedRemainingQuantity;
    final stripColor = CategoryColors.fromHex(supplement.colorHex);
    final progressColor = _progressColor(remainingDays);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 62,
              decoration: BoxDecoration(
                color: stripColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplement.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${supplement.specification} · 每日${supplement.dailyDosage}${supplement.dosageUnit}'
                    ' · 开始：${supplement.effectiveStartUseDateYmd}',
                    style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '剩余 $remainingDays 天',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5A5A5A)),
                      ),
                      const Spacer(),
                      Text(
                        '$estimatedRemainingQty/${supplement.totalQuantity}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFEFEFEF),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  Format.currencyCny(supplement.dailyCost),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text('每日', style: TextStyle(fontSize: 11, color: Color(0xFF8A8A8A))),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: '编辑',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: '补充总量',
                      onPressed: onReplenish,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    IconButton(
                      tooltip: '跳过今天',
                      onPressed: onPostponeOneDay,
                      icon: const Icon(Icons.snooze_outlined),
                    ),
                    IconButton(
                      tooltip: '删除',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
