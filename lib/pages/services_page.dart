import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appointments_page.dart';
import 'prescriptions_page.dart';
import 'lab_investigations_page.dart';
import 'procedure_reports_page.dart';
import 'emergency_info_page.dart';
import 'blood_donation_page.dart';
import 'government_hospitals_page.dart';
import 'health_records_page.dart';
import 'medical_history_page.dart';
import 'dependents_page.dart';
import 'visit_details_page.dart';
import 'private_hospitals_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key, required this.nationalId});
  final String nationalId;

  Future<void> _openEmergency(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('national_id', nationalId);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EmergencyInfoPage(nationalId: nationalId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeader(child: _HospitalHeader()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ServiceTile(
                icon: Icons.article_outlined,
                title: 'Health Records',
                subtitle: 'Patient Visits in chronological order',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealthRecordsPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.description_outlined,
                title: 'Medical History',
                subtitle: 'Allergy, Medical and diagnosis history',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedicalHistoryPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.family_restroom_outlined,
                title: 'Dependents',
                subtitle: 'Access to dependents medical records',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DependentsPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.calendar_month_outlined,
                title: 'Appointments',
                subtitle: 'Healthcare institution appointments',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppointmentsPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.medication_outlined,
                title: 'Prescriptions',
                subtitle: 'Medical prescription details',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrescriptionsPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.biotech_outlined,
                title: 'Lab Investigations',
                subtitle: 'Lab investigations grouped by visit',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LabInvestigationsPage(nationalId: nationalId),
                  ),
                ),
              ),
              _ServiceTile(
                icon: Icons.note_alt_outlined,
                title: 'Procedure Reports',
                subtitle: 'Procedures and visit details',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProcedureReportsPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.monitor_heart_outlined,
                title: 'Vital Signs',
                subtitle: 'Vitals history and trends',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VisitDetailsPage.demoVitalSigns()),
                ),
              ),
              _ServiceTile(
                icon: Icons.volunteer_activism_outlined,
                title: 'Organ Donation',
                subtitle: 'Organ donation preferences',
                onTap: () {}, // placeholder
              ),
              _ServiceTile(
                icon: Icons.bloodtype_outlined,
                title: 'Blood Donation',
                subtitle: 'Donation status and history',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BloodDonationPage()),
                ),
              ),
              _ServiceTile(
                icon: Icons.emergency_outlined,
                title: 'Emergency Info',
                subtitle: 'Critical medical information for emergencies',
                iconColor: Colors.red,
                onTap: () => _openEmergency(context),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HospitalHeader extends StatelessWidget {
  static const Color purple = Color(0xFF6F61FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Text(
              "Hospitals",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _HospitalBox(
                label: "Private Hospitals",
                icon: Icons.apartment,
                textColor: purple,
                bgColor: purple.withOpacity(.15),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivateHospitalsPage()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HospitalBox(
                label: "Government Hospitals",
                icon: Icons.apartment,
                textColor: purple,
                bgColor: purple.withOpacity(.15),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GovernmentHospitalsPage()));
                },
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Divider(height: 0, color: Colors.grey.withOpacity(.25)),
        ],
      ),
    );
  }
}

class _HospitalBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const _HospitalBox({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: textColor, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyHeader({required this.child});

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  double get maxExtent => 140;
  @override
  double get minExtent => 140;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: color.withOpacity(.08),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 26, color: color),
        ),
        title: Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
        ),
        horizontalTitleGap: 14,
        minLeadingWidth: 0,
      ),
    );
  }
}
