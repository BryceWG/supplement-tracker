import 'dart:ui';

import 'package:flutter/material.dart';

import '../../controllers/supplements_controller.dart';
import '../../l10n/l10n.dart';
import '../../models/supplement.dart';
import '../../theme/app_theme.dart';
import '../../util/format.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/monthly_trend_chart.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reminder_list.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/supplement_card.dart';
import 'supplement_list_export_screen.dart';
import '../profile/profile_manager_dialog.dart';
import '../settings/settings_screen.dart';
import '../supplement_editor/supplement_editor_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final SupplementsController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openEditor({Supplement? supplement}) async {
    final templates =
        supplement == null ? await widget.controller.loadAllSupplementsAcrossProfiles() : const <Supplement>[];
    if (!mounted) return;
    final result = await showGeneralDialog<Supplement>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      pageBuilder: (context, _, __) {
        return SupplementEditorDialog(supplement: supplement, templates: templates);
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
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.homeDialogConfirmDeleteTitle),
        content: Text(l10n.homeDialogConfirmDeleteContent(supplement.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (ok == true) {
      await widget.controller.removeById(supplement.id);
    }
  }

  Future<void> _postponeOneDay(Supplement supplement) async {
    final l10n = context.l10n;
    final beforeStart = supplement.startUseDate;
    final beforeSkipped = supplement.skippedDates.length;

    final updated = await widget.controller.postponeStartUseOneDay(supplement.id);
    if (updated == null) return;
    if (!mounted) return;

    final startChanged = beforeStart != updated.startUseDate;
    final skippedChanged = updated.skippedDates.length > beforeSkipped;

    String message;
    if (startChanged) {
      message = l10n.homeSnackStartPostponed(
        updated.name,
        updated.startUseDate ?? updated.effectiveStartUseDateYmd,
      );
    } else if (skippedChanged) {
      final today = Supplement.formatYmd(DateTime.now());
      message = l10n.homeSnackSkippedToday(today, updated.name);
    } else {
      message = l10n.homeSnackUpdated(updated.name);
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _replenish(Supplement supplement) async {
    final l10n = context.l10n;
    final qtyCtrl = TextEditingController(text: '');

    final addQty = await showDialog<int>(
      context: context,
      builder: (context) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.homeDialogReplenishTitle),
            content: TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.homeFieldAddQuantityLabel,
                hintText: l10n.homeFieldAddQuantityHint,
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
              FilledButton(
                onPressed: () {
                  final raw = qtyCtrl.text.trim();
                  final parsed = int.tryParse(raw);
                  if (parsed == null || parsed <= 0) {
                    setState(() => errorText = l10n.validationNumberMin1);
                    return;
                  }
                  Navigator.pop(context, parsed);
                },
                child: Text(l10n.commonOk),
              ),
            ],
          ),
        );
      },
    );

    qtyCtrl.dispose();

    if (addQty == null) return;

    final updated = await widget.controller.replenishQuantity(supplement.id, addQuantity: addQty);
    if (updated == null) return;
    if (!mounted) return;

    final unit = dosageUnitLabel(context, updated.dosageUnit, count: addQty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.homeSnackReplenish(addQty, unit, updated.name))),
    );
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
        final hasLowStockReminders = supplements.any((s) => s.remainingDays <= 14);

        return Scaffold(
          appBar: _TopNavBar(controller: controller),
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
                        if (hasLowStockReminders) ...[
                          ReminderList(supplements: supplements),
                          const SizedBox(height: 18),
                        ],
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
            title: context.l10n.homeTabSupplements,
            child: Column(
              children: [
                for (final s in supplements) ...[
                                  SupplementCard(
                                    supplement: s,
                                    onEdit: () => _openEditor(supplement: s),
                                    onReplenish: () => _replenish(s),
                                    onPostponeOneDay: () => _postponeOneDay(s),
                                    onDelete: () => _confirmDelete(s),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            ),
                          ),
          const SizedBox(height: 18),
          _Section(
            title: context.l10n.homeTabAnalytics,
            child: _ChartsGrid(supplements: supplements),
          ),
                          const SizedBox(height: 18),
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
  const _TopNavBar({required this.controller});

  final SupplementsController controller;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          toolbarHeight: 64,
          titleSpacing: 16,
          title: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: Colors.white,
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              _ProfileMenu(controller: controller),
              const SizedBox(width: 6),
              IconButton(
                tooltip: l10n.homeTooltipExportList,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SupplementListExportScreen(controller: controller),
                    ),
                  );
                },
                icon: const Icon(Icons.image_outlined),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: l10n.homeTooltipSettings,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(controller: controller),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.controller});

  final SupplementsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = controller.activeProfile;

    return PopupMenuButton<String>(
      tooltip: l10n.homeTooltipSwitchProfile,
      position: PopupMenuPosition.under,
      onSelected: (value) async {
        if (value == '_manage') {
          await showDialog<void>(
            context: context,
            builder: (context) => ProfileManagerDialog(controller: controller),
          );
          return;
        }
        await controller.switchProfile(value);
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        for (final p in controller.profiles) {
          final isActive = p.id == active.id;
          items.add(
            PopupMenuItem<String>(
              value: p.id,
              child: Row(
                children: [
                  if (isActive) ...[
                    const Icon(Icons.check, size: 18),
                    const SizedBox(width: 8),
                  ] else
                    const SizedBox(width: 26),
                  Expanded(child: Text(p.name)),
                ],
              ),
            ),
          );
        }

        items.add(const PopupMenuDivider());
        items.add(
          PopupMenuItem<String>(
            value: '_manage',
            child: Row(
              children: [
                const Icon(Icons.group_outlined, size: 18),
                const SizedBox(width: 8),
                Text(l10n.homeManageProfiles),
              ],
            ),
          ),
        );

        return items;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 18, color: AppTheme.primary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                active.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 18, color: AppTheme.primary),
          ],
        ),
      ),
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
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Mobile: show 2 cards per row (2 rows total) to save vertical space.
        // Super narrow screens fall back to 1 column to avoid cramped layout.
        final columns = width >= 1024 ? 4 : (width < 360 ? 1 : 2);
        final items = [
          StatCardData(
            icon: Icons.inventory_2_outlined,
            label: l10n.statsTotalSupplementsLabel,
            value: total.toString(),
            trend: l10n.statsTotalSupplementsTrend,
            color: const Color(0xFF22C55E),
          ),
          StatCardData(
            icon: Icons.account_balance_wallet_outlined,
            label: l10n.statsTodayCostLabel,
            value: Format.currencyCny(dailyCost),
            trend: l10n.statsTodayCostTrend,
            color: const Color(0xFF3B82F6),
          ),
          StatCardData(
            icon: Icons.calendar_month_outlined,
            label: l10n.statsShortestRemainingLabel,
            value: l10n.commonDays(shortestRemaining),
            trend: l10n.statsShortestRemainingTrend,
            color: const Color(0xFFF97316),
          ),
          StatCardData(
            icon: Icons.trending_up,
            label: l10n.statsMonthlyCostLabel,
            value: Format.currencyCny(monthlyCost),
            trend: l10n.statsMonthlyCostTrend,
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
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
