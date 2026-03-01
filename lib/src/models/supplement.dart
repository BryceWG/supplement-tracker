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
  });

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

  String get effectiveStartUseDateYmd => startUseDate ?? purchaseDate;

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
    );
  }

  double get dailyCost {
    final daysSupply = totalQuantity / dailyDosage;
    if (daysSupply <= 0) return 0;
    return price / daysSupply;
  }

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int usedDaysAt(DateTime today) {
    final start = DateTime.tryParse(effectiveStartUseDateYmd);
    if (start == null) return 0;
    final diff = startOfDay(today).difference(startOfDay(start)).inDays;
    return diff < 0 ? 0 : diff;
  }

  int estimatedRemainingQuantityAt(DateTime today) {
    if (dailyDosage <= 0) return remainingQuantity.clamp(0, totalQuantity);
    final consumed = usedDaysAt(today) * dailyDosage;
    final left = remainingQuantity - consumed;
    if (left <= 0) return 0;
    if (totalQuantity <= 0) return 0;
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
      };

  static Supplement fromJson(Map<String, Object?> json) {
    final category = json['category'] as String;
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
