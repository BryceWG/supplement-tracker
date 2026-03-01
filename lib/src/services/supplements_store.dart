import 'package:shared_preferences/shared_preferences.dart';

import '../models/supplement.dart';
import '../sample/sample_data.dart';

class SupplementsStore {
  static const _key = 'supplements_v1';

  Future<List<Supplement>> loadSupplements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return SampleData.supplements();
    }

    try {
      return Supplement.decodeList(raw);
    } catch (_) {
      return SampleData.supplements();
    }
  }

  Future<void> saveSupplements(List<Supplement> supplements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Supplement.encodeList(supplements));
  }
}

