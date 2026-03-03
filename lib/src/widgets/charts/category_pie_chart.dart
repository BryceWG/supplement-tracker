import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/supplement.dart';
import '../../util/colors.dart';
import '../../util/format.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key, required this.supplements});

  final List<Supplement> supplements;

  Map<String, double> _categoryMonthlyCost() {
    final from = DateTime.now();
    final map = <String, double>{};
    for (final s in supplements) {
      final monthly = s.costForNextDays(from: from, days: 30);
      map[s.category] = (map[s.category] ?? 0) + monthly;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final data = _categoryMonthlyCost();
    if (supplements.isEmpty || data.isEmpty) return const SizedBox.shrink();

    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.chartMonthlyCostByCategoryTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _PiePainter(entries: entries),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 160,
                    child: ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final e = entries[i];
                        final color = CategoryColors.forCategory(e.key);
                        return Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                categoryLabel(context, e.key),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Format.currencyCny(e.value),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF5A5A5A)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.entries});

  final List<MapEntry<String, double>> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = min(size.width, size.height) * 0.38;
    final strokeWidth = radius * 0.55;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    var start = -pi / 2;
    for (final e in entries) {
      final sweep = (e.value / total) * (2 * pi);
      paint.color = CategoryColors.forCategory(e.key);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    if (entries.length != oldDelegate.entries.length) return true;
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].key != oldDelegate.entries[i].key) return true;
      if ((entries[i].value - oldDelegate.entries[i].value).abs() > 0.0001) return true;
    }
    return false;
  }
}
