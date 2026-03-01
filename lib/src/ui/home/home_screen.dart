import 'dart:ui';

import 'package:flutter/material.dart';

import '../../controllers/supplements_controller.dart';
import '../../models/supplement.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/monthly_trend_chart.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reminder_list.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/supplement_card.dart';
import '../supplement_editor/supplement_editor_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final SupplementsController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openEditor({Supplement? supplement}) async {
    final result = await showGeneralDialog<Supplement>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      pageBuilder: (context, _, __) {
        return SupplementEditorDialog(supplement: supplement);
      },
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

    if (result != null) {
      await widget.controller.upsert(result);
    }
  }

  Future<void> _confirmDelete(Supplement supplement) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${supplement.name}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await widget.controller.removeById(supplement.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.initialized) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final supplements = controller.supplements;

        return Scaffold(
          appBar: _TopNavBar(onAdd: () => _openEditor()),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openEditor(),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0FDF4), Colors.white],
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const _PageHeader(),
                        const SizedBox(height: 16),
                        _StatsGrid(
                          total: supplements.length,
                          dailyCost: controller.dailyCostTotal,
                          monthlyCost: controller.monthlyCostTotal,
                          shortestRemaining: controller.shortestRemainingDays,
                        ),
                        const SizedBox(height: 20),
                        if (supplements.isEmpty)
                          EmptyState(onAdd: () => _openEditor())
                        else ...[
                          _Section(
                            title: '我的补剂',
                            child: Column(
                              children: [
                                for (final s in supplements) ...[
                                  SupplementCard(
                                    supplement: s,
                                    onEdit: () => _openEditor(supplement: s),
                                    onDelete: () => _confirmDelete(s),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _Section(
                            title: '数据分析',
                            child: _ChartsGrid(supplements: supplements),
                          ),
                          const SizedBox(height: 18),
                          ReminderList(supplements: supplements),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopNavBar({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          toolbarHeight: 64,
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '补剂管家',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (MediaQuery.sizeOf(context).width >= 720) ...[
                _NavChip(label: '首页', selected: true, onTap: () {}),
                _NavChip(
                  label: '我的补剂',
                  selected: false,
                  onTap: () => _toast(context, '当前版本：功能聚合在首页'),
                ),
                _NavChip(
                  label: '统计',
                  selected: false,
                  onTap: () => _toast(context, '当前版本：统计在「数据分析」区块'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('添加补剂'),
                ),
              ] else
                IconButton(
                  tooltip: '添加补剂',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppTheme.primaryLight : Colors.transparent;
    final fg = selected ? AppTheme.primary : const Color(0xFF5A5A5A);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '营养补剂跟踪器',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1D)),
        ),
        SizedBox(height: 6),
        Text(
          '追踪补剂库存与花费，让健康投资更清晰',
          style: TextStyle(fontSize: 15, color: Color(0xFF8A8A8A)),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.total,
    required this.dailyCost,
    required this.monthlyCost,
    required this.shortestRemaining,
  });

  final int total;
  final double dailyCost;
  final double monthlyCost;
  final int shortestRemaining;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1024 ? 4 : (width >= 640 ? 2 : 1);
        final items = [
          StatCardData(
            icon: Icons.inventory_2_outlined,
            label: '补剂总数',
            value: total.toString(),
            trend: '当前跟踪的补剂数量',
            color: const Color(0xFF22C55E),
          ),
          StatCardData(
            icon: Icons.account_balance_wallet_outlined,
            label: '今日花费',
            value: Format.currencyCny(dailyCost),
            trend: '日均花费',
            color: const Color(0xFF3B82F6),
          ),
          StatCardData(
            icon: Icons.calendar_month_outlined,
            label: '最短剩余',
            value: '$shortestRemaining 天',
            trend: '最早用完的补剂',
            color: const Color(0xFFF97316),
          ),
          StatCardData(
            icon: Icons.trending_up,
            label: '月度总花费',
            value: Format.currencyCny(monthlyCost),
            trend: '预计本月支出',
            color: const Color(0xFFA855F7),
          ),
        ];

        final rows = (items.length / columns).ceil();
        return Column(
          children: [
            for (var row = 0; row < rows; row++) ...[
              Row(
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (row * columns + col < items.length)
                      Expanded(child: StatCard(data: items[row * columns + col])),
                    if (col != columns - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
              if (row != rows - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ChartsGrid extends StatelessWidget {
  const _ChartsGrid({required this.supplements});

  final List<Supplement> supplements;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        final left = CategoryPieChart(supplements: supplements);
        final right = MonthlyTrendChart(supplements: supplements);

        if (!wide) {
          return Column(
            children: [
              left,
              const SizedBox(height: 12),
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
