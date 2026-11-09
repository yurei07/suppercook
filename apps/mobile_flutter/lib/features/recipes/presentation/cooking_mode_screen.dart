import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/providers/recipe_provider.dart';
import '../../../data/providers/stats_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/recipe_cards.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const CookingModeScreen({super.key, required this.recipeId});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  int _index = 0;
  Timer? _timer;
  int? _remaining;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    _running = false;
    _remaining = null;
  }

  void _toggleTimer(int minutes) {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }

    setState(() {
      _remaining ??= minutes * 60;
      _running = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _remaining ?? 0;
      if (remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _running = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.timerDone)),
        );
        return;
      }
      setState(() => _remaining = remaining - 1);
    });
  }

  String _format(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  Future<void> _finish() async {
    await ref.read(recipesCookedProvider.notifier).increment();
    if (!mounted) return;

    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(
          l10n.cookingDoneTitle,
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Text(
          l10n.cookingDoneBody,
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/home');
            },
            child: Text(l10n.backToHome),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(recipeByIdProvider(widget.recipeId));
    final l10n = context.l10n;

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: SafeArea(
            child: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.recipeNotFound,
              body: l10n.errorGeneric,
              actionLabel: l10n.back,
              onAction: () => context.pop(),
            ),
          ),
        ),
      );
    }

    final step = recipe.steps[_index];
    final locale = Localizations.localeOf(context);
    final isLast = _index == recipe.steps.length - 1;

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
                child: Row(
                  children: [
                    AppIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        recipe.title.resolve(locale),
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      l10n.stepOf(_index + 1, recipe.steps.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (_index + 1) / recipe.steps.length,
                    minHeight: 4,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.pagePadding,
                      vertical: AppSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey(_index),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_index + 1}'.padLeft(2, '0'),
                              style: const TextStyle(
                                fontFamily: AppTypography.serif,
                                fontSize: 72,
                                height: 1,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              step.title.resolve(locale),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              step.body.resolve(locale),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontSize: 17),
                            ),
                            if (step.timerMinutes != null) ...[
                              const SizedBox(height: AppSpacing.xl),
                              AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentSoft,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.timer_outlined,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.timerLabel,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _format(
                                              _remaining ??
                                                  step.timerMinutes! * 60,
                                            ),
                                            style: const TextStyle(
                                              fontFamily: AppTypography.sans,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppSmallAccentButton(
                                      label: _running
                                          ? l10n.pauseTimer
                                          : l10n.startTimer,
                                      icon: _running
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      onPressed: () =>
                                          _toggleTimer(step.timerMinutes!),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xxl),
                            RecipeMiniTile(recipe: recipe),
                          ],
                        ),
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
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Row(
                      children: [
                        if (_index > 0) ...[
                          Expanded(
                            child: AppGhostButton(
                              label: l10n.previousStep,
                              icon: Icons.arrow_back_rounded,
                              onPressed: () {
                                setState(() {
                                  _index -= 1;
                                  _resetTimer();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          flex: 2,
                          child: AppPrimaryButton(
                            label: isLast ? l10n.finishCooking : l10n.nextStep,
                            icon: isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            onPressed: () {
                              if (isLast) {
                                _finish();
                              } else {
                                setState(() {
                                  _index += 1;
                                  _resetTimer();
                                });
                              }
                            },
                          ),
                        ),
                      ],
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
