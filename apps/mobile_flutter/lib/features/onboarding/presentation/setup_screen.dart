import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/app_providers.dart';
import '../../../core/extensions.dart';
import '../../../core/preferences.dart';
import '../../../data/providers/user_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_cards.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  late final TextEditingController _nameController;
  String _diet = 'omnivore';
  final Set<String> _allergies = {};
  String _goal = 'maintain';
  double _calories = 2000;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _nameController = TextEditingController(
      text: readUserName(prefs) ?? 'Alex',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final name = _nameController.text.trim().isEmpty
        ? 'Alex'
        : _nameController.text.trim();
    await prefs.setString(userNameKey, name);
    await prefs.setString(dietKey, _diet);
    await prefs.setStringList(allergiesKey, _allergies.toList());
    await prefs.setString(goalKey, _goal);
    await prefs.setInt(calorieTargetKey, _calories.round());
    await markOnboardingComplete(prefs);
    ref.invalidate(userProfileProvider);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final diets = [
      ('omnivore', l10n.dietOmnivore),
      ('vegetarian', l10n.dietVegetarian),
      ('vegan', l10n.dietVegan),
      ('pescatarian', l10n.dietPescatarian),
      ('gluten_free', l10n.dietGlutenFree),
    ];
    final allergyOptions = [
      ('none', l10n.allergyNone),
      ('nuts', l10n.allergyNuts),
      ('dairy', l10n.allergyDairy),
      ('eggs', l10n.allergyEggs),
      ('gluten', l10n.allergyGluten),
      ('soy', l10n.allergySoy),
      ('shellfish', l10n.allergyShellfish),
    ];
    final goals = [
      ('lose', l10n.goalLose, Icons.trending_down_rounded),
      ('maintain', l10n.goalMaintain, Icons.horizontal_rule_rounded),
      ('gain', l10n.goalGain, Icons.fitness_center_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.pagePadding,
                    vertical: AppSpacing.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LogoMark(size: 38),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            l10n.setupTitle,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.setupSubtitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _Section(
                            title: l10n.nameQuestion,
                            child: TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: l10n.nameHint,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          _Section(
                            title: l10n.dietTitle,
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final diet in diets)
                                  AppChoiceChip(
                                    label: diet.$2,
                                    selected: _diet == diet.$1,
                                    onTap: () =>
                                        setState(() => _diet = diet.$1),
                                  ),
                              ],
                            ),
                          ),
                          _Section(
                            title: l10n.allergiesTitle,
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final allergy in allergyOptions)
                                  AppChoiceChip(
                                    label: allergy.$2,
                                    selected: allergy.$1 == 'none'
                                        ? _allergies.isEmpty
                                        : _allergies.contains(allergy.$1),
                                    onTap: () {
                                      setState(() {
                                        if (allergy.$1 == 'none') {
                                          _allergies.clear();
                                        } else {
                                          if (_allergies.contains(allergy.$1)) {
                                            _allergies.remove(allergy.$1);
                                          } else {
                                            _allergies.add(allergy.$1);
                                          }
                                        }
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                          _Section(
                            title: l10n.goalTitle,
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                for (final goal in goals)
                                  AppChoiceChip(
                                    label: goal.$2,
                                    selected: _goal == goal.$1,
                                    onTap: () =>
                                        setState(() => _goal = goal.$1),
                                  ),
                              ],
                            ),
                          ),
                          _Section(
                            title: l10n.caloriesTitle,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.caloriesValue(_calories.round()),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppColors.accent),
                                ),
                                Slider(
                                  value: _calories,
                                  min: 1200,
                                  max: 3200,
                                  divisions: 20,
                                  label: l10n.caloriesValue(_calories.round()),
                                  onChanged: (value) =>
                                      setState(() => _calories = value),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1200',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    Text(
                                      '3200',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.setupHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.xl),
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
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: AppPrimaryButton(
                      label: l10n.finishSetup,
                      onPressed: _finish,
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
