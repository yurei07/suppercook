import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions.dart';
import '../../../data/providers/saved_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/recipe_cards.dart';

/// Избранные рецепты. В Live API режиме сначала подтягиваем сервер.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(savedSyncProvider);
    final saved = ref.watch(savedRecipesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: saved.isEmpty
              ? AppEmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: l10n.savedTitle,
                  body: l10n.savedEmpty,
                  actionLabel: l10n.back,
                  onAction: () => context.pop(),
                )
              : SingleChildScrollView(
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
                          title: l10n.savedTitle,
                          subtitle: l10n.savedSubtitle,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        for (final recipe in saved.values) ...[
                          RecipeMiniTile(
                            recipe: recipe,
                            onTap: () => context.push('/recipe/${recipe.id}'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
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
