import 'package:flutter/material.dart';

import '../../controllers/supplements_controller.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';

class ProfileManagerDialog extends StatelessWidget {
  const ProfileManagerDialog({super.key, required this.controller});

  final SupplementsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                      Text(l10n.profileManagerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        tooltip: l10n.profileManagerTooltipClose,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.profileManagerDescription,
                      style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12),
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
                                    tooltip: l10n.profileManagerTooltipRename,
                                    onPressed: () => _renameProfile(context, controller, p.id, p.name),
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                  ),
                                  IconButton(
                                    tooltip: l10n.profileManagerTooltipDelete,
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
                        child: Text(l10n.profileManagerButtonClose),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _addProfile(context, controller),
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: Text(l10n.profileManagerButtonAdd),
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
    final l10n = context.l10n;
    final name = await _askName(
      context,
      title: l10n.profileDialogAddTitle,
      initialValue: '',
      hintText: l10n.profileDialogAddHint,
      confirmText: l10n.profileDialogAddConfirm,
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
    final l10n = context.l10n;
    final name = await _askName(
      context,
      title: l10n.profileDialogRenameTitle,
      initialValue: currentName,
      hintText: l10n.profileDialogRenameHint,
      confirmText: l10n.profileDialogRenameConfirm,
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
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileDialogDeleteTitle),
        content: Text(l10n.profileDialogDeleteContent(name)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel)),
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
