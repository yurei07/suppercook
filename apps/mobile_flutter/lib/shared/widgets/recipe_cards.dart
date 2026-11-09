import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/extensions.dart';
import '../../data/models/recipe.dart';
import 'badges.dart';

String difficultyLabel(BuildContext context, RecipeDifficulty difficulty) {
  final l10n = context.l10n;
  return switch (difficulty) {
    RecipeDifficulty.easy => l10n.difficultyEasy,
    RecipeDifficulty.medium => l10n.difficultyMedium,
    RecipeDifficulty.hard => l10n.difficultyHard,
  };
}

class RecipeHeroCard extends StatelessWidget {
  final Recipe recipe;
  final int matchPercent;
  final VoidCallback onTap;

  const RecipeHeroCard({
    super.key,
    required this.recipe,
    required this.matchPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(recipe.image, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.cardGradient),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MatchBadge(percent: matchPercent),
                  const Spacer(),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded, size: 19),
                  ),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title.resolve(locale),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.description.resolve(locale),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      MetaPill(
                        icon: Icons.schedule_rounded,
                        label: l10n.minShort(recipe.minutes),
                      ),
                      const SizedBox(width: 14),
                      MetaPill(
                        icon: Icons.local_fire_department_outlined,
                        label: l10n.kcalShort(recipe.calories),
                      ),
                      const SizedBox(width: 14),
                      MetaPill(
                        icon: Icons.restaurant_rounded,
                        label: difficultyLabel(context, recipe.difficulty),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppTypography.sans,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(l10n.viewRecipe),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeWideCard extends StatelessWidget {
  final Recipe recipe;
  final int matchPercent;
  final int missingCount;
  final VoidCallback onTap;

  const RecipeWideCard({
    super.key,
    required this.recipe,
    required this.matchPercent,
    required this.missingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderSoft),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Image.asset(
                  recipe.image,
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MatchBadge(percent: matchPercent, compact: true),
                        const Spacer(),
                        if (missingCount == 0)
                          Text(
                            l10n.noMissing,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      recipe.title.resolve(locale),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 19,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.description.resolve(locale),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        MetaPill(
                          icon: Icons.schedule_rounded,
                          label: l10n.minShort(recipe.minutes),
                        ),
                        const SizedBox(width: 12),
                        MetaPill(
                          icon: Icons.local_fire_department_outlined,
                          label: l10n.kcalShort(recipe.calories),
                        ),
                        if (missingCount > 0) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: MetaPill(
                              icon: Icons.shopping_basket_outlined,
                              label: l10n.missingLabel(missingCount),
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeSmallCard extends StatelessWidget {
  final Recipe recipe;
  final int matchPercent;
  final VoidCallback onTap;

  const RecipeSmallCard({
    super.key,
    required this.recipe,
    required this.matchPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;

    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: SizedBox(
                  height: 170,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(recipe.image, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0x990A0A0A)],
                            stops: [0.55, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: MatchBadge(percent: matchPercent, compact: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                recipe.title.resolve(locale),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  MetaPill(
                    icon: Icons.schedule_rounded,
                    label: l10n.minShort(recipe.minutes),
                  ),
                  const SizedBox(width: 12),
                  MetaPill(
                    icon: Icons.local_fire_department_outlined,
                    label: l10n.kcalShort(recipe.calories),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeMiniTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final Widget? trailing;

  const RecipeMiniTile({
    super.key,
    required this.recipe,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  recipe.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title.resolve(locale),
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l10n.minShort(recipe.minutes)} · ${l10n.kcalShort(recipe.calories)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
