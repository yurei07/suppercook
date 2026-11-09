import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_spacing.dart';
import '../app/theme/app_typography.dart';
import '../core/extensions.dart';
import '../shared/widgets/app_cards.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _DesktopRail(navigationShell: navigationShell),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _BottomBar(navigationShell: navigationShell),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _BottomBar({required this.navigationShell});

  String _label(BuildContext context, int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.navHome,
      1 => l10n.navPlanner,
      2 => l10n.navShopping,
      _ => l10n.navProfile,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = navigationShell.currentIndex;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: _label(context, 0),
                selected: current == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month_rounded,
                label: _label(context, 1),
                selected: current == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () => context.push('/scan'),
                    borderRadius: BorderRadius.circular(99),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.navScan,
                            style: const TextStyle(
                              fontFamily: AppTypography.sans,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.shopping_basket_outlined,
                selectedIcon: Icons.shopping_basket_rounded,
                label: _label(context, 2),
                selected: current == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: _label(context, 3),
                selected: current == 3,
                onTap: () => navigationShell.goBranch(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(selected ? selectedIcon : icon, size: 21, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.sans,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _DesktopRail({required this.navigationShell});

  String _label(BuildContext context, int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.navHome,
      1 => l10n.navPlanner,
      2 => l10n.navShopping,
      _ => l10n.navProfile,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = navigationShell.currentIndex;

    return Container(
      width: 96,
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            const LogoMark(withWordmark: false, size: 40),
            const SizedBox(height: AppSpacing.xxl),
            _RailItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: _label(context, 0),
              selected: current == 0,
              onTap: () => navigationShell.goBranch(0),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RailItem(
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month_rounded,
              label: _label(context, 1),
              selected: current == 1,
              onTap: () => navigationShell.goBranch(1),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RailItem(
              icon: Icons.shopping_basket_outlined,
              selectedIcon: Icons.shopping_basket_rounded,
              label: _label(context, 2),
              selected: current == 2,
              onTap: () => navigationShell.goBranch(2),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RailItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: _label(context, 3),
              selected: current == 3,
              onTap: () => navigationShell.goBranch(3),
            ),
            const Spacer(),
            Tooltip(
              message: l10n.navScan,
              child: InkWell(
                onTap: () => context.push('/scan'),
                borderRadius: BorderRadius.circular(99),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.navScan,
                      style: const TextStyle(
                        fontFamily: AppTypography.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textTertiary;
    return Tooltip(
      message: label,
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 72,
            height: 62,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? selectedIcon : icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.sans,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
