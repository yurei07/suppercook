import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/shopping_item.dart';
import '../../../data/providers/api_providers.dart';
import '../../../data/providers/data_source_provider.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../data/providers/shopping_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/app_states.dart';

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  bool _atHome(ShoppingItem item, Set<String> pantryIds) {
    return pantryIds.contains(item.id) ||
        (item.source != null && pantryIds.contains(item.source!.id));
  }

  Future<void> _showAddItem(
    BuildContext context,
    WidgetRef ref,
    bool apiMode,
  ) async {
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
              l10n.addItemTitle,
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: l10n.itemName),
              onSubmitted: (value) {
                Navigator.of(sheetContext).pop();
                _addItem(context, ref, apiMode, value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: l10n.addToList,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _addItem(context, ref, apiMode, controller.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addItem(
    BuildContext context,
    WidgetRef ref,
    bool apiMode,
    String value,
  ) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    if (!apiMode) {
      ref.read(shoppingProvider.notifier).addCustom(trimmed);
      return;
    }

    try {
      await ref
          .read(apiRepositoryProvider)
          .addShoppingItem(name: trimmed, quantity: 1, unit: 'g');
      ref.invalidate(apiShoppingProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.apiUnreachable)),
        );
      }
    }
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool apiMode,
    ShoppingItem item,
  ) async {
    if (!apiMode) {
      ref.read(shoppingProvider.notifier).toggle(item.id);
      return;
    }

    try {
      await ref
          .read(apiRepositoryProvider)
          .toggleShoppingItem(item.id, !item.checked);
      ref.invalidate(apiShoppingProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.apiUnreachable)),
        );
      }
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    bool apiMode,
    ShoppingItem item,
  ) async {
    if (!apiMode) {
      ref.read(shoppingProvider.notifier).remove(item.id);
      return;
    }

    try {
      await ref.read(apiRepositoryProvider).removeShoppingItem(item.id);
      ref.invalidate(apiShoppingProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.apiUnreachable)),
        );
      }
    }
  }

  Future<void> _clearChecked(
    BuildContext context,
    WidgetRef ref,
    bool apiMode,
  ) async {
    if (!apiMode) {
      ref.read(shoppingProvider.notifier).clearChecked();
      return;
    }

    try {
      await ref.read(apiRepositoryProvider).clearCheckedShopping();
      ref.invalidate(apiShoppingProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.apiUnreachable)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final source = ref.watch(dataSourceProvider);
    final feed = ref.watch(apiShoppingProvider);
    final pantryIds = ref.watch(pantryIdsProvider);
    final apiMode = source == DataSource.api;

    final items = feed.asData?.value ?? const <ShoppingItem>[];
    final checked = items.where((item) => item.checked).length;
    final ratio = items.isEmpty ? 0.0 : checked / items.length;

    final atHome = items.where((item) => _atHome(item, pantryIds)).toList();
    final active = items.where((item) => !_atHome(item, pantryIds)).toList();

    final grouped = <IngredientCategory, List<ShoppingItem>>{};
    for (final item in active) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItem(context, ref, apiMode),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add_rounded),
      ),
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
                    title: l10n.shoppingTitle,
                    subtitle: l10n.shoppingProgress(checked, items.length),
                    showBack: false,
                    actions: [
                      AppIconButton(
                        icon: Icons.delete_sweep_outlined,
                        tooltip: l10n.clearChecked,
                        onPressed: () =>
                            _clearChecked(context, ref, apiMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.shoppingProgress(checked, items.length),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Text(
                              '${(ratio * 100).round()}%',
                              style: const TextStyle(
                                fontFamily: AppTypography.sans,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (feed.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxl),
                      child: AppLoadingState(label: l10n.loadingList),
                    )
                  else if (feed.hasError)
                    SizedBox(
                      height: 360,
                      child: AppEmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: l10n.apiUnreachable,
                        body: l10n.dataSourceHint,
                        actionLabel: l10n.retry,
                        onAction: () => ref.invalidate(apiShoppingProvider),
                      ),
                    )
                  else if (active.isEmpty && atHome.isEmpty)
                    SizedBox(
                      height: 380,
                      child: AppEmptyState(
                        icon: Icons.shopping_basket_outlined,
                        title: l10n.shoppingEmpty,
                        body: l10n.shoppingEmptyBody,
                        actionLabel: l10n.addItemTitle,
                        onAction: () => _showAddItem(context, ref, apiMode),
                      ),
                    )
                  else ...[
                    for (final category in order)
                      if (grouped[category]?.isNotEmpty ?? false) ...[
                        _CategoryHeader(
                          label: categoryLabel(context, category),
                          count: grouped[category]!.length,
                        ),
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
                                _ShoppingRow(
                                  item: grouped[category]![i],
                                  onToggle: () => _toggle(
                                    context,
                                    ref,
                                    apiMode,
                                    grouped[category]![i],
                                  ),
                                  onDelete: () => _remove(
                                    context,
                                    ref,
                                    apiMode,
                                    grouped[category]![i],
                                  ),
                                ),
                                if (i != grouped[category]!.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    if (atHome.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _CategoryHeader(
                        label: l10n.alreadyAtHome,
                        count: atHome.length,
                        color: AppColors.success,
                      ),
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.shoppingAtHomeHint,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            for (final item in atHome)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        item.name.resolve(
                                          Localizations.localeOf(context),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textTertiary,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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

class _CategoryHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CategoryHeader({
    required this.label,
    required this.count,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(width: 8),
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

class _ShoppingRow extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ShoppingRow({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(99),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.checked ? AppColors.accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.checked ? AppColors.accent : AppColors.border,
                    width: 1.4,
                  ),
                ),
                child: item.checked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.black,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            item.name.resolve(locale),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              color: item.checked
                  ? AppColors.textTertiary
                  : AppColors.textPrimary,
              decoration: item.checked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (item.source != null)
          Text(
            item.source!.quantityLabel(locale),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: item.checked
                  ? AppColors.textDisabled
                  : AppColors.textTertiary,
              decoration: item.checked ? TextDecoration.lineThrough : null,
            ),
          ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.close_rounded, size: 17),
          color: AppColors.textTertiary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
