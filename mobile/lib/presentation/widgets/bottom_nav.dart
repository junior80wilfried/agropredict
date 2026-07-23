import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const _navItems = [
  NavItem(Icons.home_rounded, 'Accueil'),
  NavItem(Icons.trending_up_rounded, 'Prix'),
  NavItem(Icons.bar_chart_rounded, 'Rendements'),
  NavItem(Icons.eco_rounded, 'Cultures'),
  NavItem(Icons.person_rounded, 'Profil'),
];

class BottomNav extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChange;

  const BottomNav({super.key, required this.active, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final on = active == i;
          return Expanded(
            child: InkWell(
              onTap: () => onChange(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: on ? AppColors.statGreenBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      size: 19,
                      color: on ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: AppTextStyles.sans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: on ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
