import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/localized_text.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/app_states.dart';

class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  Future<void> _addProduct(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final l10n = context.l10n;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.addProduct,
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.productName),
              onSubmitted: (value) {
                _save(ref, value);
                Navigator.of(sheetContext).pop();
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: l10n.addToPantry,
              onPressed: () {
                _save(ref, controller.text);
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save(WidgetRef ref, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    ref.read(pantryProvider.notifier).add(
      Ingredient(
        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
        name: LocalizedText.same(trimmed),
        amount: 1,
        unit: 'pcs',
        category: IngredientCategory.other,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(pantryProvider);

    final grouped = <IngredientCategory, List<Ingredient>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    const order = [
      IngredientCategory.produce,
      IngredientCategory.dairy,
      IngredientCategory.pantry,
      IngredientCategory.other,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
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
                    title: l10n.pantryTitle,
                    subtitle: l10n.pantrySubtitle(items.length),
                    onBack: () => context.pop(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppGhostButton(
                          label: l10n.emptyPantryCta,
                          icon: Icons.camera_alt_outlined,
                          onPressed: () => context.push('/scan'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      AppSmallAccentButton(
                        label: l10n.addProduct,
                        icon: Icons.add_rounded,
                        onPressed: () => _addProduct(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (items.isEmpty)
                    SizedBox(
                      height: 380,
                      child: AppEmptyState(
                        icon: Icons.kitchen_outlined,
                        title: l10n.pantryEmpty,
                        body: l10n.pantryEmptyBody,
                        actionLabel: l10n.emptyPantryCta,
                        onAction: () => context.push('/scan'),
                      ),
                    )
                  else
                    for (final category in order)
                      if (grouped[category]?.isNotEmpty ?? false) ...[
                        Text(
                          categoryLabel(context, category).toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xs,
                          ),
                          child: Column(
                            children: [
                              for (var i = 0;
                                  i < grouped[category]!.length;
                                  i++) ...[
                                _PantryRow(
                                  ingredient: grouped[category]![i],
                                  onDelete: () => ref
                                      .read(pantryProvider.notifier)
                                      .remove(grouped[category]![i].id),
                                ),
                                if (i != grouped[category]!.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
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

class _PantryRow extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onDelete;

  const _PantryRow({required this.ingredient, required this.onDelete});

  IconData get _icon => switch (ingredient.category) {
    IngredientCategory.produce => Icons.eco_outlined,
    IngredientCategory.dairy => Icons.egg_alt_outlined,
    IngredientCategory.pantry => Icons.inventory_2_outlined,
    IngredientCategory.other => Icons.shopping_bag_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(_icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name.resolve(locale),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  ingredient.quantityLabel(locale),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: AppColors.textTertiary,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
