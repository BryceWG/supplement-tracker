import 'dart:convert';

import '../util/colors.dart';

class Supplement {
  Supplement({
    required this.id,
    required this.name,
    required this.specification,
    required this.dailyDosage,
    required this.dosageUnit,
    required this.price,
    required this.purchaseDate,
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
  final int totalQuantity;
  final int remainingQuantity;
  final String category;
  final String colorHex;

  double get dailyCost {
    final daysSupply = totalQuantity / dailyDosage;
    if (daysSupply <= 0) return 0;
    return price / daysSupply;
  }

  int get remainingDays {
    if (dailyDosage <= 0) return 0;
    return (remainingQuantity / dailyDosage).floor();
  }

  double get remainingPercent {
    if (totalQuantity <= 0) return 0;
    return remainingQuantity / totalQuantity;
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'specification': specification,
        'dailyDosage': dailyDosage,
        'dosageUnit': dosageUnit,
        'price': price,
        'purchaseDate': purchaseDate,
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

