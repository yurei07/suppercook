import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../data/providers/recipe_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/recipe_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _heroIndex = 0;

  String _greeting(BuildContext context, UserProfile user) {
    final hour = DateTime.now().hour;
    final l10n = context.l10n;
    if (hour < 12) return l10n.greetingMorning(user.name);
    if (hour < 18) return l10n.greetingAfternoon(user.name);
    return l10n.greetingEvening(user.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(userProfileProvider);
    final featured = ref.watch(featuredRecipesProvider);
    final suggestions = ref.watch(suggestionsProvider);
    final pantryIds = ref.watch(pantryIdsProvider);
    final pantry = ref.watch(pantryProvider);
    final desktop = context.isDesktopLayout;
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
              bottom: desktop ? AppSpacing.xxl : 104,
            ),
            child: ContentConstraint(
              horizontalPadding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const LogoMark(size: 36),
                      const Spacer(),
                      AppIconButton(
                        icon: Icons.search_rounded,
                        tooltip: l10n.search,
                        onPressed: () => context.push('/suggestions'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            gradient: AppColors.accentGradient,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontFamily: AppTypography.serif,
                              fontSize: 21,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    _greeting(context, user),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: desktop ? 40 : 33,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (featured.isNotEmpty) ...[
                    SizedBox(
                      height: desktop ? 440 : 420,
                      child: PageView.builder(
                        itemCount: featured.length,
                        onPageChanged: (value) =>
                            setState(() => _heroIndex = value),
                        itemBuilder: (context, index) {
                          final recipe = featured[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: RecipeHeroCard(
                              recipe: recipe,
                              matchPercent: recipe.matchPercent(pantryIds),
                              onTap: () => context.push('/recipe/${recipe.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < featured.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _heroIndex ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _heroIndex
                                  ? AppColors.accent
                                  : AppColors.surfaceHigh,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.photo_camera_outlined,
                          label: l10n.quickScan,
                          accent: true,
                          onTap: () => context.push('/scan'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.kitchen_outlined,
                          label: l10n.quickPantry,
                          onTap: () => context.push('/pantry'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.calendar_month_outlined,
                          label: l10n.quickPlanner,
                          onTap: () => context.go('/planner'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: l10n.quickChat,
                          onTap: () => context.push('/chat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: l10n.recommended,
                    actionLabel: l10n.seeAll,
                    onAction: () => context.push('/suggestions'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 278,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final recipe = suggestions[index];
                        return RecipeSmallCard(
                          recipe: recipe,
                          matchPercent: recipe.matchPercent(pantryIds),
                          onTap: () => context.push('/recipe/${recipe.id}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: l10n.fromPantry,
                    actionLabel: pantry.isEmpty ? null : l10n.seeAll,
                    onAction: () => context.push('/pantry'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (pantry.isEmpty)
                    AppCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.kitchen_outlined,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.noPantryYet,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          AppSmallAccentButton(
                            label: l10n.addProducts,
                            onPressed: () => context.push('/pantry'),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final recipe in suggestions.take(3)) ...[
                      RecipeWideCard(
                        recipe: recipe,
                        matchPercent: recipe.matchPercent(pantryIds),
                        missingCount: recipe.missing(pantryIds).length,
                        onTap: () => context.push('/recipe/${recipe.id}'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent ? AppColors.accentSoft : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: accent
                  ? AppColors.accent.withValues(alpha: 0.35)
                  : AppColors.borderSoft,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 23,
                color: accent ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.sans,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accent ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
