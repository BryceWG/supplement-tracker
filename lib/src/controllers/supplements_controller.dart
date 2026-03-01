import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../models/supplement.dart';
import '../services/supplements_store.dart';

class SupplementsController extends ChangeNotifier {
  SupplementsController({required SupplementsStore store}) : _store = store;

  final SupplementsStore _store;

  bool _initialized = false;
  List<Supplement> _supplements = const [];
  List<Profile> _profiles = const [];
  String? _activeProfileId;

  bool get initialized => _initialized;
  List<Supplement> get supplements => List.unmodifiable(_supplements);
  List<Profile> get profiles => List.unmodifiable(_profiles);

  Profile get activeProfile {
    final id = _activeProfileId;
    if (id == null) return _profiles.first;
    return _profiles.firstWhere((p) => p.id == id, orElse: () => _profiles.first);
  }

  Future<void> _loadFromStore({required bool seedSampleIfEmpty}) async {
    _profiles = await _store.loadProfiles();
    _activeProfileId = await _store.loadActiveProfileId();

    if (_profiles.isEmpty) {
      final me = Profile(id: 'me', name: '我');
      _profiles = [me];
      _activeProfileId = me.id;
      await _store.saveProfiles(_profiles);
      await _store.saveActiveProfileId(me.id);
    }

    if (_activeProfileId == null || !_profiles.any((p) => p.id == _activeProfileId)) {
      _activeProfileId = _profiles.first.id;
      await _store.saveActiveProfileId(_activeProfileId!);
    }

    // Migrate older single-user data into the active profile if needed.
    await _store.migrateLegacySupplementsIfNeeded(_activeProfileId!);

    _supplements = await _store.loadSupplements(
      profileId: _activeProfileId!,
      seedSampleIfEmpty: seedSampleIfEmpty,
    );
    _initialized = true;
    notifyListeners();
  }

  Future<void> init() async {
    await _loadFromStore(seedSampleIfEmpty: true);
  }

  Future<void> reload({bool seedSampleIfEmpty = false}) async {
    await _loadFromStore(seedSampleIfEmpty: seedSampleIfEmpty);
  }

  Future<void> switchProfile(String profileId) async {
    if (_activeProfileId == profileId) return;
    if (!_profiles.any((p) => p.id == profileId)) return;

    _activeProfileId = profileId;
    await _store.saveActiveProfileId(profileId);
    _supplements = await _store.loadSupplements(profileId: profileId);
    notifyListeners();
  }

  Future<void> addProfile(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _profiles = [..._profiles, Profile(id: id, name: trimmed)];
    await _store.saveProfiles(_profiles);

    // Switch to the new profile for convenience.
    await switchProfile(id);
  }

  Future<void> renameProfile(String profileId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index < 0) return;

    _profiles = [
      for (final p in _profiles)
        if (p.id == profileId) Profile(id: p.id, name: trimmed) else p,
    ];
    await _store.saveProfiles(_profiles);
    notifyListeners();
  }

  Future<void> deleteProfile(String profileId) async {
    if (_profiles.length <= 1) return;
    if (!_profiles.any((p) => p.id == profileId)) return;

    final wasActive = _activeProfileId == profileId;
    _profiles = _profiles.where((p) => p.id != profileId).toList();
    await _store.saveProfiles(_profiles);
    await _store.deleteProfileData(profileId);

    if (wasActive) {
      final next = _profiles.first.id;
      _activeProfileId = next;
      await _store.saveActiveProfileId(next);
      _supplements = await _store.loadSupplements(profileId: next);
    }

    notifyListeners();
  }

  Future<void> upsert(Supplement supplement) async {
    final index = _supplements.indexWhere((s) => s.id == supplement.id);
    if (index >= 0) {
      _supplements = [
        for (final s in _supplements) if (s.id == supplement.id) supplement else s,
      ];
    } else {
      _supplements = [..._supplements, supplement];
    }
    await _store.saveSupplements(profileId: activeProfile.id, supplements: _supplements);
    notifyListeners();
  }

  Future<void> removeById(String id) async {
    _supplements = _supplements.where((s) => s.id != id).toList();
    await _store.saveSupplements(profileId: activeProfile.id, supplements: _supplements);
    notifyListeners();
  }

  Future<Supplement?> postponeStartUseOneDay(String supplementId) async {
    final index = _supplements.indexWhere((s) => s.id == supplementId);
    if (index < 0) return null;

    final s = _supplements[index];
    final base = Supplement.parseYmd(s.effectiveStartUseDateYmd);
    final next = base.add(const Duration(days: 1));
    final updated = s.copyWith(startUseDate: Supplement.formatYmd(next));

    _supplements = [
      for (final item in _supplements) if (item.id == supplementId) updated else item,
    ];
    await _store.saveSupplements(profileId: activeProfile.id, supplements: _supplements);
    notifyListeners();
    return updated;
  }

  Future<Supplement?> replenishQuantity(String supplementId, {required int addQuantity}) async {
    if (addQuantity <= 0) return null;

    final index = _supplements.indexWhere((s) => s.id == supplementId);
    if (index < 0) return null;

    final s = _supplements[index];
    final updated = s.copyWith(
      totalQuantity: s.totalQuantity + addQuantity,
      remainingQuantity: s.remainingQuantity + addQuantity,
    );

    await upsert(updated);
    return updated;
  }

  double get dailyCostTotal => _supplements.fold(0, (sum, s) => sum + s.dailyCost);
  double get monthlyCostTotal => dailyCostTotal * 30;

  int get shortestRemainingDays {
    if (_supplements.isEmpty) return 0;
    return _supplements.map((s) => s.remainingDays).reduce((a, b) => a < b ? a : b);
  }

  Future<String> exportBackupJson() async {
    final data = await _store.exportBackup();

    // Ensure the export reflects what the user is currently seeing.
    final active = _activeProfileId;
    final supplementsByProfile = data['supplementsByProfile'];
    if (active != null && supplementsByProfile is Map) {
      supplementsByProfile[active] = _supplements.map((s) => s.toJson()).toList();
    }

    return jsonEncode(data);
  }

  Future<void> importBackupJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('备份文件格式错误');
    }

    await _store.importBackup(decoded.cast<String, Object?>());
    await reload(seedSampleIfEmpty: false);
  }
}
