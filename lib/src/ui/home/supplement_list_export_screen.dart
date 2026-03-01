import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../controllers/supplements_controller.dart';
import '../../models/supplement.dart';
import '../../services/export_image/image_file_service_factory.dart';
import '../../theme/app_theme.dart';
import '../../util/colors.dart';
import '../../util/format.dart';

class SupplementListExportScreen extends StatefulWidget {
  const SupplementListExportScreen({super.key, required this.controller});

  final SupplementsController controller;

  @override
  State<SupplementListExportScreen> createState() => _SupplementListExportScreenState();
}

class _SupplementListExportScreenState extends State<SupplementListExportScreen> {
  final _fileService = createImageFileService();
  final _boundaryKey = GlobalKey();

  bool _busy = false;

  String _sanitizeFileNamePart(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'profile';
    return trimmed.replaceAll(RegExp(r'[\\\\/:*?"<>|]+'), '_');
  }

  String _buildSuggestedFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');

    final profile = _sanitizeFileNamePart(widget.controller.activeProfile.name);
    return 'supplements_${profile}_$y$m${d}_$hh$mm$ss.png';
  }

  Future<Uint8List> _capturePngBytes({required double pixelRatio}) async {
    await WidgetsBinding.instance.endOfFrame;

    final renderObject = _boundaryKey.currentContext?.findRenderObject();
    final boundary = renderObject is RenderRepaintBoundary ? renderObject : null;
    if (boundary == null) {
      throw StateError('无法获取要导出的区域');
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('图片生成失败');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _export() async {
    if (_busy) return;

    final supplements = widget.controller.supplements;
    if (supplements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('当前没有补剂可导出')));
      return;
    }

    setState(() => _busy = true);

    try {
      final pixelRatio = MediaQuery.of(context).devicePixelRatio.clamp(2.0, 3.0).toDouble();
      final pngBytes = await _capturePngBytes(pixelRatio: pixelRatio);
      final ok = await _fileService.savePng(
        suggestedFileName: _buildSuggestedFileName(),
        pngBytes: pngBytes,
      );

      if (!mounted) return;
      if (ok) {
        final mobile = !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
        final message = mobile ? '已打开系统分享（可保存/发送图片）' : '已导出 PNG 图片';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出失败：$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final supplements = controller.supplements;
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    final actionLabel = isMobile ? '分享 PNG' : '下载 PNG';
    final actionIcon = isMobile ? Icons.share_outlined : Icons.download_outlined;

    return Scaffold(
      appBar: AppBar(
        title: const Text('导出补剂清单'),
        actions: [
          IconButton(
            tooltip: actionLabel,
            onPressed: _busy ? null : _export,
            icon: Icon(actionIcon),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              const title = Text(
                                '导出为图片（PNG）',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              );
                              return title;
                            },
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isMobile
                                ? '点击右上角或下方按钮即可分享当前成员的补剂清单（适合发给朋友/营养师）。'
                                : '点击右上角或下方按钮即可下载当前成员的补剂清单图片（PNG）。',
                            style: TextStyle(color: Colors.black.withValues(alpha: 0.60)),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _busy ? null : _export,
                            icon: Icon(actionIcon),
                            label: Text(actionLabel),
                          ),
                          if (_busy) ...[
                            const SizedBox(height: 10),
                            const LinearProgressIndicator(minHeight: 3),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RepaintBoundary(
                    key: _boundaryKey,
                    child: _ExportSurface(
                      child: _ExportSheet(
                        profileName: controller.activeProfile.name,
                        exportedAt: DateTime.now(),
                        dailyCostTotal: controller.dailyCostTotal,
                        monthlyCostTotal: controller.monthlyCostTotal,
                        supplements: supplements,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportSheet extends StatelessWidget {
  const _ExportSheet({
    required this.profileName,
    required this.exportedAt,
    required this.dailyCostTotal,
    required this.monthlyCostTotal,
    required this.supplements,
  });

  final String profileName;
  final DateTime exportedAt;
  final double dailyCostTotal;
  final double monthlyCostTotal;
  final List<Supplement> supplements;

  @override
  Widget build(BuildContext context) {
    return _ExportListSheet(
      profileName: profileName,
      exportedAt: exportedAt,
      dailyCostTotal: dailyCostTotal,
      monthlyCostTotal: monthlyCostTotal,
      supplements: supplements,
    );
  }
}

class _ExportListSheet extends StatelessWidget {
  const _ExportListSheet({
    required this.profileName,
    required this.exportedAt,
    required this.dailyCostTotal,
    required this.monthlyCostTotal,
    required this.supplements,
  });

  final String profileName;
  final DateTime exportedAt;
  final double dailyCostTotal;
  final double monthlyCostTotal;
  final List<Supplement> supplements;

  String _ymdHm(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5EE),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandHeader(
            title: '$profileName 的补剂清单',
            subtitle: '一份可分享的补剂清单',
            meta: '导出：${_ymdHm(exportedAt)}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.inventory_2_outlined, label: '补剂数', value: supplements.length.toString()),
              _InfoChip(icon: Icons.account_balance_wallet_outlined, label: '今日花费', value: Format.currencyCny(dailyCostTotal)),
              _InfoChip(icon: Icons.calendar_month_outlined, label: '月度总花费', value: Format.currencyCny(monthlyCostTotal)),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 12),
          for (var i = 0; i < supplements.length; i++) ...[
            _SupplementRow(index: i + 1, supplement: supplements[i]),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.share_outlined, size: 16, color: Colors.black.withValues(alpha: 0.55)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '可分享给朋友/营养师，便于快速了解你的补剂情况',
                  style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.55)),
                ),
              ),
              Text(
                '补剂管家',
                style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.55), fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportSurface extends StatelessWidget {
  const _ExportSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final String title;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.medication_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.2),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.70), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                style: TextStyle(fontSize: 11, color: Colors.black.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.55)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black.withValues(alpha: 0.60)),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SupplementRow extends StatelessWidget {
  const _SupplementRow({required this.index, required this.supplement});

  final int index;

  final Supplement supplement;

  Color _progressColor(int remainingDays) {
    if (remainingDays <= 14) return const Color(0xFFEF4444);
    if (remainingDays <= 30) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  @override
  Widget build(BuildContext context) {
    final stripColor = CategoryColors.fromHex(supplement.colorHex);
    final remainingDays = supplement.remainingDays;
    final estimatedRemainingQty = supplement.estimatedRemainingQuantity;
    final progress = supplement.remainingPercent.clamp(0.0, 1.0);
    final progressColor = _progressColor(remainingDays);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFC),
        border: Border.all(color: const Color(0xFFEDEEF1)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: stripColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(fontWeight: FontWeight.w900, color: stripColor.withValues(alpha: 0.95)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            supplement.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(days: remainingDays, color: progressColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MiniChip(
                          color: CategoryColors.forCategory(supplement.category),
                          text: supplement.category,
                        ),
                        Text(
                          supplement.specification,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                        ),
                        Text(
                          '每日${supplement.dailyDosage}${supplement.dosageUnit}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '开始：${supplement.startUseDate ?? '未设置'} · 数量：$estimatedRemainingQty/${supplement.totalQuantity}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Format.currencyCny(supplement.dailyCost),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  const Text('每日', style: TextStyle(fontSize: 11, color: Color(0xFF8A8A8A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFEFEFEF),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.days, required this.color});

  final int days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        '剩余 $days 天',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color.withValues(alpha: 0.95)),
      ),
    );
  }
}
