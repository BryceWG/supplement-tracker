import 'package:flutter/foundation.dart';

import '../models/supplement.dart';
import '../services/supplements_store.dart';

class SupplementsController extends ChangeNotifier {
  SupplementsController({required SupplementsStore store}) : _store = store;

  final SupplementsStore _store;

  bool _initialized = false;
  List<Supplement> _supplements = const [];

  bool get initialized => _initialized;
  List<Supplement> get supplements => List.unmodifiable(_supplements);

  Future<void> init() async {
    _supplements = await _store.loadSupplements();
    _initialized = true;
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
    await _store.saveSupplements(_supplements);
    notifyListeners();
  }

  Future<void> removeById(String id) async {
    _supplements = _supplements.where((s) => s.id != id).toList();
    await _store.saveSupplements(_supplements);
    notifyListeners();
  }

  double get dailyCostTotal => _supplements.fold(0, (sum, s) => sum + s.dailyCost);
  double get monthlyCostTotal => dailyCostTotal * 30;

  int get shortestRemainingDays {
    if (_supplements.isEmpty) return 0;
    return _supplements.map((s) => s.remainingDays).reduce((a, b) => a < b ? a : b);
  }
}

