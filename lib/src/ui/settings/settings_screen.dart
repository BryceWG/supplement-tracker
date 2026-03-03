import 'package:flutter/material.dart';

import '../../controllers/supplements_controller.dart';
import '../../l10n/l10n.dart';
import '../../services/backup/backup_file_service_factory.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final SupplementsController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _fileService = createBackupFileService();

  bool _busy = false;

  String _buildSuggestedFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return 'supplement_tracker_backup_$y$m${d}_$hh$mm$ss.json';
  }

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);

    final l10n = context.l10n;
    try {
      final json = await widget.controller.exportBackupJson();
      final ok = await _fileService.saveJson(
        dialogTitle: l10n.filePickerChooseExportLocation,
        suggestedFileName: _buildSuggestedFileName(),
        json: json,
      );

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSnackExported)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSnackExportFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);

    final l10n = context.l10n;
    try {
      final json = await _fileService.pickJson(dialogTitle: l10n.filePickerChooseImportBackup);
      if (json == null) return;
      if (!mounted) return;

      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.settingsImportConfirmTitle),
          content: Text(l10n.settingsImportConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.settingsImportContinue),
            ),
          ],
        ),
      );

      if (ok != true) return;

      await widget.controller.importBackupJson(json);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSnackImportDone)));
    } catch (e) {
      if (!mounted) return;
      final error = e is FormatException ? l10n.errorInvalidBackup : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSnackImportFailed(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SectionTitle(l10n.settingsSectionData),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsBackupCardTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.settingsBackupCardDescription,
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.60)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _export,
                          icon: const Icon(Icons.upload_file),
                          label: Text(l10n.settingsButtonExport),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _import,
                          icon: const Icon(Icons.download),
                          label: Text(l10n.settingsButtonImport),
                        ),
                      ),
                    ],
                  ),
                  if (_busy) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}
