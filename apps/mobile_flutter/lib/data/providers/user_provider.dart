import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_providers.dart';
import '../../core/preferences.dart';

class UserProfile {
  final String name;
  final String diet;
  final List<String> allergies;
  final String goal;
  final int calorieTarget;

  const UserProfile({
    required this.name,
    required this.diet,
    required this.allergies,
    required this.goal,
    required this.calorieTarget,
  });
}

final userProfileProvider = Provider<UserProfile>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserProfile(
    name: readUserName(prefs) ?? 'Alex',
    diet: readDiet(prefs),
    allergies: readAllergies(prefs),
    goal: readGoal(prefs),
    calorieTarget: readCalorieTarget(prefs),
  );
});
