import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// تعرض بيانات الطوارئ للمستخدم بناءً على national_id من Supabase.
class EmergencyInfoPage extends StatefulWidget {
  final String nationalId;
  const EmergencyInfoPage({super.key, required this.nationalId});

  @override
  State<EmergencyInfoPage> createState() => _EmergencyInfoPageState();
}

class _EmergencyInfoPageState extends State<EmergencyInfoPage> {
  Map<String, dynamic>? row; // بيانات من create_user_patient
  bool loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final supabase = Supabase.instance.client;

      /// ✨ غيّر اسم الجدول/الأعمدة لو كانت مختلفة عندك.
      final data = await supabase
          .from('create_user_patient')
          .select()
          .eq('national_id', widget.nationalId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        row = data; // قد تكون null لو ما لقي
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = 'Failed to load data: $e';
        loading = false;
      });
    }
  }

  String _v(dynamic v) =>
      (v == null || (v is String && v.trim().isEmpty)) ? '—' : v.toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMsg != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency Access')),
        body: Center(child: Text(errorMsg!)),
      );
    }
    if (row == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency Access')),
        body: Center(
          child: Text('No data found for ID: ${widget.nationalId}'),
        ),
      );
    }

    final name = _v(row!['full_name']);
    final dob = _v(row!['dob']);
    final gender = _v(row!['gender']);
    final blood = _v(row!['blood_group']);

    // إبقِ هذه كروت مرتبة وقابلة للتبديل لاحقًا (أدوية مزمنة/حساسيات… الخ)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Access'),
        actions: [
          // لاحقًا ممكن تضيف زر QR أو مشاركة
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text('Patient',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _row(theme, 'Name', name),
            _row(theme, 'National ID', widget.nationalId),
            _row(theme, 'DOB', dob),
            _row(theme, 'Gender', gender),
            _row(theme, 'Blood Type', blood),

            const SizedBox(height: 16),
            const Divider(height: 24),

            // أمثلة لأقسام ثابتة مؤقتًا — اربطها لاحقًا بجدول آخر (مثلاً create_user_hospital)
            Text('Current Medications',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _bullet(theme, 'Metformin (daily)'),
            _bullet(theme, 'Aspirin (daily)'),

            const SizedBox(height: 16),
            _warning(theme),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _warning(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.06),
        border: Border.all(color: Colors.red.withOpacity(.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Text(
                  "This information is critical for emergency medical care.\nPlease ensure it's always up to date.",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
