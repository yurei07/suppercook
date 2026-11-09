import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../data/providers/recipe_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/recipe_cards.dart';

enum _Filter { all, quick, vegan, highProtein }

class SuggestionsScreen extends ConsumerStatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  ConsumerState<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends ConsumerState<SuggestionsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pantryIds = ref.watch(pantryIdsProvider);
    final suggestions = ref.watch(suggestionsProvider);

    final filtered = switch (_filter) {
      _Filter.all => suggestions,
      _Filter.quick => suggestions.where((recipe) => recipe.isQuick).toList(),
      _Filter.vegan => suggestions.where((recipe) => recipe.isVegan).toList(),
      _Filter.highProtein =>
        suggestions.where((recipe) => recipe.isHighProtein).toList(),
    };

    final filters = [
      (_Filter.all, l10n.filterAll, Icons.grid_view_rounded),
      (_Filter.quick, l10n.filterQuick, Icons.bolt_rounded),
      (_Filter.vegan, l10n.filterVegan, Icons.eco_outlined),
      (
        _Filter.highProtein,
        l10n.filterHighProtein,
        Icons.fitness_center_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.pagePadding,
                  AppSpacing.md,
                  context.pagePadding,
                  AppSpacing.sm,
                ),
                child: ContentConstraint(
                  child: AppPageHeader(
                    title: l10n.suggestionsTitle,
                    subtitle: l10n.suggestionsSubtitle(filtered.length),
                    onBack: () => context.pop(),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                  itemCount: filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    return Center(
                      child: AppFilterChip(
                        label: filter.$2,
                        icon: filter.$3,
                        selected: _filter == filter.$1,
                        onTap: () => setState(() => _filter = filter.$1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: filtered.isEmpty
                    ? AppEmptyState(
                        icon: Icons.ramen_dining_outlined,
                        title: l10n.noRecipesTitle,
                        body: l10n.noRecipesBody,
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              context.pagePadding,
                              AppSpacing.sm,
                              context.pagePadding,
                              AppSpacing.xxl,
                            ),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final recipe = filtered[index];
                              return RecipeWideCard(
                                recipe: recipe,
                                matchPercent: recipe.matchPercent(pantryIds),
                                missingCount:
                                    recipe.missing(pantryIds).length,
                                onTap: () =>
                                    context.push('/recipe/${recipe.id}'),
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
