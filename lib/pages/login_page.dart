import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // غيّر الـ IP هنا إلى IP جهازك + منفذ Django
  static const String baseUrl = 'http://192.168.1.9:8000';

  final _idController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/request-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'national_id': _idController.text.trim()}),
      );
      if (res.statusCode == 200) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('تم إرسال رمز التحقق (راجع كونسول السيرفر حالياً).')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإرسال: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رمز التحقق')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'national_id': _idController.text.trim(),
          'code': _otpController.text.trim(),
        }),
      );
      if (res.statusCode == 200) {
        // حفظ حالة الدخول لفتح التطبيق مباشرة في المرات القادمة
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logged_in', true);

        if (!mounted) return;
        // غيّر الوجهة هنا لو صفحتك الرئيسية غير '/'
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحقق: ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  "تسجيل الدخول",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "أدخل الرقم المدني وسيصلك رمز تحقق",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "الرقم المدني",
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'أدخل الرقم المدني';
                    if (t.length < 6) return 'الرقم المدني قصير';
                    return null;
                  },
                  enabled: !_otpSent, // بعد إرسال OTP نقفل تعديل الرقم
                ),
                const SizedBox(height: 16),
                if (_otpSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "رمز التحقق",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading
                        ? null
                        : (!_otpSent ? _requestOtp : _verifyOtp),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(!_otpSent ? "إرسال الرمز" : "تحقق ودخول"),
                  ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() => _otpSent = false);
                            _otpController.clear();
                          },
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل الرقم المدني'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
