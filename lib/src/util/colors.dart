import 'package:flutter/material.dart';

class CategoryColors {
  static const vitamins = Color(0xFF3EBB7F);
  static const minerals = Color(0xFFA855F7);
  static const fattyAcids = Color(0xFF3B82F6);
  static const probiotics = Color(0xFFF59E0B);
  static const other = Color(0xFFEF4444);

  static Color forCategory(String category) {
    switch (category) {
      case '维生素':
        return vitamins;
      case '矿物质':
        return minerals;
      case '脂肪酸':
        return fattyAcids;
      case '益生菌':
        return probiotics;
      default:
        return other;
    }
  }

  static String hexForCategory(String category) {
    return toHex(forCategory(category));
  }

  static Color fromHex(String hex) {
    var normalized = hex.trim();
    if (normalized.startsWith('#')) normalized = normalized.substring(1);
    if (normalized.length == 6) normalized = 'FF$normalized';
    final value = int.parse(normalized, radix: 16);
    return Color(value);
  }

  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}
