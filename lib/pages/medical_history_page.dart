import 'package:flutter/material.dart';
import '../widgets.dart';

class MedicalHistoryPage extends StatelessWidget {
  const MedicalHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final pillBg = primary.withOpacity(0.08); // لون كرت فاتح متناسق
    final iconBg = primary.withOpacity(0.15); // خلفية دايرة الأيقونة

    Widget pill({
      required String title,
      required String hint,
      required IconData icon,
      VoidCallback? onTap,
    }) {
      return Material(
        color: pillBg,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أيقونة داخل دائرة فاتحة
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: primary, size: 22),
                ),
                const SizedBox(width: 12),
                // عناوين ونص مساعد
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black.withOpacity(0.6),
                              height: 1.25,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: primary.withOpacity(0.9)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        elevation: 0,
      ),
      backgroundColor: cs.surface, // ينسجم مع باقي الصفحات
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // نفس مكوّن العنوان اللي تستخدمه في الصفحات السابقة
            const SectionTitle(
              title: "Allergy",
              icon: Icons.ac_unit_outlined,
            ),

            pill(
              title: "Allergy",
              hint:
                  "It seems that you are not allergic to anything, thank God.",
              icon: Icons.ac_unit_outlined,
              onTap: () {}, // اختياري
            ),
            const SizedBox(height: 10),

            pill(
              title: "Medical History",
              hint: "Your medical history will appear here",
              icon: Icons.description_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 10),

            pill(
              title: "Final Diagnosis",
              hint: "You’ll find the final diagnostics here",
              icon: Icons.monitor_heart_outlined,
              onTap: () {},
            ),
            const SizedBox(height: 10),

            pill(
              title: "Referrals",
              hint: "Your recent referrals appear here",
              icon: Icons.swap_horiz_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
