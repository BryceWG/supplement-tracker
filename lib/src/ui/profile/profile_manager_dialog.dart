import 'package:flutter/material.dart';

import '../../controllers/supplements_controller.dart';
import '../../theme/app_theme.dart';

class ProfileManagerDialog extends StatelessWidget {
  const ProfileManagerDialog({super.key, required this.controller});

  final SupplementsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final profiles = controller.profiles;
        final activeId = controller.activeProfile.id;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('成员管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        tooltip: '关闭',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '每个成员的数据相互独立，可随时切换。',
                      style: TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: profiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = profiles[index];
                        final isActive = p.id == activeId;

                        return Material(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              await controller.switchProfile(p.id);
                              if (context.mounted) Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: isActive ? AppTheme.primary : const Color(0xFF8A8A8A),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      p.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isActive ? AppTheme.primary : const Color(0xFF1D1D1D),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: '重命名',
                                    onPressed: () => _renameProfile(context, controller, p.id, p.name),
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                  ),
                                  IconButton(
                                    tooltip: '删除',
                                    onPressed: profiles.length <= 1
                                        ? null
                                        : () => _confirmDelete(context, controller, p.id, p.name),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: profiles.length <= 1 ? const Color(0xFFBDBDBD) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('关闭'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _addProfile(context, controller),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('添加成员'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _addProfile(BuildContext context, SupplementsController controller) async {
    final name = await _askName(
      context,
      title: '添加成员',
      initialValue: '',
      hintText: '例如：妈妈 / 朋友 / 伴侣',
      confirmText: '添加并切换',
    );
    if (name == null) return;
    await controller.addProfile(name);
    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> _renameProfile(
    BuildContext context,
    SupplementsController controller,
    String profileId,
    String currentName,
  ) async {
    final name = await _askName(
      context,
      title: '重命名成员',
      initialValue: currentName,
      hintText: '请输入成员名称',
      confirmText: '保存',
    );
    if (name == null) return;
    await controller.renameProfile(profileId, name);
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    SupplementsController controller,
    String profileId,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('删除「$name」后，该成员的补剂数据也会一并删除。'),
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
      await controller.deleteProfile(profileId);
    }
  }

  static Future<String?> _askName(
    BuildContext context, {
    required String title,
    required String initialValue,
    required String hintText,
    required String confirmText,
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hintText),
          onSubmitted: (_) => Navigator.pop(context, controller.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result == null) return null;
    final trimmed = result.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}

