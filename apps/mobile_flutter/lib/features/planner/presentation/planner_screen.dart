import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/models/recipe.dart';
import '../../../data/providers/recipe_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/recipe_cards.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  late int _selectedDay;
  late final DateTime _weekStart;
  final Map<int, Map<String, String>> _plan = {
    0: {
      'breakfast': 'berry_pancakes',
      'lunch': 'green_salad',
      'dinner': 'salmon_bowl',
    },
    1: {'breakfast': 'avocado_toast', 'dinner': 'tomato_pasta'},
    2: {'lunch': 'harvest_bowl', 'dinner': 'mushroom_pizza'},
    3: {
      'breakfast': 'berry_pancakes',
      'lunch': 'tomato_pasta',
      'dinner': 'pumpkin_soup',
    },
    4: {'dinner': 'mushroom_pizza'},
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    _selectedDay = now.weekday - 1;
  }

  Recipe? _recipeById(List<Recipe> recipes, String? id) {
    if (id == null) return null;
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  void _showAddMeal(String mealKey) {
    final recipes = ref.read(recipesProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: [
              Text(
                context.l10n.addMeal,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final recipe in recipes) ...[
                RecipeMiniTile(
                  recipe: recipe,
                  onTap: () {
                    setState(() {
                      _plan[_selectedDay] ??= {};
                      _plan[_selectedDay]![mealKey] = recipe.id;
                    });
                    Navigator.of(sheetContext).pop();
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }

  void _generatePlan() {
    final recipes = ref.read(recipesProvider);
    final lunch = recipes.where((recipe) => recipe.id == 'harvest_bowl').first;
    final dinners = [
      'salmon_bowl',
      'tomato_pasta',
      'pumpkin_soup',
      'mushroom_pizza',
      'green_salad',
      'harvest_bowl',
      'tomato_pasta',
    ];
    final breakfasts = [
      'berry_pancakes',
      'avocado_toast',
      'berry_pancakes',
      'avocado_toast',
      'berry_pancakes',
      'avocado_toast',
      'berry_pancakes',
    ];
    setState(() {
      for (var day = 0; day < 7; day++) {
        _plan[day] = {
          'breakfast': breakfasts[day],
          'lunch': lunch.id,
          'dinner': dinners[day],
        };
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.planGenerated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final recipes = ref.watch(recipesProvider);
    final dayPlan = _plan[_selectedDay] ?? const {};

    final meals = [
      ('breakfast', l10n.breakfast),
      ('lunch', l10n.lunch),
      ('dinner', l10n.dinner),
    ];

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
              maxWidth: 820,
              horizontalPadding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(
                    title: l10n.plannerTitle,
                    subtitle: l10n.plannerSubtitle,
                    showBack: false,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      for (var day = 0; day < 7; day++) ...[
                        Expanded(
                          child: _DayCell(
                            date: _weekStart.add(Duration(days: day)),
                            locale: locale,
                            selected: _selectedDay == day,
                            onTap: () => setState(() => _selectedDay = day),
                          ),
                        ),
                        if (day != 6) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (final meal in meals) ...[
                    Row(
                      children: [
                        Text(
                          meal.$2.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const Spacer(),
                        AppIconButton(
                          icon: Icons.add_rounded,
                          size: 34,
                          tooltip: l10n.addMeal,
                          onPressed: () => _showAddMeal(meal.$1),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MealSlot(
                      recipe: _recipeById(recipes, dayPlan[meal.$1]),
                      addLabel: l10n.addMeal,
                      onAdd: () => _showAddMeal(meal.$1),
                      onTapRecipe: (recipe) =>
                          context.push('/recipe/${recipe.id}'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  AppPrimaryButton(
                    label: l10n.generatePlan,
                    icon: Icons.auto_awesome,
                    onPressed: _generatePlan,
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

class _DayCell extends StatelessWidget {
  final DateTime date;
  final String locale;
  final bool selected;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat.E(locale).format(date);
    return Material(
      color: selected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.borderSoft,
            ),
          ),
          child: Column(
            children: [
              Text(
                weekday,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTypography.sans,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.black : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: AppTypography.sans,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.black : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealSlot extends StatelessWidget {
  final Recipe? recipe;
  final String addLabel;
  final VoidCallback onAdd;
  final void Function(Recipe) onTapRecipe;

  const _MealSlot({
    required this.recipe,
    required this.addLabel,
    required this.onAdd,
    required this.onTapRecipe,
  });

  @override
  Widget build(BuildContext context) {
    if (recipe != null) {
      return RecipeMiniTile(
        recipe: recipe!,
        onTap: () => onTapRecipe(recipe!),
      );
    }

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdd,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 19,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                addLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
