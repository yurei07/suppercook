import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/mock_data.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/localized_text.dart';
import '../../../data/providers/pantry_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';

class ScanResultsScreen extends ConsumerStatefulWidget {
  final String? imagePath;

  const ScanResultsScreen({super.key, this.imagePath});

  @override
  ConsumerState<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends ConsumerState<ScanResultsScreen> {
  late final List<Ingredient> _ingredients;
  late final Set<String> _selected;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ingredients = List.of(MockData.scanDetected);
    _selected = _ingredients.map((item) => item.id).toSet();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(Ingredient ingredient) {
    setState(() {
      if (_selected.contains(ingredient.id)) {
        _selected.remove(ingredient.id);
      } else {
        _selected.add(ingredient.id);
      }
    });
  }

  void _addCustom() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final ingredient = Ingredient(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      name: LocalizedText.same(name),
      amount: 1,
      unit: 'pcs',
      category: IngredientCategory.other,
    );
    setState(() {
      _ingredients.add(ingredient);
      _selected.add(ingredient.id);
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _findRecipes() {
    final chosen = _ingredients
        .where((ingredient) => _selected.contains(ingredient.id))
        .toList();
    ref.read(pantryProvider.notifier).addAll(chosen);
    context.pushReplacement('/suggestions');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedCount = _selected.length;

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
                child: AppPageHeader(
                  title: l10n.detectedTitle(_ingredients.length),
                  subtitle: l10n.detectedSubtitle,
                  onBack: () => context.pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.pagePadding,
                    vertical: AppSpacing.md,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.imagePath != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              child: SizedBox(
                                height: 170,
                                child: widget.imagePath!.startsWith('assets/')
                                    ? Image.asset(
                                        widget.imagePath!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(widget.imagePath!),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          Row(
                            children: [
                              AppTag(
                                label: l10n.selectedCount(selectedCount),
                                icon: Icons.check_circle_outline_rounded,
                                color: AppColors.accent,
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => setState(() {
                                  _selected
                                    ..clear()
                                    ..addAll(
                                      _ingredients.map((item) => item.id),
                                    );
                                }),
                                icon: const Icon(Icons.done_all_rounded, size: 16),
                                label: Text(l10n.all),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (var i = 0; i < _ingredients.length; i++) ...[
                                  _IngredientCheckRow(
                                    ingredient: _ingredients[i],
                                    selected: _selected.contains(
                                      _ingredients[i].id,
                                    ),
                                    onTap: () => _toggle(_ingredients[i]),
                                  ),
                                  if (i != _ingredients.length - 1)
                                    const Divider(height: 1),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _addCustom(),
                                  decoration: InputDecoration(
                                    hintText: l10n.ingredientName,
                                    prefixIcon: const Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              AppIconButton(
                                icon: Icons.arrow_forward_rounded,
                                backgroundColor: AppColors.surfaceElevated,
                                onPressed: _addCustom,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: AppPrimaryButton(
                      label: l10n.findRecipes,
                      icon: Icons.auto_awesome,
                      onPressed: selectedCount == 0 ? null : _findRecipes,
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

class _IngredientCheckRow extends StatelessWidget {
  final Ingredient ingredient;
  final bool selected;
  final VoidCallback onTap;

  const _IngredientCheckRow({
    required this.ingredient,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon => switch (ingredient.category) {
    IngredientCategory.produce => Icons.eco_outlined,
    IngredientCategory.dairy => Icons.egg_alt_outlined,
    IngredientCategory.pantry => Icons.inventory_2_outlined,
    IngredientCategory.other => Icons.shopping_bag_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.border,
                    width: 1.4,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.black,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(_icon, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  ingredient.name.resolve(locale),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              Text(
                ingredient.quantityLabel(locale),
                style: const TextStyle(
                  fontFamily: AppTypography.sans,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
