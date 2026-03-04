import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../models/supplement.dart';
import '../models/supplement_stock.dart';
import '../models/supplement_template_ref.dart';
import '../services/supplements_store.dart';

class SupplementsController extends ChangeNotifier {
  SupplementsController({
    required SupplementsStore store,
    required String defaultProfileName,
  })  : _store = store,
        _defaultProfileName = defaultProfileName;

  final SupplementsStore _store;
  final String _defaultProfileName;

  bool _initialized = false;
  List<Supplement> _supplements = const [];
  List<Profile> _profiles = const [];
  String? _activeProfileId;
  List<SupplementStock> _stocks = const [];
  Map<String, SharedStockStats> _sharedStockStats = const {};

  bool get initialized => _initialized;
  List<Supplement> get supplements => List.unmodifiable(_supplements);
  List<Profile> get profiles => List.unmodifiable(_profiles);
  List<SupplementStock> get stocks => List.unmodifiable(_stocks);

  SharedStockStats? sharedStatsForStockId(String stockId) => _sharedStockStats[stockId];
  SupplementStock? stockById(String stockId) {
    for (final s in _stocks) {
      if (s.id == stockId) return s;
    }
    return null;
  }

  int remainingDaysForSupplement(Supplement s) {
    final stockId = s.stockId;
    if (stockId == null) return s.remainingDays;
    return _sharedStockStats[stockId]?.remainingDays ?? s.remainingDays;
  }

  int remainingQuantityForSupplement(Supplement s) {
    final stockId = s.stockId;
    if (stockId == null) return s.estimatedRemainingQuantity;
    return _sharedStockStats[stockId]?.remainingQuantity ?? s.estimatedRemainingQuantity;
  }

  int totalQuantityForSupplement(Supplement s) {
    final stockId = s.stockId;
    if (stockId == null) return s.totalQuantityAt(DateTime.now());
    return _sharedStockStats[stockId]?.totalQuantity ?? s.totalQuantityAt(DateTime.now());
  }

  double remainingPercentForSupplement(Supplement s) {
    final stockId = s.stockId;
    if (stockId == null) return s.remainingPercent;
    return _sharedStockStats[stockId]?.remainingPercent ?? s.remainingPercent;
  }

  double dailyCostForSupplement(Supplement s) {
    final stockId = s.stockId;
    if (stockId == null) return s.dailyCost;
    return _sharedStockStats[stockId]?.dailyCost ?? s.dailyCost;
  }

  Profile get activeProfile {
    final id = _activeProfileId;
    if (id == null) return _profiles.first;
    return _profiles.firstWhere((p) => p.id == id, orElse: () => _profiles.first);
  }

