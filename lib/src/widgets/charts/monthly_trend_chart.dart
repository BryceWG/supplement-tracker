import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/supplement.dart';
import '../../theme/app_theme.dart';

class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({super.key, required this.supplements});

  final List<Supplement> supplements;

  List<String> _last6MonthsLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      labels.add('${d.month}月');
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    if (supplements.isEmpty) return const SizedBox.shrink();

    final from = DateTime.now();
    final monthlyTotal = supplements.fold<double>(0, (sum, s) => sum + s.costForNextDays(from: from, days: 30));
    final labels = _last6MonthsLabels();
    final values = List<double>.filled(6, monthlyTotal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('花费趋势', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _LinePainter(labels: labels, values: values),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.labels, required this.values});

  final List<String> labels;
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty || values.isEmpty) return;

    const paddingLeft = 36.0;
    const paddingRight = 14.0;
    const paddingTop = 14.0;
    const paddingBottom = 28.0;

    final chartRect = Rect.fromLTWH(
      paddingLeft,
      paddingTop,
      max(1, size.width - paddingLeft - paddingRight),
      max(1, size.height - paddingTop - paddingBottom),
    );

    final maxY = values.reduce(max).clamp(1.0, double.infinity);
    const minY = 0.0;
    final range = max(1e-6, maxY - minY);

    final gridPaint = Paint()
      ..color = const Color(0xFFEFEFEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + (chartRect.height * i / 4);
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = chartRect.left + (chartRect.width * i / max(1, values.length - 1));
      final normalized = (values[i] - minY) / range;
      final y = chartRect.bottom - (chartRect.height * normalized);
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, chartRect.bottom)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, chartRect.bottom)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primary.withValues(alpha: 0.18),
          AppTheme.primary.withValues(alpha: 0.02),
        ],
      ).createShader(chartRect);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = AppTheme.primary;
    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
    }

    const textStyle = TextStyle(color: Color(0xFF8A8A8A), fontSize: 11);
    for (var i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = chartRect.left + (chartRect.width * i / max(1, labels.length - 1));
      tp.paint(canvas, Offset(x - tp.width / 2, chartRect.bottom + 8));
    }

    for (final tick in [0.0, maxY]) {
      final label = '¥${tick.toStringAsFixed(0)}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = chartRect.bottom - (chartRect.height * ((tick - minY) / range));
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    if (labels.length != oldDelegate.labels.length) return true;
    if (values.length != oldDelegate.values.length) return true;
    for (var i = 0; i < labels.length; i++) {
      if (labels[i] != oldDelegate.labels[i]) return true;
    }
    for (var i = 0; i < values.length; i++) {
      if ((values[i] - oldDelegate.values[i]).abs() > 0.0001) return true;
    }
    return false;
  }
}
