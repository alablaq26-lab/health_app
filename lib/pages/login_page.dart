import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      final nid = _idController.text.trim();
      await Api.postJson('/auth/request-otp/', {'national_id': nid});
      setState(() => _otpSent = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('OTP sent.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the verification code')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final nid = _idController.text.trim();
      await Api.postJson('/auth/verify-otp/', {
        'national_id': nid,
        'code': code,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      await prefs.setString('national_id', nid);

      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed('/home', arguments: {'nid': nid});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF6F61FF);
    const overlayTint = Color(0xFFB9A6FF);

    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pills_bg.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: Container(color: overlayTint.withOpacity(0.10)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      overlayTint.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health App',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Sign in with your National ID. We'll send a one-time code to verify.",
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _idController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'National ID',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (v) {
                                final t = v?.trim() ?? '';
                                if (t.isEmpty) return 'Enter your National ID';
                                if (t.length < 6) {
                                  return 'National ID seems too short';
                                }
                                return null;
                              },
                              enabled: !_otpSent && !_loading,
                            ),
                            if (_otpSent) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Verification Code',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                enabled: !_loading,
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: ButtonStyle(
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                  backgroundColor:
                                      const WidgetStatePropertyAll(deepPurple),
                                  foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                                onPressed: _loading
                                    ? null
                                    : (!_otpSent ? _requestOtp : _verifyOtp),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(!_otpSent
                                        ? 'Send Code'
                                        : 'Verify & Login'),
                              ),
                            ),
                            if (_otpSent) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          setState(() {
                                            _otpSent = false;
                                            _otpController.clear();
                                          });
                                        },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit National ID'),
                                  style: const ButtonStyle(
                                    foregroundColor:
                                        WidgetStatePropertyAll(deepPurple),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
