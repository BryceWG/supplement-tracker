import 'dart:convert';

import '../util/colors.dart';

const _noChange = Object();

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
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.category,
    required this.colorHex,
    List<String>? skippedDates,
  }) : skippedDates = List.unmodifiable(skippedDates ?? const []);

  final String id;
  final String name;
  final String specification;
  final int dailyDosage;
  final String dosageUnit;
  final double price;
  final String purchaseDate; // yyyy-MM-dd
  final String? startUseDate; // yyyy-MM-dd
  final String? purchaseUrl;
  final int totalQuantity;
  final int remainingQuantity;
  final String category;
  final String colorHex;
  final List<String> skippedDates;

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
    int? totalQuantity,
    int? remainingQuantity,
    String? category,
    String? colorHex,
    Object? skippedDates = _noChange,
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
      totalQuantity: totalQuantity ?? this.totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      skippedDates: identical(skippedDates, _noChange) ? this.skippedDates : skippedDates as List<String>?,
    );
  }

  double get dailyCost {
    final daysSupply = totalQuantity / dailyDosage;
    if (daysSupply <= 0) return 0;
    return price / daysSupply;
  }

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

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

  bool canConsumeOn(DateTime day) {
    if (dailyDosage <= 0) return false;
    if (!hasStartedBy(day)) return false;
    if (isSkippedOn(day)) return false;
    return estimatedRemainingQuantityAt(day) >= dailyDosage;
  }

  double dailyCostOn(DateTime day) {
    if (!canConsumeOn(day)) return 0;
    return dailyCost;
  }

  double costForNextDays({required DateTime from, required int days}) {
    if (days <= 0) return 0;

    final start = startOfDay(from);
    var total = 0.0;
    for (var i = 0; i < days; i++) {
      total += dailyCostOn(start.add(Duration(days: i)));
    }
    return total;
  }

  int usedDaysAt(DateTime today) {
    final start = DateTime.tryParse(startUseDateYmdForCalc(today));
    if (start == null) return 0;
    final diff = startOfDay(today).difference(startOfDay(start)).inDays;
    return diff < 0 ? 0 : diff;
  }

  int skippedDaysBefore(DateTime today) {
    if (skippedDates.isEmpty) return 0;

    final start = DateTime.tryParse(startUseDateYmdForCalc(today));
    if (start == null) return 0;
    final startDay = startOfDay(start);
    final todayDay = startOfDay(today);

    var count = 0;
    for (final ymd in skippedDates) {
      final date = DateTime.tryParse(ymd);
      if (date == null) continue;
      final day = startOfDay(date);
      if (day.isBefore(startDay)) continue;
      if (day.isBefore(todayDay)) count++;
    }
    return count;
  }

  int consumedDaysAt(DateTime today) {
    final used = usedDaysAt(today);
    final skipped = skippedDaysBefore(today);
    final consumed = used - skipped;
    return consumed < 0 ? 0 : consumed;
  }

  int estimatedRemainingQuantityAt(DateTime today) {
    if (totalQuantity <= 0) return 0;
    if (dailyDosage <= 0) return totalQuantity;

    final consumed = consumedDaysAt(today) * dailyDosage;
    final left = totalQuantity - consumed;
    if (left <= 0) return 0;
    return left > totalQuantity ? totalQuantity : left;
  }

  int remainingDaysAt(DateTime today) {
    if (dailyDosage <= 0) return 0;
    return (estimatedRemainingQuantityAt(today) / dailyDosage).floor();
  }

  double remainingPercentAt(DateTime today) {
    if (totalQuantity <= 0) return 0;
    return estimatedRemainingQuantityAt(today) / totalQuantity;
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
        'totalQuantity': totalQuantity,
        'remainingQuantity': remainingQuantity,
        'category': category,
        'color': colorHex,
        if (skippedDates.isNotEmpty) 'skippedDates': skippedDates,
      };

  static Supplement fromJson(Map<String, Object?> json) {
    final category = json['category'] as String;
    final skipped = (json['skippedDates'] as List?)?.cast<String>();
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
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      category: category,
      colorHex: (json['color'] as String?) ?? CategoryColors.hexForCategory(category),
      skippedDates: skipped,
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
