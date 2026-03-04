import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/supplement.dart';
import '../../models/supplement_template_ref.dart';
import '../../theme/app_theme.dart';
import '../../util/colors.dart';

sealed class SupplementEditorResult {
  const SupplementEditorResult();
}

class SupplementEditorUpsertResult extends SupplementEditorResult {
  const SupplementEditorUpsertResult(this.supplement);

  final Supplement supplement;
}

class SupplementEditorShareStockResult extends SupplementEditorResult {
  const SupplementEditorShareStockResult({
    required this.source,
    required this.targetDraft,
  });

  final SupplementTemplateRef source;
  final Supplement targetDraft;
}

class SupplementEditorDialog extends StatefulWidget {
  const SupplementEditorDialog({
    super.key,
    this.supplement,
    this.templates = const [],
  });

  final Supplement? supplement;
  final List<SupplementTemplateRef> templates;

  @override
  State<SupplementEditorDialog> createState() => _SupplementEditorDialogState();
}

class _SupplementEditorDialogState extends State<SupplementEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _spec;
  late final TextEditingController _dailyDosage;
  late final TextEditingController _price;
  late final TextEditingController _totalQty;
  late final TextEditingController _purchaseUrl;

  String _dosageUnit = '粒';
  String _category = '维生素';
  late String _startUseDateYmd;
  late List<String> _skippedDates;
  late final List<SupplementTemplateRef> _templateOptions;
  SupplementTemplateRef? _shareSource;
  bool _shareStock = false;

  @override
  void initState() {
    super.initState();
    final s = widget.supplement;
    _name = TextEditingController(text: s?.name ?? '');
    _spec = TextEditingController(text: s?.specification ?? '');
    _dailyDosage = TextEditingController(text: (s?.dailyDosage ?? 1).toString());
    _price = TextEditingController(text: (s?.price ?? '').toString());
    final initialTotalQty = s == null ? '' : s.totalQuantityAt(DateTime.now()).toString();
    _totalQty = TextEditingController(text: s == null ? '' : initialTotalQty);
    _purchaseUrl = TextEditingController(text: s?.purchaseUrl ?? '');

    _dosageUnit = s?.dosageUnit ?? '粒';
    _category = s?.category ?? '维生素';
    _startUseDateYmd = s?.startUseDate ?? s?.purchaseDate ?? _todayYmd();
    _skippedDates = [...(s?.skippedDates ?? const [])];

    _templateOptions = widget.templates.toList()
      ..sort((a, b) => a.supplement.name.compareTo(b.supplement.name));
    _shareStock = s?.stockId != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _spec.dispose();
    _dailyDosage.dispose();
    _price.dispose();
    _totalQty.dispose();
    _purchaseUrl.dispose();
    super.dispose();
  }

  String _todayYmd() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickStartUseDate() async {
    final l10n = context.l10n;
    final initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10),
      helpText: l10n.supplementEditorDatePickerHelp,
    );
    if (picked == null) return;
    setState(() => _startUseDateYmd = Supplement.formatYmd(picked));
  }

  void _postponeOneDayLocal() {
    final today = Supplement.formatYmd(DateTime.now());
    if (_skippedDates.contains(today)) return;
    setState(() {
      _skippedDates = [..._skippedDates, today]..sort();
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final existing = widget.supplement;
    final dailyDosage = int.parse(_dailyDosage.text.trim());
    final price = double.parse(_price.text.trim());
    final totalQty = int.parse(_totalQty.text.trim());
    final todayYmd = _todayYmd();

    final colorHex = existing?.colorHex ?? CategoryColors.hexForCategory(_category);
    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final purchaseUrl = _purchaseUrl.text.trim();

    final purchaseDate = existing?.purchaseDate ?? todayYmd;

    List<DosageChange> dosageChanges = existing?.dosageChanges ?? const <DosageChange>[];
    if (existing != null && dailyDosage != existing.dailyDosage) {
      final list = [...existing.dosageChanges];
      if (list.isEmpty) {
        final baselineDate =
            (existing.startUseDate != null && existing.startUseDate!.compareTo(existing.purchaseDate) < 0)
                ? existing.startUseDate!
                : existing.purchaseDate;
        list.add(DosageChange(effectiveDate: baselineDate, dailyDosage: existing.dailyDosage));
      }

      list.removeWhere((c) => c.effectiveDate == todayYmd);
      list.add(DosageChange(effectiveDate: todayYmd, dailyDosage: dailyDosage));
      list.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
      dosageChanges = list;
    }

    List<StockChange> stockChanges = existing?.stockChanges ?? const <StockChange>[];
    int baseTotalQuantity = totalQty;
    if (existing != null && existing.stockId == null) {
      baseTotalQuantity = existing.totalQuantity;
      final currentTotal = existing.totalQuantityAt(DateTime.now());
      final delta = totalQty - currentTotal;
      if (delta != 0) {
        final list = [...existing.stockChanges];
        list.removeWhere((c) => c.effectiveDate == todayYmd);
        list.add(StockChange(effectiveDate: todayYmd, quantityDelta: delta));
        list.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
        stockChanges = list;
      }
    }
    final result = Supplement(
      id: id,
      name: _name.text.trim(),
      specification: _spec.text.trim(),
      dailyDosage: dailyDosage,
      dosageUnit: _dosageUnit,
      price: price,
      purchaseDate: purchaseDate,
      startUseDate: _startUseDateYmd,
      purchaseUrl: purchaseUrl.isEmpty ? null : purchaseUrl,
      stockId: existing?.stockId,
      totalQuantity: baseTotalQuantity,
      remainingQuantity: existing == null ? totalQty : min(existing.remainingQuantity, totalQty),
      category: _category,
      colorHex: colorHex,
      skippedDates: _skippedDates,
      dosageChanges: dosageChanges,
      stockChanges: stockChanges,
    );

    final shareSource = _shareSource;
    if (existing == null && _shareStock && shareSource != null) {
      Navigator.of(context).pop(SupplementEditorShareStockResult(source: shareSource, targetDraft: result));
      return;
    }

    Navigator.of(context).pop(SupplementEditorUpsertResult(result));
  }

  void _applyShareSource(Supplement template) {
    _name.text = template.name;
    _spec.text = template.specification;
    _price.text = template.price.toString();
    _totalQty.text = template.totalQuantityAt(DateTime.now()).toString();
    _purchaseUrl.text = template.purchaseUrl ?? '';

    setState(() {
      _dosageUnit = template.dosageUnit;
      _category = template.category;
      _startUseDateYmd = _todayYmd();
      _skippedDates = const [];
      _shareStock = true;
    });
  }

  Future<void> _pickShareSource() async {
    if (_templateOptions.isEmpty) return;

    final l10n = context.l10n;
    final selected = await showModalBottomSheet<SupplementTemplateRef>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        var query = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final trimmed = query.trim();
            final lower = trimmed.toLowerCase();

            final filtered = trimmed.isEmpty
                ? _templateOptions
                : _templateOptions.where((ref) {
                    final s = ref.supplement;
                    return s.name.toLowerCase().contains(lower) ||
                        s.specification.toLowerCase().contains(lower) ||
                        ref.profileName.toLowerCase().contains(lower);
                  }).toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supplementEditorTemplatePickerTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l10n.supplementEditorTemplatePickerSearchHint,
                      ),
                      onChanged: (v) => setState(() => query = v),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                l10n.supplementEditorTemplatePickerEmpty,
                                style: const TextStyle(color: Color(0xFF8A8A8A)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final ref = filtered[index];
                                final s = ref.supplement;
                                final unit = dosageUnitLabel(context, s.dosageUnit, count: s.dailyDosage);
                                final subtitle =
                                    '${ref.profileName} · ${s.specification} · ${s.dailyDosage}$unit · ${categoryLabel(context, s.category)}';

                                return Material(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.of(context).pop(ref),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitle,
                                            style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null) return;
    setState(() => _shareSource = selected);
    _applyShareSource(selected.supplement);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.supplement != null;
    final isSharedUsage = widget.supplement?.stockId != null;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final lockStockFields = isSharedUsage || (!isEditing && _shareStock && _shareSource != null);

    return SafeArea(
      child: Align(
        alignment: isNarrow ? Alignment.center : Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        isEditing ? l10n.supplementEditorTitleEdit : l10n.supplementEditorTitleAdd,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: l10n.supplementEditorTooltipClose,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!isEditing && _templateOptions.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: _pickShareSource,
                              icon: const Icon(Icons.history, size: 18),
                              label: Text(l10n.supplementEditorButtonPickFromExisting),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (!isEditing && _shareSource != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.supplementEditorSharedStockHint(_shareSource!.profileName),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF5A5A5A)),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _name,
                          enabled: !lockStockFields,
                          decoration: InputDecoration(
                            labelText: l10n.supplementEditorFieldNameLabel,
                            hintText: l10n.supplementEditorFieldNameHint,
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.supplementEditorValidationNameRequired : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _spec,
                          enabled: !lockStockFields,
                          decoration: InputDecoration(
                            labelText: l10n.supplementEditorFieldSpecLabel,
                            hintText: l10n.supplementEditorFieldSpecHint,
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.supplementEditorValidationSpecRequired : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dailyDosage,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: l10n.supplementEditorFieldDailyDosageLabel),
                                validator: (v) {
                                  final raw = (v ?? '').trim();
                                  final parsed = int.tryParse(raw);
                                  if (parsed == null || parsed < 1) return l10n.validationNumberMin1;
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _dosageUnit,
                                onChanged: lockStockFields ? null : (v) => setState(() => _dosageUnit = v ?? '粒'),
                                decoration: InputDecoration(labelText: l10n.supplementEditorFieldUnitLabel),
                                items: [
                                  DropdownMenuItem(value: '粒', child: Text(dosageUnitLabel(context, '粒', count: 1))),
                                  DropdownMenuItem(value: '片', child: Text(dosageUnitLabel(context, '片', count: 1))),
                                  DropdownMenuItem(value: '滴', child: Text(dosageUnitLabel(context, '滴', count: 1))),
                                  DropdownMenuItem(value: '勺', child: Text(dosageUnitLabel(context, '勺', count: 1))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _price,
                                enabled: !lockStockFields,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: l10n.supplementEditorFieldPriceLabel,
                                  hintText: l10n.supplementEditorFieldPriceHint,
                                ),
                                validator: (v) {
                                  final raw = (v ?? '').trim();
                                  final parsed = double.tryParse(raw);
                                  if (parsed == null || parsed < 0) return l10n.validationNumberMin0;
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _totalQty,
                                enabled: !lockStockFields,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.supplementEditorFieldTotalQtyLabel,
                                  hintText: l10n.supplementEditorFieldTotalQtyHint,
                                ),
                                validator: (v) {
                                  final raw = (v ?? '').trim();
                                  final parsed = int.tryParse(raw);
                                  if (parsed == null || parsed < 1) return l10n.validationNumberMin1;
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _pickStartUseDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.supplementEditorFieldStartUseDateLabel,
                                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(_startUseDateYmd),
                                ),
                              ),
                            ),
                            if (isEditing) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _postponeOneDayLocal,
                                icon: const Icon(Icons.snooze_outlined, size: 18),
                                label: Text(l10n.supplementEditorButtonSkipToday),
                              ),
                            ],
                          ],
                        ),
                        if (isEditing && _skippedDates.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.supplementEditorSkippedDays(_skippedDates.length),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          onChanged: lockStockFields ? null : (v) => setState(() => _category = v ?? '维生素'),
                          decoration: InputDecoration(labelText: l10n.supplementEditorFieldCategoryLabel),
                          items: [
                            DropdownMenuItem(value: '维生素', child: Text(categoryLabel(context, '维生素'))),
                            DropdownMenuItem(value: '矿物质', child: Text(categoryLabel(context, '矿物质'))),
                            DropdownMenuItem(value: '脂肪酸', child: Text(categoryLabel(context, '脂肪酸'))),
                            DropdownMenuItem(value: '益生菌', child: Text(categoryLabel(context, '益生菌'))),
                            DropdownMenuItem(value: '其他', child: Text(categoryLabel(context, '其他'))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _purchaseUrl,
                          enabled: !lockStockFields,
                          decoration: InputDecoration(
                            labelText: l10n.supplementEditorFieldPurchaseUrlLabel,
                            hintText: l10n.supplementEditorFieldPurchaseUrlHint,
                          ),
                          keyboardType: TextInputType.url,
                          validator: (v) {
                            final raw = (v ?? '').trim();
                            if (raw.isEmpty) return null;
                            final uri = Uri.tryParse(raw);
                            if (uri == null || !(uri.hasScheme && uri.hasAuthority)) return l10n.validationUrlInvalid;
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.commonCancel),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _save,
                        child: Text(l10n.commonSave),
                      ),
                    ],
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
