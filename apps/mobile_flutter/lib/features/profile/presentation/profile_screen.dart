import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/app_providers.dart';
import '../../../core/extensions.dart';
import '../../../core/locale_controller.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../data/providers/planner_provider.dart';
import '../../../data/providers/shopping_provider.dart';
import '../../../data/providers/stats_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_cards.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notifications = true;

  String _dietLabel(BuildContext context, String diet) {
    final l10n = context.l10n;
    return switch (diet) {
      'vegetarian' => l10n.dietVegetarian,
      'vegan' => l10n.dietVegan,
      'pescatarian' => l10n.dietPescatarian,
      'gluten_free' => l10n.dietGlutenFree,
      _ => l10n.dietOmnivore,
    };
  }

  String _goalLabel(BuildContext context, String goal) {
    final l10n = context.l10n;
    return switch (goal) {
      'lose' => l10n.goalLose,
      'gain' => l10n.goalGain,
      _ => l10n.goalMaintain,
    };
  }

  void _showLanguageSheet() {
    final locale = ref.read(localeProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.languageLabel,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              _LanguageOption(
                code: 'EN',
                name: l10n.languageEnglish,
                selected: locale.languageCode == 'en',
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('en'));
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _LanguageOption(
                code: 'DE',
                name: l10n.languageGerman,
                selected: locale.languageCode == 'de',
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocale(const Locale('de'));
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAbout() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(
          l10n.aboutLabel,
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aboutBody,
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.version('0.1.0'),
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDemo() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(
          l10n.resetDialogTitle,
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Text(
          l10n.resetDemoBody,
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(sharedPreferencesProvider).clear();
    ref.invalidate(localeProvider);
    ref.invalidate(pantryProvider);
    ref.invalidate(shoppingProvider);
    ref.invalidate(plannerProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(recipesCookedProvider);
    if (!mounted) return;
    context.go('/language');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(userProfileProvider);
    final cooked = ref.watch(recipesCookedProvider);
    final locale = ref.watch(localeProvider);
    final initial = user.name.trim().isEmpty
        ? 'A'
        : user.name.trim().characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: AppSpacing.md,
              bottom: context.isDesktopLayout ? AppSpacing.xxl : 110,
            ),
            child: ContentConstraint(
              maxWidth: 760,
              horizontalPadding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(
                    title: l10n.profileTitle,
                    subtitle: l10n.profileSubtitle,
                    showBack: false,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            gradient: AppColors.accentGradient,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontFamily: AppTypography.serif,
                              fontSize: 32,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 24),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_dietLabel(context, user.diet)} · ${l10n.caloriesValue(user.calorieTarget)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '$cooked',
                          label: l10n.recipesCooked,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(value: '4', label: l10n.savedRecipes),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionLabel(label: l10n.settingsSection),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        AppInfoRow(
                          icon: Icons.language_rounded,
                          label: l10n.languageLabel,
                          value: locale.languageCode.toUpperCase(),
                          onTap: _showLanguageSheet,
                        ),
                        const Divider(height: 1),
                        AppInfoRow(
                          icon: Icons.restaurant_menu_rounded,
                          label: l10n.dietLabel,
                          value: _dietLabel(context, user.diet),
                        ),
                        const Divider(height: 1),
                        AppInfoRow(
                          icon: Icons.warning_amber_rounded,
                          label: l10n.allergiesLabel,
                          value: user.allergies.isEmpty
                              ? l10n.allergyNone
                              : '${user.allergies.length}',
                        ),
                        const Divider(height: 1),
                        AppInfoRow(
                          icon: Icons.flag_outlined,
                          label: l10n.goalLabel,
                          value: _goalLabel(context, user.goal),
                        ),
                        const Divider(height: 1),
                        AppInfoRow(
                          icon: Icons.notifications_none_rounded,
                          label: l10n.notificationsLabel,
                          trailing: Switch(
                            value: _notifications,
                            onChanged: (value) =>
                                setState(() => _notifications = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionLabel(label: l10n.accountSection),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        AppInfoRow(
                          icon: Icons.info_outline_rounded,
                          label: l10n.aboutLabel,
                          onTap: _showAbout,
                        ),
                        const Divider(height: 1),
                        AppInfoRow(
                          icon: Icons.logout_rounded,
                          label: l10n.signOut,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.comingSoonBody)),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        AppInfoRow(
                          icon: Icons.restart_alt_rounded,
                          label: l10n.resetDemo,
                          onTap: _resetDemo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      l10n.version('0.1.0'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.serif,
              fontSize: 30,
              height: 1,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accentSoft : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.borderSoft,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.black : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
