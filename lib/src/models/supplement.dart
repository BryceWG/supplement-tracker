import 'dart:convert';

import '../util/colors.dart';

const _noChange = Object();

class DosageChange {
  const DosageChange({
    required this.effectiveDate,
    required this.dailyDosage,
  });

  /// yyyy-MM-dd
  final String effectiveDate;

  final int dailyDosage;

  Map<String, Object?> toJson() => {
        'effectiveDate': effectiveDate,
        'dailyDosage': dailyDosage,
      };

  static DosageChange? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final date = raw['effectiveDate'];
    final dosage = raw['dailyDosage'];
    if (date is! String) return null;
    if (dosage is! num) return null;

    final parsed = DateTime.tryParse(date);
    if (parsed == null) return null;
    final normalized = Supplement.formatYmd(Supplement.startOfDay(parsed));

    final dailyDosage = dosage.toInt();
    if (dailyDosage <= 0) return null;
    return DosageChange(effectiveDate: normalized, dailyDosage: dailyDosage);
  }
}

class StockChange {
  const StockChange({
    required this.effectiveDate,
    required this.quantityDelta,
  });

  /// yyyy-MM-dd
  final String effectiveDate;

  /// Positive means replenish; negative means adjust down (e.g. correction/loss).
  final int quantityDelta;

  Map<String, Object?> toJson() => {
        'effectiveDate': effectiveDate,
        'quantityDelta': quantityDelta,
      };

  static StockChange? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final date = raw['effectiveDate'];
    final qty = raw['quantityDelta'];
    if (date is! String) return null;
    if (qty is! num) return null;

    final parsed = DateTime.tryParse(date);
    if (parsed == null) return null;
    final normalized = Supplement.formatYmd(Supplement.startOfDay(parsed));

    final delta = qty.toInt();
    if (delta == 0) return null;
    return StockChange(effectiveDate: normalized, quantityDelta: delta);
  }
}

