import 'package:shared_preferences/shared_preferences.dart';

const onboardingCompleteKey = 'onboarding_complete';
const userNameKey = 'user_name';
const dietKey = 'user_diet';
const allergiesKey = 'user_allergies';
const goalKey = 'user_goal';
const calorieTargetKey = 'user_calorie_target';
const recipesCookedKey = 'recipes_cooked';

bool isOnboardingComplete(SharedPreferences prefs) =>
    prefs.getBool(onboardingCompleteKey) ?? false;

Future<void> markOnboardingComplete(SharedPreferences prefs) =>
    prefs.setBool(onboardingCompleteKey, true);

String? readUserName(SharedPreferences prefs) => prefs.getString(userNameKey);

String readDiet(SharedPreferences prefs) => prefs.getString(dietKey) ?? 'omnivore';

List<String> readAllergies(SharedPreferences prefs) =>
    prefs.getStringList(allergiesKey) ?? const [];

String readGoal(SharedPreferences prefs) => prefs.getString(goalKey) ?? 'maintain';

int readCalorieTarget(SharedPreferences prefs) =>
    prefs.getInt(calorieTargetKey) ?? 2000;
