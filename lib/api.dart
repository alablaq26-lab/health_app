import 'dart:convert';
import 'package:http/http.dart' as http;

/// غيّر هذا إلى IP جهاز اللابتوب + منفذ Django (وتأكد السيرفر شغال على 0.0.0.0)
/// مثال: http://192.168.1.9:8000
const String baseUrl = 'http://192.168.1.9:8000';

class Api {
  static Uri _u(String path) {
    // يدعم تمرير path يبدأ بـ "/" أو بدون
    final p = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$p');
  }

  static Future<Map<String, dynamic>> getJson(String path) async {
    final r = await http.get(_u(path));
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${r.statusCode} ${r.body}');
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final r = await http.post(
      _u(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      if (r.body.isEmpty) return <String, dynamic>{};
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${r.statusCode} ${r.body}');
  }
}
