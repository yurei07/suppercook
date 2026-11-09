import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions.dart';
import '../../../data/models/recipe.dart';
import '../../../data/providers/api_providers.dart';
import '../../../data/providers/data_source_provider.dart';
import '../../../data/providers/pantry_provider.dart';
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

  List<Recipe> _applyFilter(List<Recipe> recipes) {
    return switch (_filter) {
      _Filter.all => recipes,
      _Filter.quick => recipes.where((recipe) => recipe.isQuick).toList(),
      _Filter.vegan => recipes.where((recipe) => recipe.isVegan).toList(),
      _Filter.highProtein =>
        recipes.where((recipe) => recipe.isHighProtein).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pantryIds = ref.watch(pantryIdsProvider);
    final source = ref.watch(dataSourceProvider);
    final feed = ref.watch(suggestionsFeedProvider);

    final subtitle = feed.when(
      data: (recipes) => l10n.suggestionsSubtitle(recipes.length),
      error: (_, _) => l10n.apiUnreachable,
      loading: () => l10n.loadingRecipes,
    );

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
                    subtitle: subtitle,
                    onBack: () => context.pop(),
                    actions: [
                      AppTag(
                        label: source == DataSource.api
                            ? l10n.liveBadge
                            : l10n.demoBadge,
                        icon: source == DataSource.api
                            ? Icons.cloud_done_outlined
                            : Icons.storage_rounded,
                        color: source == DataSource.api
                            ? AppColors.success
                            : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: feed.when(
                  loading: () =>
                      AppLoadingState(label: l10n.loadingRecipes),
                  error: (_, _) => AppEmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: l10n.apiUnreachable,
                    body: l10n.dataSourceHint,
                    actionLabel: l10n.retry,
                    onAction: () => ref.invalidate(suggestionsFeedProvider),
                  ),
                  data: (recipes) {
                    final filtered = _applyFilter(recipes);
                    if (filtered.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.ramen_dining_outlined,
                        title: l10n.noRecipesTitle,
                        body: l10n.noRecipesBody,
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal: context.pagePadding,
                            ),
                            itemCount: filters.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final filter = filters[index];
                              return Center(
                                child: AppFilterChip(
                                  label: filter.$2,
                                  icon: filter.$3,
                                  selected: _filter == filter.$1,
                                  onTap: () =>
                                      setState(() => _filter = filter.$1),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: Center(
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
                                    matchPercent: recipe.matchPercent(
                                      pantryIds,
                                    ),
                                    missingCount: recipe
                                        .missing(pantryIds)
                                        .length,
                                    onTap: () => context.push(
                                      '/recipe/${recipe.id}',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
