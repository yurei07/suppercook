// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Suppercook';

  @override
  String get continueLabel => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get search => 'Search';

  @override
  String get seeAll => 'See all';

  @override
  String get retry => 'Try again';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonBody => 'This feature is coming in the next iteration.';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get apply => 'Apply';

  @override
  String get all => 'All';

  @override
  String get confirm => 'Confirm';

  @override
  String minShort(int minutes) {
    return '$minutes min';
  }

  @override
  String kcalShort(int value) {
    return '$value kcal';
  }

  @override
  String servingsShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String matchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String missingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missing',
      one: '1 missing',
      zero: 'Nothing missing',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get viewRecipe => 'View recipe';

  @override
  String get perServing => 'per serving';

  @override
  String get searchRecipes => 'Search recipes';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'You can change it anytime in your profile.';

  @override
  String get languagePreview => 'Tonight we\'re cooking something amazing.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get onboardingTitle1 => 'Cook with what you have';

  @override
  String get onboardingBody1 =>
      'Snap a photo of your fridge or pantry and get recipes that fit your ingredients.';

  @override
  String get onboardingTitle2 => 'Your smart shopping list';

  @override
  String get onboardingBody2 =>
      'We add only what\'s missing — no duplicate buying, no waste.';

  @override
  String get onboardingTitle3 => 'Plan your week in minutes';

  @override
  String get onboardingBody3 =>
      'Balanced meals, calories and macros tailored to your goals.';

  @override
  String get getStarted => 'Get started';

  @override
  String get onboardingSkip => 'Skip intro';

  @override
  String get authTitle => 'Welcome to Suppercook';

  @override
  String get authSubtitle => 'Your kitchen, smarter.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get authTerms =>
      'By continuing you agree to our Terms and Privacy Policy.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get setupTitle => 'Let\'s personalize your kitchen';

  @override
  String get setupSubtitle =>
      'This helps us suggest meals that actually fit you.';

  @override
  String get nameQuestion => 'What should we call you?';

  @override
  String get nameHint => 'Your name';

  @override
  String get orLabel => 'or';

  @override
  String get dietTitle => 'What do you eat?';

  @override
  String get dietOmnivore => 'Everything';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietPescatarian => 'Pescatarian';

  @override
  String get dietGlutenFree => 'Gluten-free';

  @override
  String get allergiesTitle => 'Any allergies?';

  @override
  String get allergyNone => 'None';

  @override
  String get allergyNuts => 'Nuts';

  @override
  String get allergyDairy => 'Dairy';

  @override
  String get allergyEggs => 'Eggs';

  @override
  String get allergyGluten => 'Gluten';

  @override
  String get allergySoy => 'Soy';

  @override
  String get allergyShellfish => 'Shellfish';

  @override
  String get goalTitle => 'Your goal';

  @override
  String get goalLose => 'Lose weight';

  @override
  String get goalMaintain => 'Maintain';

  @override
  String get goalGain => 'Build muscle';

  @override
  String get caloriesTitle => 'Daily calorie target';

  @override
  String caloriesValue(int value) {
    return '$value kcal';
  }

  @override
  String get finishSetup => 'Start cooking';

  @override
  String get setupHint => 'You can change all of this later.';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get homeSubtitle => 'What are we cooking today?';

  @override
  String get scanIngredients => 'Scan ingredients';

  @override
  String get quickScan => 'Scan';

  @override
  String get quickPantry => 'Pantry';

  @override
  String get quickPlanner => 'Planner';

  @override
  String get quickChat => 'AI chef';

  @override
  String get recommended => 'Recommended for you';

  @override
  String get fromPantry => 'From your pantry';

  @override
  String get noPantryYet => 'Add ingredients to see personalized recipes';

  @override
  String get addProducts => 'Add products';

  @override
  String get chefTip => 'Chef\'s tip';

  @override
  String get scanTitle => 'Scan your ingredients';

  @override
  String get scanSubtitle =>
      'Point the camera at your fridge shelf or upload a photo.';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get uploadPhoto => 'Upload photo';

  @override
  String get useSample => 'Use sample photo';

  @override
  String get analyzing => 'Analyzing your ingredients…';

  @override
  String get analyzingHint => 'Our AI is identifying what\'s on the photo.';

  @override
  String detectedTitle(int count) {
    return 'We found $count ingredients';
  }

  @override
  String get detectedSubtitle =>
      'Check the list and edit anything that\'s wrong.';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get ingredientName => 'Ingredient name';

  @override
  String get findRecipes => 'Find recipes';

  @override
  String get scanError =>
      'Couldn\'t analyze the photo. Try again or add ingredients manually.';

  @override
  String get cameraUnavailable =>
      'Camera is not available on this device. Upload a photo instead.';

  @override
  String get suggestionsTitle => 'Recipes for you';

  @override
  String suggestionsSubtitle(int count) {
    return '$count ideas from your ingredients';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterQuick => 'Under 20 min';

  @override
  String get filterVegan => 'Vegan';

  @override
  String get filterHighProtein => 'High protein';

  @override
  String get loadingRecipes => 'Loading recipes…';

  @override
  String get liveBadge => 'Live API';

  @override
  String get demoBadge => 'Demo data';

  @override
  String get noRecipesTitle => 'No recipes yet';

  @override
  String get noRecipesBody => 'Add a few more ingredients and try again.';

  @override
  String get matchLabel => 'match';

  @override
  String get noMissing => 'You have everything';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get stepsTitle => 'Steps';

  @override
  String get youHave => 'You have';

  @override
  String get youNeed => 'You need';

  @override
  String get nutritionTitle => 'Nutrition per serving';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get calories => 'Calories';

  @override
  String get startCooking => 'Start cooking';

  @override
  String get addMissingToList => 'Add missing to list';

  @override
  String get addedToList => 'Added to your shopping list';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get recipeNotFound => 'Recipe not found';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get timerLabel => 'Timer';

  @override
  String get startTimer => 'Start timer';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get nextStep => 'Next step';

  @override
  String get previousStep => 'Back';

  @override
  String get finishCooking => 'Finish cooking';

  @override
  String get cookingDoneTitle => 'Enjoy your meal!';

  @override
  String get cookingDoneBody =>
      'Bon appétit! Your shopping list has been updated.';

  @override
  String get ratePrompt => 'How did it turn out?';

  @override
  String get backToHome => 'Back to home';

  @override
  String get timerDone => 'Time\'s up!';

  @override
  String get shoppingTitle => 'Shopping list';

  @override
  String shoppingProgress(int checked, int total) {
    return '$checked of $total bought';
  }

  @override
  String get shoppingEmpty => 'Your list is empty';

  @override
  String get shoppingEmptyBody => 'Add missing ingredients from any recipe.';

  @override
  String get categoryProduce => 'Produce';

  @override
  String get categoryDairy => 'Dairy & eggs';

  @override
  String get categoryPantry => 'Pantry';

  @override
  String get categoryOther => 'Other';

  @override
  String get alreadyAtHome => 'Already at home';

  @override
  String get clearChecked => 'Clear bought';

  @override
  String get addItemTitle => 'Add item';

  @override
  String get itemName => 'Item name';

  @override
  String get addToList => 'Add to list';

  @override
  String get shoppingAtHomeHint => 'These items are already in your pantry';

  @override
  String get noItems => 'No items';

  @override
  String get plannerTitle => 'Meal planner';

  @override
  String get plannerSubtitle => 'Your week at a glance';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get addMeal => 'Add meal';

  @override
  String get generatePlan => 'Generate plan';

  @override
  String get planGenerated => 'Your week is planned';

  @override
  String get today => 'Today';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle => 'Preferences and account';

  @override
  String get languageLabel => 'Language';

  @override
  String get dataSourceLabel => 'Data source';

  @override
  String get dataSourceDemo => 'Demo data';

  @override
  String get dataSourceApi => 'Live API';

  @override
  String get dataSourceHint =>
      'Demo data works offline. Live API talks to the NestJS backend on your network.';

  @override
  String get dataSourceDemoHint => 'Built-in recipes; no backend needed.';

  @override
  String get dataSourceApiHint =>
      'Recipes and photo recognition from the NestJS API.';

  @override
  String get apiEnabled => 'Live API enabled';

  @override
  String get apiUnreachable =>
      'Can\'t reach the API. Check that the backend is running.';

  @override
  String get apiSyncFailed =>
      'Couldn\'t sync with the API — showing local data.';

  @override
  String get dietLabel => 'Diet';

  @override
  String get allergiesLabel => 'Allergies';

  @override
  String get goalLabel => 'Goal';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get aboutLabel => 'About Suppercook';

  @override
  String get aboutBody =>
      'Suppercook is your smart kitchen companion. It turns the ingredients you already have into recipes, plans and a shopping list that never buys twice.';

  @override
  String get resetDemo => 'Reset demo data';

  @override
  String get resetDemoBody =>
      'This clears your pantry, shopping list and onboarding state.';

  @override
  String get resetDialogTitle => 'Reset demo?';

  @override
  String get signOut => 'Sign out';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get recipesCooked => 'Recipes cooked';

  @override
  String get savedRecipes => 'Saved recipes';

  @override
  String get settingsSection => 'Preferences';

  @override
  String get accountSection => 'Account';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get pantryTitle => 'My pantry';

  @override
  String pantrySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items at home',
      one: '1 item at home',
    );
    return '$_temp0';
  }

  @override
  String get pantryEmpty => 'Your pantry is empty';

  @override
  String get pantryEmptyBody => 'Scan your fridge or add items manually.';

  @override
  String get addProduct => 'Add product';

  @override
  String get productName => 'Product name';

  @override
  String get deleteItem => 'Delete';

  @override
  String get addToPantry => 'Add to pantry';

  @override
  String get pantryUpdated => 'Pantry updated';

  @override
  String get emptyPantryCta => 'Scan products';

  @override
  String get chatTitle => 'AI chef';

  @override
  String get chatSubtitle => 'Cook with what you have';

  @override
  String get chatGreeting =>
      'Hi! Tell me what\'s in your fridge, or ask for a recipe. I\'ll only use ingredients you have.';

  @override
  String get chatHint => 'Ask about a recipe…';

  @override
  String get chatSuggestion1 => 'What can I cook with salmon?';

  @override
  String get chatSuggestion2 => 'High-protein dinner ideas';

  @override
  String get chatSuggestion3 => 'Quick vegan lunch';

  @override
  String get chatTyping => 'Suppercook is thinking…';

  @override
  String chatMockReply(String title, int minutes, String ingredients) {
    return 'Here\'s an idea: $title. It takes about $minutes minutes and uses $ingredients. Want the full recipe?';
  }

  @override
  String get chatSend => 'Send';

  @override
  String get navHome => 'Home';

  @override
  String get navPlanner => 'Planner';

  @override
  String get navScan => 'Scan';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navProfile => 'Profile';
}
