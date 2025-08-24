import 'package:flutter/material.dart';

class Segmented<T> extends StatelessWidget {
  final Map<T, String> segments;
  final T value;
  final ValueChanged<T> onChanged;
  const Segmented(
      {super.key,
      required this.segments,
      required this.value,
      required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final keys = segments.keys.toList();
    return LayoutBuilder(builder: (ctx, _) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black12.withOpacity(.06),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: keys.map((k) {
            final selected = k == value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      segments[k]!,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionTitle({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class CardTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const CardTile(
      {super.key,
      this.leading,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }
}

/// =======================
/// Profile Header Card
/// =======================
/// كرت أزرق صافي (بدون نقوش) مثل الصورة:
/// صورة دائرية يسار، الاسم كبير، أسفلها الرقم المدني + العمر + الفصيلة،
//// وعلى اليمين أيقونات الوزن والطول.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.civilId,
    required this.ageYears,
    required this.bloodGroup,
    this.weightKg,
    this.heightCm,
    this.avatar,
    this.onTap,
  });

  final String name;
  final String civilId;
  final int ageYears; // يُعرض كـ 23Y
  final String bloodGroup; // مثال: A NEG
  final double? weightKg; // يُعرض -- kg إذا null
  final double? heightCm; // يُعرض -- cm إذا null
  final ImageProvider? avatar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1E88E5); // خلفية زرقاء صافية
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        );
    final secondary = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.88),
          height: 1.1,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: blue,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الصورة الدائرية يسار
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: avatar,
                child: avatar == null
                    ? const Icon(Icons.person, color: Colors.white, size: 34)
                    : null,
              ),
              const SizedBox(width: 14),

              // الاسم + ID + العمر/الفصيلة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle),
                    const SizedBox(height: 6),
                    Text(civilId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: secondary),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.event, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('${ageYears}Y', style: secondary),
                        const SizedBox(width: 14),
                        const Icon(Icons.water_drop,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(bloodGroup, style: secondary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // أعمدة الوزن والطول يمين
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _pill(const Icon(Icons.monitor_weight,
                        color: Colors.white, size: 18)),
                    const SizedBox(width: 8),
                    Text(
                      weightKg == null
                          ? '-- kg'
                          : '${weightKg!.toStringAsFixed(0)} kg',
                      style: secondary,
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _pill(const Icon(Icons.height,
                        color: Colors.white, size: 18)),
                    const SizedBox(width: 8),
                    Text(
                      heightCm == null
                          ? '-- cm'
                          : '${heightCm!.toStringAsFixed(0)} cm',
                      style: secondary,
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _pill(Widget child) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
}
