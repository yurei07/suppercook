import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/recipe.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../data/providers/recipe_provider.dart';
import '../../../data/providers/shopping_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/badges.dart';
import '../../../shared/widgets/recipe_cards.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(recipeByIdProvider(recipeId));
    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: SafeArea(
            child: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: context.l10n.recipeNotFound,
              body: context.l10n.errorGeneric,
              actionLabel: context.l10n.back,
              onAction: () => context.pop(),
            ),
          ),
        ),
      );
    }

    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final pantryIds = ref.watch(pantryIdsProvider);
    final missing = recipe.missing(pantryIds);
    final have = recipe.ingredients
        .where((ingredient) => pantryIds.contains(ingredient.id))
        .toList();
    final match = recipe.matchPercent(pantryIds);
    final desktop = context.isDesktopLayout;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hero(
          recipe: recipe,
          match: match,
          onBack: () => context.pop(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                recipe.title.resolve(locale),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: desktop ? 42 : 34,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                recipe.description.resolve(locale),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: [
                  MetaPill(
                    icon: Icons.schedule_rounded,
                    label: l10n.minShort(recipe.minutes),
                  ),
                  MetaPill(
                    icon: Icons.local_fire_department_outlined,
                    label: l10n.kcalShort(recipe.calories),
                  ),
                  MetaPill(
                    icon: Icons.restaurant_rounded,
                    label: difficultyLabel(context, recipe.difficulty),
                  ),
                  MetaPill(
                    icon: Icons.people_outline_rounded,
                    label: l10n.servingsShort(recipe.servings),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _NutritionCard(recipe: recipe),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.ingredientsTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  MatchBadge(percent: match),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (have.isNotEmpty) ...[
                      _GroupLabel(
                        label: l10n.youHave,
                        count: have.length,
                        color: AppColors.success,
                      ),
                      for (var i = 0; i < have.length; i++) ...[
                        _IngredientLine(
                          ingredient: have[i],
                          have: true,
                          showDivider: i != have.length - 1 || missing.isNotEmpty,
                        ),
                      ],
                    ],
                    if (missing.isNotEmpty) ...[
                      _GroupLabel(
                        label: l10n.youNeed,
                        count: missing.length,
                        color: AppColors.warning,
                      ),
                      for (var i = 0; i < missing.length; i++)
                        _IngredientLine(
                          ingredient: missing[i],
                          have: false,
                          showDivider: i != missing.length - 1,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.stepsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < recipe.steps.length; i++) ...[
                _StepCard(
                  index: i,
                  step: recipe.steps[i],
                  timerLabel: l10n.minShort,
                ),
                if (i != recipe.steps.length - 1)
                  const SizedBox(height: AppSpacing.lg),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
            bottom: AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: content,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        missingCount: missing.length,
        onAddMissing: () {
          ref
              .read(shoppingProvider.notifier)
              .addMissing(recipe, pantryIds);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.addedToList)),
          );
        },
        onStartCooking: () =>
            context.push('/recipe/${recipe.id}/cook'),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final Recipe recipe;
  final int match;
  final VoidCallback onBack;

  const _Hero({
    required this.recipe,
    required this.match,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.isDesktopLayout ? 20 : 10,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: SizedBox(
          height: context.isDesktopLayout ? 430 : 330,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(recipe.image, fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Colors.transparent, Color(0x990A0A0A)],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                left: AppSpacing.md,
                child: AppIconButton(
                  icon: Icons.arrow_back_rounded,
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  onPressed: onBack,
                ),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: AppIconButton(
                  icon: Icons.bookmark_border_rounded,
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  onPressed: () {},
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: MatchBadge(percent: match),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final Recipe recipe;

  const _NutritionCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nutritionTitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Macro(
                value: '${recipe.calories}',
                label: l10n.calories,
                color: AppColors.accent,
              ),
              _Macro(
                value: '${recipe.protein} g',
                label: l10n.protein,
                color: AppColors.success,
              ),
              _Macro(
                value: '${recipe.carbs} g',
                label: l10n.carbs,
                color: AppColors.gold,
              ),
              _Macro(
                value: '${recipe.fat} g',
                label: l10n.fat,
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Macro({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.sans,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _GroupLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientLine extends StatelessWidget {
  final Ingredient ingredient;
  final bool have;
  final bool showDivider;

  const _IngredientLine({
    required this.ingredient,
    required this.have,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Icon(
                have
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                size: 19,
                color: have ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  ingredient.name.resolve(locale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: have
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                ingredient.quantityLabel(locale),
                style: const TextStyle(
                  fontFamily: AppTypography.sans,
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final RecipeStep step;
  final String Function(int) timerLabel;

  const _StepCard({
    required this.index,
    required this.step,
    required this.timerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.25),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontFamily: AppTypography.serif,
              fontSize: 17,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title.resolve(locale),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                step.body.resolve(locale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (step.timerMinutes != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppTag(
                  label: timerLabel(step.timerMinutes!),
                  icon: Icons.timer_outlined,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int missingCount;
  final VoidCallback onAddMissing;
  final VoidCallback onStartCooking;

  const _BottomBar({
    required this.missingCount,
    required this.onAddMissing,
    required this.onStartCooking,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final desktop = context.isDesktopLayout;

    final primary = AppPrimaryButton(
      label: l10n.startCooking,
      icon: Icons.play_arrow_rounded,
      onPressed: onStartCooking,
    );
    final ghost = AppGhostButton(
      label: l10n.addMissingToList,
      icon: Icons.shopping_basket_outlined,
      onPressed: onAddMissing,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        AppSpacing.md,
        context.pagePadding,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: desktop
                ? Row(
                    children: [
                      if (missingCount > 0) ...[
                        Expanded(child: ghost),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(flex: 2, child: primary),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (missingCount > 0) ...[
                        ghost,
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      primary,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
