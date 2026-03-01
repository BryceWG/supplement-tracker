import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';
import '../models/supplement.dart';

class SupplementsStore {
  static const _legacySupplementsKey = 'supplements_v1';
  static const _profilesKey = 'profiles_v1';
  static const _activeProfileKey = 'active_profile_v1';
  static const _backupFormat = 'supplement_tracker_backup';
  static const _backupVersion = 1;

  static String _supplementsKeyForProfile(String profileId) => 'supplements_v1_profile_$profileId';

  Future<List<Profile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      return Profile.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilesKey, Profile.encodeList(profiles));
  }

  Future<String?> loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey);
  }

  Future<void> saveActiveProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profileId);
  }

  Future<void> deleteProfileData(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_supplementsKeyForProfile(profileId));
  }

  Future<void> migrateLegacySupplementsIfNeeded(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final targetKey = _supplementsKeyForProfile(profileId);
    if (prefs.containsKey(targetKey)) return;

    final legacy = prefs.getString(_legacySupplementsKey);
    if (legacy == null || legacy.trim().isEmpty) return;

    try {
      final list = Supplement.decodeList(legacy);
      await prefs.setString(targetKey, Supplement.encodeList(list));
      await prefs.remove(_legacySupplementsKey);
    } catch (_) {
      // Keep legacy as-is if it's not decodable.
    }
  }

  Future<List<Supplement>> loadSupplements({
    required String profileId,
    bool seedSampleIfEmpty = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_supplementsKeyForProfile(profileId));
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    try {
      return Supplement.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSupplements({
    required String profileId,
    required List<Supplement> supplements,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_supplementsKeyForProfile(profileId), Supplement.encodeList(supplements));
  }

  Future<Map<String, Object?>> exportBackup() async {
    final profiles = await loadProfiles();
    final activeProfileId = await loadActiveProfileId();

    final supplementsByProfile = <String, Object?>{};
    for (final profile in profiles) {
      final list = await loadSupplements(profileId: profile.id, seedSampleIfEmpty: false);
      supplementsByProfile[profile.id] = list.map((s) => s.toJson()).toList();
    }

    return {
      'format': _backupFormat,
      'version': _backupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'profiles': profiles.map((p) => p.toJson()).toList(),
      'activeProfileId': activeProfileId,
      'supplementsByProfile': supplementsByProfile,
    };
  }

  Future<void> importBackup(Map<String, Object?> backup) async {
    final format = backup['format'];
    final version = backup['version'];
    if (format != _backupFormat || version != _backupVersion) {
      throw const FormatException('不支持的备份格式或版本');
    }

    final rawProfiles = backup['profiles'];
    if (rawProfiles is! List) {
      throw const FormatException('备份文件缺少 profiles');
    }

    final profiles = rawProfiles
        .cast<Map<String, dynamic>>()
        .map((m) => Profile.fromJson(m.cast<String, Object?>()))
        .toList();

    if (profiles.isEmpty) {
      throw const FormatException('备份文件 profiles 为空');
    }

    final supplementsByProfile = backup['supplementsByProfile'];
    final supplementsMap = supplementsByProfile is Map ? supplementsByProfile.cast<String, Object?>() : const <String, Object?>{};

    var activeProfileId = backup['activeProfileId'] as String?;
    if (activeProfileId == null || !profiles.any((p) => p.id == activeProfileId)) {
      activeProfileId = profiles.first.id;
    }

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key == _legacySupplementsKey ||
          key == _profilesKey ||
          key == _activeProfileKey ||
          key.startsWith('supplements_v1_profile_')) {
        await prefs.remove(key);
      }
    }

    await saveProfiles(profiles);
    await saveActiveProfileId(activeProfileId);

    for (final profile in profiles) {
      final raw = supplementsMap[profile.id];
      final list = raw is List
          ? raw
              .cast<Map<String, dynamic>>()
              .map((m) => Supplement.fromJson(m.cast<String, Object?>()))
              .toList()
          : const <Supplement>[];
      await saveSupplements(profileId: profile.id, supplements: list);
    }
  }
}
