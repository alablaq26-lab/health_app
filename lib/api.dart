import 'dart:convert';
import 'package:http/http.dart' as http;

/// غيّر هذا إلى IP جهاز اللابتوب + المنفذ 8000
/// مثال: http://192.168.1.23:8000
const String baseUrl = 'http://127.0.0.1:8000/';

class Api {
  static Uri _u(String path) => Uri.parse('$baseUrl$path');

  /// طلب بسيط للتأكد أن الاتصال يعمل (يضرب الصفحة الرئيسية في Django)
  static Future<String> ping() async {
    final r = await http.get(_u('/')); // جرّب أيضاً /api/ لو عندك مسار
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return r.body.isEmpty ? 'OK' : r.body;
    }
    throw Exception('Ping failed: ${r.statusCode} ${r.body}');
  }

  /// مثال GET عام تُعيد JSON كـ Map
  static Future<Map<String, dynamic>> getJson(String path) async {
    final r = await http.get(_u(path));
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${r.statusCode} ${r.body}');
  }

  /// مثال POST عام تُرسل JSON وتستقبل JSON
  static Future<Map<String, dynamic>> postJson(
      String path, Map<String, dynamic> body) async {
    final r = await http.post(
      _u(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${r.statusCode} ${r.body}');
  }
}
