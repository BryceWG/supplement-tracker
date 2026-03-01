import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/supplement.dart';
import '../../theme/app_theme.dart';
import '../../util/colors.dart';

class SupplementEditorDialog extends StatefulWidget {
  const SupplementEditorDialog({super.key, this.supplement});

  final Supplement? supplement;

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

  @override
  void initState() {
    super.initState();
    final s = widget.supplement;
    _name = TextEditingController(text: s?.name ?? '');
    _spec = TextEditingController(text: s?.specification ?? '');
    _dailyDosage = TextEditingController(text: (s?.dailyDosage ?? 1).toString());
    _price = TextEditingController(text: (s?.price ?? '').toString());
    _totalQty = TextEditingController(text: (s?.totalQuantity ?? '').toString());
    _purchaseUrl = TextEditingController(text: s?.purchaseUrl ?? '');

    _dosageUnit = s?.dosageUnit ?? '粒';
    _category = s?.category ?? '维生素';
    _startUseDateYmd = s?.startUseDate ?? s?.purchaseDate ?? _todayYmd();
    _skippedDates = [...(s?.skippedDates ?? const [])];
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
    final initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10),
      helpText: '选择开始使用日期',
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

    final colorHex = existing?.colorHex ?? CategoryColors.hexForCategory(_category);
    final id = existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final purchaseUrl = _purchaseUrl.text.trim();

    final purchaseDate = existing?.purchaseDate ?? _todayYmd();
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
      totalQuantity: totalQty,
      remainingQuantity: existing == null ? totalQty : min(existing.remainingQuantity, totalQty),
      category: _category,
      colorHex: colorHex,
      skippedDates: _skippedDates,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplement != null;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

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
                        isEditing ? '编辑补剂' : '添加补剂',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: '关闭',
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
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: '补剂名称', hintText: '例如：维生素D3'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入补剂名称' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _spec,
                          decoration: const InputDecoration(labelText: '规格', hintText: '例如：2000IU, 180粒'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入规格' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dailyDosage,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: '每日服用量'),
                                validator: (v) {
                                  final raw = (v ?? '').trim();
                                  final parsed = int.tryParse(raw);
                                  if (parsed == null || parsed < 1) return '请输入 >= 1 的数字';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _dosageUnit,
                                decoration: const InputDecoration(labelText: '单位'),
                                items: const [
                                  DropdownMenuItem(value: '粒', child: Text('粒')),
                                  DropdownMenuItem(value: '片', child: Text('片')),
                                  DropdownMenuItem(value: '滴', child: Text('滴')),
                                  DropdownMenuItem(value: '勺', child: Text('勺')),
                                ],
                                onChanged: (v) => setState(() => _dosageUnit = v ?? '粒'),
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
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: '购买价格 (¥)', hintText: '128'),
                                validator: (v) {
                                  final raw = (v ?? '').trim();
                                  final parsed = double.tryParse(raw);
                                  if (parsed == null || parsed < 0) return '请输入 >= 0 的数字';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _totalQty,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: '总数量', hintText: '180'),
                                validator: (v) {
                                  final raw = (v ?? '').trim();
                                  final parsed = int.tryParse(raw);
                                  if (parsed == null || parsed < 1) return '请输入 >= 1 的数字';
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
                                  decoration: const InputDecoration(
                                    labelText: '开始使用日期',
                                    suffixIcon: Icon(Icons.calendar_today_outlined),
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
                                label: const Text('跳过今天'),
                              ),
                            ],
                          ],
                        ),
                        if (isEditing && _skippedDates.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '已跳过 ${_skippedDates.length} 天',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(labelText: '分类'),
                          items: const [
                            DropdownMenuItem(value: '维生素', child: Text('维生素')),
                            DropdownMenuItem(value: '矿物质', child: Text('矿物质')),
                            DropdownMenuItem(value: '脂肪酸', child: Text('脂肪酸')),
                            DropdownMenuItem(value: '益生菌', child: Text('益生菌')),
                            DropdownMenuItem(value: '其他', child: Text('其他')),
                          ],
                          onChanged: (v) => setState(() => _category = v ?? '维生素'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _purchaseUrl,
                          decoration: const InputDecoration(labelText: '购买链接（可选）', hintText: 'https://...'),
                          keyboardType: TextInputType.url,
                          validator: (v) {
                            final raw = (v ?? '').trim();
                            if (raw.isEmpty) return null;
                            final uri = Uri.tryParse(raw);
                            if (uri == null || !(uri.hasScheme && uri.hasAuthority)) return '请输入有效的链接（包含 http/https）';
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
                        child: const Text('取消'),
                      ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _save,
                        child: const Text('保存'),
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
