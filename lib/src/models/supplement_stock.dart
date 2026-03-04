import 'dart:convert';

import 'supplement.dart';

class SupplementStock {
  SupplementStock({
    required this.id,
    required this.name,
    required this.specification,
    required this.dosageUnit,
    required this.price,
    required this.purchaseDate,
    this.purchaseUrl,
    required this.totalQuantity,
    required this.category,
    required this.colorHex,
    List<StockChange>? stockChanges,
  }) : stockChanges = List.unmodifiable((stockChanges ?? const []).toList()
          ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate)));

  final String id;
  final String name;
  final String specification;
  final String dosageUnit;
  final double price;
  final String purchaseDate; // yyyy-MM-dd
  final String? purchaseUrl;
  final int totalQuantity; // baseline quantity at purchase
  final String category;
  final String colorHex;
  final List<StockChange> stockChanges;

  int totalQuantityAt(DateTime day) {
    final ymd = Supplement.formatYmd(Supplement.startOfDay(day));
    var total = totalQuantity;
    for (final c in stockChanges) {
      if (c.effectiveDate.compareTo(ymd) <= 0) {
        total += c.quantityDelta;
      } else {
        break;
      }
    }
    return total < 0 ? 0 : total;
  }

  double get unitCost {
    if (totalQuantity <= 0) return 0;
    if (price <= 0) return 0;
    return price / totalQuantity;
  }

  SupplementStock copyWith({
    String? id,
    String? name,
    String? specification,
    String? dosageUnit,
    double? price,
    String? purchaseDate,
    Object? purchaseUrl = _noChange,
    int? totalQuantity,
    String? category,
    String? colorHex,
    List<StockChange>? stockChanges,
  }) {
    return SupplementStock(
      id: id ?? this.id,
      name: name ?? this.name,
      specification: specification ?? this.specification,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseUrl: identical(purchaseUrl, _noChange) ? this.purchaseUrl : purchaseUrl as String?,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      stockChanges: stockChanges ?? this.stockChanges,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'specification': specification,
        'dosageUnit': dosageUnit,
        'price': price,
        'purchaseDate': purchaseDate,
        if (purchaseUrl != null) 'purchaseUrl': purchaseUrl,
        'totalQuantity': totalQuantity,
        'category': category,
        'color': colorHex,
        if (stockChanges.isNotEmpty) 'stockChanges': stockChanges.map((c) => c.toJson()).toList(),
      };

  static SupplementStock fromJson(Map<String, Object?> json) {
    final rawStock = json['stockChanges'];
    final stock = rawStock is List
        ? rawStock.map(StockChange.tryFromJson).whereType<StockChange>().toList()
        : <StockChange>[];
    stock.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    return SupplementStock(
      id: json['id'] as String,
      name: json['name'] as String,
      specification: json['specification'] as String,
      dosageUnit: json['dosageUnit'] as String,
      price: (json['price'] as num).toDouble(),
      purchaseDate: json['purchaseDate'] as String,
      purchaseUrl: json['purchaseUrl'] as String?,
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      category: json['category'] as String,
      colorHex: json['color'] as String,
      stockChanges: stock,
    );
  }

  static String encodeList(List<SupplementStock> list) {
    return jsonEncode(list.map((s) => s.toJson()).toList());
  }

  static List<SupplementStock> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((m) => SupplementStock.fromJson(m.cast<String, Object?>()))
        .toList();
  }
}

const _noChange = Object();

class SharedStockStats {
  const SharedStockStats({
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.remainingDays,
    required this.remainingPercent,
    required this.dailyCost,
  });

  final int totalQuantity;
  final int remainingQuantity;
  final int remainingDays;
  final double remainingPercent;
  final double dailyCost;

