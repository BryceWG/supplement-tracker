import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';
import '../models/supplement.dart';
import '../sample/sample_data.dart';

class SupplementsStore {
  static const _legacySupplementsKey = 'supplements_v1';
  static const _profilesKey = 'profiles_v1';
  static const _activeProfileKey = 'active_profile_v1';

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
      return seedSampleIfEmpty ? SampleData.supplements() : const [];
    }

    try {
      return Supplement.decodeList(raw);
    } catch (_) {
      return seedSampleIfEmpty ? SampleData.supplements() : const [];
    }
  }

  Future<void> saveSupplements({
    required String profileId,
    required List<Supplement> supplements,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_supplementsKeyForProfile(profileId), Supplement.encodeList(supplements));
  }
}
