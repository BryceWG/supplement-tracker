import 'dart:convert';

class Profile {
  Profile({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
      };

  static Profile fromJson(Map<String, Object?> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  static String encodeList(List<Profile> list) {
    return jsonEncode(list.map((p) => p.toJson()).toList());
  }

  static List<Profile> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((m) => Profile.fromJson(m.cast<String, Object?>()))
        .toList();
  }
}