  static SharedStockStats compute({
    required SupplementStock stock,
    required List<Supplement> usages,
    required DateTime today,
    int maxSimDays = 3650,
  }) {
    final day = Supplement.startOfDay(today);

    final stockDeltaByDate = <String, int>{};
    for (final c in stock.stockChanges) {
      stockDeltaByDate[c.effectiveDate] = (stockDeltaByDate[c.effectiveDate] ?? 0) + c.quantityDelta;
    }

    DateTime? earliestStart;
    for (final u in usages) {
      final start = DateTime.tryParse(u.startUseDateYmdForCalc(day));
      if (start == null) continue;
      final startDay = Supplement.startOfDay(start);
      if (earliestStart == null || startDay.isBefore(earliestStart)) {
        earliestStart = startDay;
      }
    }

    earliestStart ??= day;
    final earliestStartYmd = Supplement.formatYmd(earliestStart);

    var remaining = stock.totalQuantity;
    for (final c in stock.stockChanges) {
      if (c.effectiveDate.compareTo(earliestStartYmd) < 0) {
        remaining += c.quantityDelta;
      } else {
        break;
      }
    }
    if (remaining < 0) remaining = 0;

    var cursor = earliestStart;
    final end = Supplement.addDays(day, -1);
    while (!cursor.isAfter(end)) {
      if (remaining <= 0) break;

      final ymd = Supplement.formatYmd(cursor);
      final delta = stockDeltaByDate[ymd];
      if (delta != null) {
        remaining += delta;
        if (remaining < 0) remaining = 0;
      }

      final consume = _dailyDoseTotalOn(usages, cursor);
      if (consume > 0 && remaining >= consume) {
        remaining -= consume;
      }
      cursor = Supplement.addDays(cursor, 1);
    }

    final todayYmd = Supplement.formatYmd(day);
    final todayDelta = stockDeltaByDate[todayYmd];
    if (todayDelta != null) {
      remaining += todayDelta;
      if (remaining < 0) remaining = 0;
    }

    final remainingBeforeToday = remaining;
    final consumeToday = _dailyDoseTotalOn(usages, day);
    final actualConsumeToday = (consumeToday > 0 && remainingBeforeToday >= consumeToday) ? consumeToday : 0;
    final remainingAfterToday = remainingBeforeToday - actualConsumeToday;

    final totalToday = stock.totalQuantityAt(day);
    final percent = totalToday <= 0 ? 0.0 : (remainingAfterToday / totalToday).clamp(0.0, 1.0);
    final dailyCost = stock.unitCost * actualConsumeToday;

    final remainingDays = _simulateRemainingDaysFrom(
      stockDeltaByDate: stockDeltaByDate,
      usages: usages,
      from: Supplement.addDays(day, 1),
      startingRemaining: remainingAfterToday,
      maxDays: maxSimDays,
    );

    return SharedStockStats(
      totalQuantity: totalToday,
      remainingQuantity: remainingAfterToday,
      remainingDays: remainingDays,
      remainingPercent: percent,
      dailyCost: dailyCost,
    );
  }

  static int _dailyDoseTotalOn(List<Supplement> usages, DateTime day) {
    var total = 0;
    for (final u in usages) {
      if (!u.hasStartedBy(day)) continue;
      if (u.isSkippedOn(day)) continue;
      final dose = u.dailyDosageOn(day);
      if (dose <= 0) continue;
      total += dose;
    }
    return total;
  }

  static int _simulateRemainingDaysFrom({
    required Map<String, int> stockDeltaByDate,
    required List<Supplement> usages,
    required DateTime from,
    required int startingRemaining,
    required int maxDays,
  }) {
    if (startingRemaining <= 0) return 0;

    var remaining = startingRemaining;
    var day = Supplement.startOfDay(from);
    for (var i = 0; i < maxDays; i++) {
      if (remaining <= 0) return i;

      final ymd = Supplement.formatYmd(day);
      final delta = stockDeltaByDate[ymd];
      if (delta != null) {
        remaining += delta;
        if (remaining < 0) remaining = 0;
      }

      final consume = _dailyDoseTotalOn(usages, day);
      if (consume > 0) {
        if (remaining < consume) return i;
        remaining -= consume;
      }

      day = Supplement.addDays(day, 1);
    }

    return maxDays;
  }
}