class Supplement {
  Supplement({
    required this.id,
    required this.name,
    required this.specification,
    required this.dailyDosage,
    required this.dosageUnit,
    required this.price,
    required this.purchaseDate,
    this.startUseDate,
    this.purchaseUrl,
    this.stockId,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.category,
    required this.colorHex,
    List<String>? skippedDates,
    List<DosageChange>? dosageChanges,
    List<StockChange>? stockChanges,
  })  : skippedDates = List.unmodifiable(skippedDates ?? const []),
        dosageChanges = List.unmodifiable((dosageChanges ?? const []).toList()
          ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate))),
        stockChanges = List.unmodifiable((stockChanges ?? const []).toList()
          ..sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate)));

  final String id;
  final String name;
  final String specification;
  final int dailyDosage;
  final String dosageUnit;
  final double price;
  final String purchaseDate; // yyyy-MM-dd
  final String? startUseDate; // yyyy-MM-dd
  final String? purchaseUrl;
  final String? stockId;
  final int totalQuantity;
  final int remainingQuantity;
  final String category;
  final String colorHex;
  final List<String> skippedDates;
  final List<DosageChange> dosageChanges;
  final List<StockChange> stockChanges;

  String get effectiveStartUseDateYmd => startUseDate ?? purchaseDate;

  String startUseDateYmdForCalc(DateTime today) {
    // Legacy data might not have `startUseDate`. In that case, treat it as "not started yet",
    // so remaining days won't suddenly drop just because `purchaseDate` is old.
    return startUseDate ?? formatYmd(today);
  }

  static DateTime parseYmd(String ymd) => DateTime.parse(ymd);

  static String formatYmd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Supplement copyWith({
    String? id,
    String? name,
    String? specification,
    int? dailyDosage,
    String? dosageUnit,
    double? price,
    String? purchaseDate,
    Object? startUseDate = _noChange,
    Object? purchaseUrl = _noChange,
    Object? stockId = _noChange,
    int? totalQuantity,
    int? remainingQuantity,
    String? category,
    String? colorHex,
    Object? skippedDates = _noChange,
    Object? dosageChanges = _noChange,
    Object? stockChanges = _noChange,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      specification: specification ?? this.specification,
      dailyDosage: dailyDosage ?? this.dailyDosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      startUseDate: identical(startUseDate, _noChange) ? this.startUseDate : startUseDate as String?,
      purchaseUrl: identical(purchaseUrl, _noChange) ? this.purchaseUrl : purchaseUrl as String?,
      stockId: identical(stockId, _noChange) ? this.stockId : stockId as String?,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      skippedDates: identical(skippedDates, _noChange) ? this.skippedDates : skippedDates as List<String>?,
      dosageChanges: identical(dosageChanges, _noChange) ? this.dosageChanges : dosageChanges as List<DosageChange>?,
      stockChanges: identical(stockChanges, _noChange) ? this.stockChanges : stockChanges as List<StockChange>?,
    );
  }

  int totalQuantityAt(DateTime day) {
    if (stockChanges.isEmpty) return totalQuantity;
    final ymd = formatYmd(startOfDay(day));
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

  double get dailyCost {
    return unitCost * dailyDosageOn(DateTime.now());
  }

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime addDays(DateTime day, int days) {
    final d = startOfDay(day);
    return DateTime(d.year, d.month, d.day + days);
  }

  bool isSkippedOn(DateTime day) {
    if (skippedDates.isEmpty) return false;
    final ymd = formatYmd(startOfDay(day));
    return skippedDates.contains(ymd);
  }

  bool hasStartedBy(DateTime day) {
    final start = DateTime.tryParse(startUseDateYmdForCalc(day));
    if (start == null) return false;
    return !startOfDay(day).isBefore(startOfDay(start));
  }

  int dailyDosageOn(DateTime day) {
    if (dosageChanges.isEmpty) return dailyDosage;

    final ymd = formatYmd(startOfDay(day));
    DosageChange? selected;
    for (final c in dosageChanges) {
      if (c.effectiveDate.compareTo(ymd) <= 0) {
        selected = c;
      } else {
        break;
      }
    }
    return selected?.dailyDosage ?? dailyDosage;
  }

  int estimatedRemainingQuantityBeforeConsumptionAt(DateTime day) {
    final start = DateTime.tryParse(startUseDateYmdForCalc(day));
    if (start == null) return totalQuantityAt(day);

    final startDay = startOfDay(start);
    final dayDay = startOfDay(day);
    if (dayDay.isBefore(startDay)) return totalQuantityAt(day);

    final skipped = skippedDates.isEmpty ? const <String>{} : skippedDates.toSet();

    final stockDeltaByDate = <String, int>{};
    for (final c in stockChanges) {
      stockDeltaByDate[c.effectiveDate] = (stockDeltaByDate[c.effectiveDate] ?? 0) + c.quantityDelta;
    }

    final startYmd = formatYmd(startDay);
    var remaining = totalQuantity;
    for (final c in stockChanges) {
      if (c.effectiveDate.compareTo(startYmd) < 0) {
        remaining += c.quantityDelta;
      } else {
        break;
      }
    }
    if (remaining < 0) remaining = 0;

    var cursor = startDay;
    final endDay = addDays(dayDay, -1);
    while (!cursor.isAfter(endDay)) {
      if (remaining <= 0) break;
      final cursorYmd = formatYmd(cursor);
      final delta = stockDeltaByDate[cursorYmd];
      if (delta != null) {
        remaining += delta;
        if (remaining < 0) remaining = 0;
      }
      if (!skipped.contains(cursorYmd)) {
        final dose = dailyDosageOn(cursor);
        if (dose > 0 && remaining >= dose) {
          remaining -= dose;
        }
      }
      cursor = addDays(cursor, 1);
    }

    final dayYmd = formatYmd(dayDay);
    final dayDelta = stockDeltaByDate[dayYmd];
    if (dayDelta != null) {
      remaining += dayDelta;
      if (remaining < 0) remaining = 0;
    }

    return remaining;
  }

  bool canConsumeOn(DateTime day) {
    final dose = dailyDosageOn(day);
    if (dose <= 0) return false;
    if (!hasStartedBy(day)) return false;
    if (isSkippedOn(day)) return false;
    return estimatedRemainingQuantityBeforeConsumptionAt(day) >= dose;
  }

  double dailyCostOn(DateTime day) {
    final dose = dailyDosageOn(day);
    if (dose <= 0) return 0;
    if (totalQuantity <= 0) return 0;
    if (!hasStartedBy(day)) return 0;
    if (isSkippedOn(day)) return 0;

    final remainingBefore = estimatedRemainingQuantityBeforeConsumptionAt(day);
    if (remainingBefore < dose) return 0;

    return unitCost * dose;
  }

  double costForNextDays({required DateTime from, required int days}) {
    if (days <= 0) return 0;

    final start = startOfDay(from);
    var remaining = estimatedRemainingQuantityBeforeConsumptionAt(start);
    if (remaining <= 0) return 0;

    final skipped = skippedDates.isEmpty ? const <String>{} : skippedDates.toSet();
    final stockDeltaByDate = <String, int>{};
    for (final c in stockChanges) {
      stockDeltaByDate[c.effectiveDate] = (stockDeltaByDate[c.effectiveDate] ?? 0) + c.quantityDelta;
    }
    var total = 0.0;
    for (var i = 0; i < days; i++) {
      final day = addDays(start, i);
      if (!hasStartedBy(day)) continue;

      final ymd = formatYmd(day);
      if (i > 0) {
        final delta = stockDeltaByDate[ymd];
        if (delta != null) {
          remaining += delta;
          if (remaining < 0) remaining = 0;
        }
      }
      if (skipped.contains(ymd)) continue;

      final dose = dailyDosageOn(day);
      if (dose <= 0) continue;
      if (remaining < dose) continue;

      total += unitCost * dose;
      remaining -= dose;
      if (remaining <= 0) break;
    }
    return total;
  }

  int estimatedRemainingQuantityAt(DateTime today) {
    final remainingBefore = estimatedRemainingQuantityBeforeConsumptionAt(today);
    if (remainingBefore <= 0) return 0;
    if (!hasStartedBy(today)) return remainingBefore;
    if (isSkippedOn(today)) return remainingBefore;

    final dose = dailyDosageOn(today);
    if (dose <= 0) return remainingBefore;
    if (remainingBefore < dose) return remainingBefore;
    return remainingBefore - dose;
  }

  int remainingDaysAt(DateTime today) {
    final dose = dailyDosageOn(today);
    if (dose <= 0) return 0;
    return (estimatedRemainingQuantityAt(today) / dose).floor();
  }

  double remainingPercentAt(DateTime today) {
    final denom = totalQuantityAt(today);
    if (denom <= 0) return 0;
    return estimatedRemainingQuantityAt(today) / denom;
  }

  int get estimatedRemainingQuantity => estimatedRemainingQuantityAt(DateTime.now());

  int get remainingDays {
    return remainingDaysAt(DateTime.now());
  }

  double get remainingPercent {
    return remainingPercentAt(DateTime.now());
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'specification': specification,
        'dailyDosage': dailyDosage,
        'dosageUnit': dosageUnit,
        'price': price,
        'purchaseDate': purchaseDate,
        if (startUseDate != null) 'startUseDate': startUseDate,
        if (purchaseUrl != null) 'purchaseUrl': purchaseUrl,
        if (stockId != null) 'stockId': stockId,
        'totalQuantity': totalQuantity,
        'remainingQuantity': remainingQuantity,
        'category': category,
        'color': colorHex,
        if (skippedDates.isNotEmpty) 'skippedDates': skippedDates,
        if (dosageChanges.isNotEmpty) 'dosageChanges': dosageChanges.map((c) => c.toJson()).toList(),
        if (stockChanges.isNotEmpty) 'stockChanges': stockChanges.map((c) => c.toJson()).toList(),
      };

  static Supplement fromJson(Map<String, Object?> json) {
    final category = json['category'] as String;
    final skipped = (json['skippedDates'] as List?)?.cast<String>();
    final rawChanges = json['dosageChanges'];
    final changes = rawChanges is List
        ? rawChanges.map(DosageChange.tryFromJson).whereType<DosageChange>().toList()
        : <DosageChange>[];
    changes.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));

    final rawStock = json['stockChanges'];
    final stock = rawStock is List
        ? rawStock.map(StockChange.tryFromJson).whereType<StockChange>().toList()
        : <StockChange>[];
    stock.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
    return Supplement(
      id: json['id'] as String,
      name: json['name'] as String,
      specification: json['specification'] as String,
      dailyDosage: (json['dailyDosage'] as num).toInt(),
      dosageUnit: json['dosageUnit'] as String,
      price: (json['price'] as num).toDouble(),
      purchaseDate: json['purchaseDate'] as String,
      startUseDate: json['startUseDate'] as String?,
      purchaseUrl: json['purchaseUrl'] as String?,
      stockId: json['stockId'] as String?,
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      category: category,
      colorHex: (json['color'] as String?) ?? CategoryColors.hexForCategory(category),
      skippedDates: skipped,
      dosageChanges: changes,
      stockChanges: stock,
    );
  }

  static String encodeList(List<Supplement> list) {
    return jsonEncode(list.map((s) => s.toJson()).toList());
  }

  static List<Supplement> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((m) => Supplement.fromJson(m.cast<String, Object?>()))
        .toList();
  }
}