  Future<void> _loadFromStore({required bool seedSampleIfEmpty}) async {
    _profiles = await _store.loadProfiles();
    _activeProfileId = await _store.loadActiveProfileId();

    if (_profiles.isEmpty) {
      final me = Profile(id: 'me', name: _defaultProfileName);
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
    _stocks = await _store.loadStocks();
    await _recomputeSharedStockStats(notify: false);
    _initialized = true;
    notifyListeners();
  }

  Future<void> _recomputeSharedStockStats({required bool notify}) async {
    if (_stocks.isEmpty || _profiles.isEmpty) {
      _sharedStockStats = const {};
      if (notify) notifyListeners();
      return;
    }

    final activeId = _activeProfileId ?? activeProfile.id;
    final all = <Supplement>[];
    for (final p in _profiles) {
      if (p.id == activeId) {
        all.addAll(_supplements);
      } else {
        all.addAll(await _store.loadSupplements(profileId: p.id));
      }
    }

    final byStockId = <String, List<Supplement>>{};
    for (final s in all) {
      final stockId = s.stockId;
      if (stockId == null) continue;
      (byStockId[stockId] ??= []).add(s);
    }

    final today = DateTime.now();
    final map = <String, SharedStockStats>{};
    for (final stock in _stocks) {
      final usages = byStockId[stock.id];
      if (usages == null || usages.isEmpty) continue;
      map[stock.id] = SharedStockStats.compute(stock: stock, usages: usages, today: today);
    }

    _sharedStockStats = map;
    if (notify) notifyListeners();
  }

  Future<void> init() async {
    await _loadFromStore(seedSampleIfEmpty: false);
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
    _stocks = await _store.loadStocks();
    await _recomputeSharedStockStats(notify: false);
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

    _stocks = await _store.loadStocks();
    await _recomputeSharedStockStats(notify: false);
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
    _stocks = await _store.loadStocks();
    await _recomputeSharedStockStats(notify: false);
    notifyListeners();
  }

  Future<void> removeById(String id) async {
    _supplements = _supplements.where((s) => s.id != id).toList();
    await _store.saveSupplements(profileId: activeProfile.id, supplements: _supplements);
    _stocks = await _store.loadStocks();
    await _recomputeSharedStockStats(notify: false);
    notifyListeners();
  }

  Future<Supplement?> postponeStartUseOneDay(String supplementId, {DateTime? today}) async {
    final index = _supplements.indexWhere((s) => s.id == supplementId);
    if (index < 0) return null;

    final s = _supplements[index];
    final now = today ?? DateTime.now();
    final todayDay = Supplement.startOfDay(now);

    final start = DateTime.tryParse(s.startUseDate ?? '');
    final startDay = Supplement.startOfDay(start ?? todayDay);

    // If the supplement hasn't started yet, postponing means moving the start day later.
    // If it has started, postponing means "skip today" (do not consume today).
    final Supplement updated;
    if (start == null || todayDay.isBefore(startDay)) {
      final next = Supplement.addDays(startDay, 1);
      updated = s.copyWith(startUseDate: Supplement.formatYmd(next));
    } else {
      final ymd = Supplement.formatYmd(todayDay);
      final set = {...s.skippedDates, ymd};
      final list = set.toList()..sort();
      updated = s.copyWith(skippedDates: list);
    }

    _supplements = [
      for (final item in _supplements) if (item.id == supplementId) updated else item,
    ];
    await _store.saveSupplements(profileId: activeProfile.id, supplements: _supplements);
    await _recomputeSharedStockStats(notify: false);
    notifyListeners();
    return updated;
  }

  Future<Supplement?> replenishQuantity(
    String supplementId, {
    required int addQuantity,
    DateTime? today,
  }) async {
    if (addQuantity <= 0) return null;

    final index = _supplements.indexWhere((s) => s.id == supplementId);
    if (index < 0) return null;

    final s = _supplements[index];
    final now = today ?? DateTime.now();
    final ymd = Supplement.formatYmd(Supplement.startOfDay(now));
    final stockId = s.stockId;
    if (stockId != null) {
      final stocks = await _store.loadStocks();
      final stockIndex = stocks.indexWhere((st) => st.id == stockId);
      if (stockIndex < 0) return null;

      final stock = stocks[stockIndex];
      final updatedStock = stock.copyWith(
        stockChanges: [...stock.stockChanges, StockChange(effectiveDate: ymd, quantityDelta: addQuantity)],
      );
      final nextStocks = [...stocks]..[stockIndex] = updatedStock;
      await _store.saveStocks(nextStocks);
      _stocks = nextStocks;
      await _recomputeSharedStockStats(notify: false);
      notifyListeners();
      return s;
    }

    final updated = s.copyWith(stockChanges: [...s.stockChanges, StockChange(effectiveDate: ymd, quantityDelta: addQuantity)]);

    await upsert(updated);
    return updated;
  }

  double dailyCostTotalAt(DateTime day) {
    return _supplements.fold(0, (sum, s) => sum + s.dailyCostOn(day));
  }

  double monthlyCostTotalFrom(DateTime from, {int days = 30}) {
    var total = 0.0;
    for (final s in _supplements) {
      total += s.costForNextDays(from: from, days: days);
    }
    return total;
  }

  double get dailyCostTotal => dailyCostTotalAt(DateTime.now());
  double get monthlyCostTotal => monthlyCostTotalFrom(DateTime.now(), days: 30);

  int get shortestRemainingDays {
    if (_supplements.isEmpty) return 0;
    return _supplements.map(remainingDaysForSupplement).reduce((a, b) => a < b ? a : b);
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

  Future<List<SupplementTemplateRef>> loadAllSupplementsAcrossProfiles() async {
    if (!_initialized) return const [];

    final activeId = _activeProfileId ?? activeProfile.id;
    final all = <SupplementTemplateRef>[];
    for (final p in _profiles) {
      final profileName = p.name;
      if (p.id == activeId) {
        all.addAll(_supplements.map((s) => SupplementTemplateRef(profileId: p.id, profileName: profileName, supplement: s)));
      } else {
        final list = await _store.loadSupplements(profileId: p.id);
        all.addAll(list.map((s) => SupplementTemplateRef(profileId: p.id, profileName: profileName, supplement: s)));
      }
    }
    return all;
  }

  Future<void> addSharedUsageFromTemplate({
    required SupplementTemplateRef source,
    required Supplement targetDraft,
  }) async {
    final stockId = await _ensureSharedStockFor(sourceProfileId: source.profileId, sourceSupplementId: source.supplement.id);
    final stock = _stocks.firstWhere((s) => s.id == stockId);

    final existingIndex = _supplements.indexWhere((s) => s.stockId == stockId);
    final usage = targetDraft.copyWith(
      name: stock.name,
      specification: stock.specification,
      dosageUnit: stock.dosageUnit,
      price: stock.price,
      purchaseDate: stock.purchaseDate,
      purchaseUrl: stock.purchaseUrl,
      category: stock.category,
      colorHex: stock.colorHex,
      stockId: stockId,
      stockChanges: const <StockChange>[],
      totalQuantity: stock.totalQuantity,
    );

    if (existingIndex >= 0) {
      final existing = _supplements[existingIndex];
      final updated = usage.copyWith(id: existing.id);
      await upsert(updated);
      return;
    }

    await upsert(usage);
  }

  Future<String> _ensureSharedStockFor({
    required String sourceProfileId,
    required String sourceSupplementId,
  }) async {
    final stocks = await _store.loadStocks();

    List<Supplement> sourceList;
    final activeId = _activeProfileId ?? activeProfile.id;
    if (sourceProfileId == activeId) {
      sourceList = [..._supplements];
    } else {
      sourceList = await _store.loadSupplements(profileId: sourceProfileId);
    }

    final index = sourceList.indexWhere((s) => s.id == sourceSupplementId);
    if (index < 0) {
      throw StateError('Source supplement not found');
    }

    final source = sourceList[index];
    final existingStockId = source.stockId;
    if (existingStockId != null && stocks.any((s) => s.id == existingStockId)) {
      _stocks = stocks;
      return existingStockId;
    }

    final newStockId = 'stock_${DateTime.now().microsecondsSinceEpoch}';
    final stock = SupplementStock(
      id: newStockId,
      name: source.name,
      specification: source.specification,
      dosageUnit: source.dosageUnit,
      price: source.price,
      purchaseDate: source.purchaseDate,
      purchaseUrl: source.purchaseUrl,
      totalQuantity: source.totalQuantity,
      category: source.category,
      colorHex: source.colorHex,
      stockChanges: source.stockChanges,
    );

    final nextStocks = [...stocks, stock];
    await _store.saveStocks(nextStocks);

    final updatedSource = source.copyWith(
      stockId: newStockId,
      stockChanges: const <StockChange>[],
    );
    sourceList = [
      for (final s in sourceList) if (s.id == sourceSupplementId) updatedSource else s,
    ];
    await _store.saveSupplements(profileId: sourceProfileId, supplements: sourceList);

    if (sourceProfileId == activeId) {
      _supplements = sourceList;
    }

    _stocks = nextStocks;
    await _recomputeSharedStockStats(notify: false);
    notifyListeners();
    return newStockId;
  }
}
