import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Suppercook'**
  String get appName;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming in the next iteration.'**
  String get comingSoonBody;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @minShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minShort(int minutes);

  /// No description provided for @kcalShort.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String kcalShort(int value);

  /// No description provided for @servingsShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 serving} other{{count} servings}}'**
  String servingsShort(int count);

  /// No description provided for @matchPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String matchPercent(int percent);

  /// No description provided for @missingLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing missing} =1{1 missing} other{{count} missing}}'**
  String missingLabel(int count);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String selectedCount(int count);

  /// No description provided for @viewRecipe.
  ///
  /// In en, this message translates to:
  /// **'View recipe'**
  String get viewRecipe;

  /// No description provided for @perServing.
  ///
  /// In en, this message translates to:
  /// **'per serving'**
  String get perServing;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes'**
  String get searchRecipes;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change it anytime in your profile.'**
  String get languageSubtitle;

  /// No description provided for @languagePreview.
  ///
  /// In en, this message translates to:
  /// **'Tonight we\'re cooking something amazing.'**
  String get languagePreview;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Cook with what you have'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo of your fridge or pantry and get recipes that fit your ingredients.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Your smart shopping list'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'We add only what\'s missing — no duplicate buying, no waste.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Plan your week in minutes'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Balanced meals, calories and macros tailored to your goals.'**
  String get onboardingBody3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip intro'**
  String get onboardingSkip;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Suppercook'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your kitchen, smarter.'**
  String get authSubtitle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get continueWithEmail;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @authTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Privacy Policy.'**
  String get authTerms;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize your kitchen'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us suggest meals that actually fit you.'**
  String get setupSubtitle;

  /// No description provided for @nameQuestion.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameQuestion;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabel;

  /// No description provided for @dietTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you eat?'**
  String get dietTitle;

  /// No description provided for @dietOmnivore.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get dietOmnivore;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietVegan;

  /// No description provided for @dietPescatarian.
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get dietPescatarian;

  /// No description provided for @dietGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get dietGlutenFree;

  /// No description provided for @allergiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Any allergies?'**
  String get allergiesTitle;

  /// No description provided for @allergyNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get allergyNone;

  /// No description provided for @allergyNuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get allergyNuts;

  /// No description provided for @allergyDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get allergyDairy;

  /// No description provided for @allergyEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergyEggs;

  /// No description provided for @allergyGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergyGluten;

  /// No description provided for @allergySoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergySoy;

  /// No description provided for @allergyShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergyShellfish;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get goalTitle;

  /// No description provided for @goalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get goalLose;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get goalMaintain;

  /// No description provided for @goalGain.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get goalGain;

  /// No description provided for @caloriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie target'**
  String get caloriesTitle;

  /// No description provided for @caloriesValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kcal'**
  String caloriesValue(int value);

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get finishSetup;

  /// No description provided for @setupHint.
  ///
  /// In en, this message translates to:
  /// **'You can change all of this later.'**
  String get setupHint;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What are we cooking today?'**
  String get homeSubtitle;

  /// No description provided for @scanIngredients.
  ///
  /// In en, this message translates to:
  /// **'Scan ingredients'**
  String get scanIngredients;

  /// No description provided for @quickScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get quickScan;

  /// No description provided for @quickPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get quickPantry;

  /// No description provided for @quickPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get quickPlanner;

  /// No description provided for @quickChat.
  ///
  /// In en, this message translates to:
  /// **'AI chef'**
  String get quickChat;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommended;

  /// No description provided for @fromPantry.
  ///
  /// In en, this message translates to:
  /// **'From your pantry'**
  String get fromPantry;

  /// No description provided for @noPantryYet.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to see personalized recipes'**
  String get noPantryYet;

  /// No description provided for @addProducts.
  ///
  /// In en, this message translates to:
  /// **'Add products'**
  String get addProducts;

  /// No description provided for @chefTip.
  ///
  /// In en, this message translates to:
  /// **'Chef\'s tip'**
  String get chefTip;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your ingredients'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at your fridge shelf or upload a photo.'**
  String get scanSubtitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @useSample.
  ///
  /// In en, this message translates to:
  /// **'Use sample photo'**
  String get useSample;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your ingredients…'**
  String get analyzing;

  /// No description provided for @analyzingHint.
  ///
  /// In en, this message translates to:
  /// **'Our AI is identifying what\'s on the photo.'**
  String get analyzingHint;

  /// No description provided for @detectedTitle.
  ///
  /// In en, this message translates to:
  /// **'We found {count} ingredients'**
  String detectedTitle(int count);

  /// No description provided for @detectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check the list and edit anything that\'s wrong.'**
  String get detectedSubtitle;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name'**
  String get ingredientName;

  /// No description provided for @findRecipes.
  ///
  /// In en, this message translates to:
  /// **'Find recipes'**
  String get findRecipes;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t analyze the photo. Try again or add ingredients manually.'**
  String get scanError;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available on this device. Upload a photo instead.'**
  String get cameraUnavailable;

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes for you'**
  String get suggestionsTitle;

  /// No description provided for @suggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} ideas from your ingredients'**
  String suggestionsSubtitle(int count);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterQuick.
  ///
  /// In en, this message translates to:
  /// **'Under 20 min'**
  String get filterQuick;

  /// No description provided for @filterVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get filterVegan;

  /// No description provided for @filterHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get filterHighProtein;

  /// No description provided for @noRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesTitle;

  /// No description provided for @noRecipesBody.
  ///
  /// In en, this message translates to:
  /// **'Add a few more ingredients and try again.'**
  String get noRecipesBody;

  /// No description provided for @matchLabel.
  ///
  /// In en, this message translates to:
  /// **'match'**
  String get matchLabel;

  /// No description provided for @noMissing.
  ///
  /// In en, this message translates to:
  /// **'You have everything'**
  String get noMissing;

  /// No description provided for @ingredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsTitle;

  /// No description provided for @stepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsTitle;

  /// No description provided for @youHave.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get youHave;

  /// No description provided for @youNeed.
  ///
  /// In en, this message translates to:
  /// **'You need'**
  String get youNeed;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per serving'**
  String get nutritionTitle;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start cooking'**
  String get startCooking;

  /// No description provided for @addMissingToList.
  ///
  /// In en, this message translates to:
  /// **'Add missing to list'**
  String get addMissingToList;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'Added to your shopping list'**
  String get addedToList;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsLabel;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get recipeNotFound;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @timerLabel.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerLabel;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get startTimer;

  /// No description provided for @pauseTimer.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTimer;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get nextStep;

  /// No description provided for @previousStep.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get previousStep;

  /// No description provided for @finishCooking.
  ///
  /// In en, this message translates to:
  /// **'Finish cooking'**
  String get finishCooking;

  /// No description provided for @cookingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal!'**
  String get cookingDoneTitle;

  /// No description provided for @cookingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Bon appétit! Your shopping list has been updated.'**
  String get cookingDoneBody;

  /// No description provided for @ratePrompt.
  ///
  /// In en, this message translates to:
  /// **'How did it turn out?'**
  String get ratePrompt;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @timerDone.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get timerDone;

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingTitle;

  /// No description provided for @shoppingProgress.
  ///
  /// In en, this message translates to:
  /// **'{checked} of {total} bought'**
  String shoppingProgress(int checked, int total);

  /// No description provided for @shoppingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty'**
  String get shoppingEmpty;

  /// No description provided for @shoppingEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add missing ingredients from any recipe.'**
  String get shoppingEmptyBody;

  /// No description provided for @categoryProduce.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get categoryProduce;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy & eggs'**
  String get categoryDairy;

  /// No description provided for @categoryPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get categoryPantry;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @alreadyAtHome.
  ///
  /// In en, this message translates to:
  /// **'Already at home'**
  String get alreadyAtHome;

  /// No description provided for @clearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear bought'**
  String get clearChecked;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemTitle;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get addToList;

  /// No description provided for @shoppingAtHomeHint.
  ///
  /// In en, this message translates to:
  /// **'These items are already in your pantry'**
  String get shoppingAtHomeHint;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @plannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal planner'**
  String get plannerTitle;

  /// No description provided for @plannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your week at a glance'**
  String get plannerSubtitle;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMeal;

  /// No description provided for @generatePlan.
  ///
  /// In en, this message translates to:
  /// **'Generate plan'**
  String get generatePlan;

  /// No description provided for @planGenerated.
  ///
  /// In en, this message translates to:
  /// **'Your week is planned'**
  String get planGenerated;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences and account'**
  String get profileSubtitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @dietLabel.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get dietLabel;

  /// No description provided for @allergiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesLabel;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About Suppercook'**
  String get aboutLabel;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Suppercook is your smart kitchen companion. It turns the ingredients you already have into recipes, plans and a shopping list that never buys twice.'**
  String get aboutBody;

  /// No description provided for @resetDemo.
  ///
  /// In en, this message translates to:
  /// **'Reset demo data'**
  String get resetDemo;

  /// No description provided for @resetDemoBody.
  ///
  /// In en, this message translates to:
  /// **'This clears your pantry, shopping list and onboarding state.'**
  String get resetDemoBody;

  /// No description provided for @resetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset demo?'**
  String get resetDialogTitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @recipesCooked.
  ///
  /// In en, this message translates to:
  /// **'Recipes cooked'**
  String get recipesCooked;

  /// No description provided for @savedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved recipes'**
  String get savedRecipes;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSection;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageChanged;

  /// No description provided for @pantryTitle.
  ///
  /// In en, this message translates to:
  /// **'My pantry'**
  String get pantryTitle;

  /// No description provided for @pantrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item at home} other{{count} items at home}}'**
  String pantrySubtitle(int count);

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your pantry is empty'**
  String get pantryEmpty;

  /// No description provided for @pantryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan your fridge or add items manually.'**
  String get pantryEmptyBody;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteItem;

  /// No description provided for @addToPantry.
  ///
  /// In en, this message translates to:
  /// **'Add to pantry'**
  String get addToPantry;

  /// No description provided for @pantryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Pantry updated'**
  String get pantryUpdated;

  /// No description provided for @emptyPantryCta.
  ///
  /// In en, this message translates to:
  /// **'Scan products'**
  String get emptyPantryCta;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI chef'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cook with what you have'**
  String get chatSubtitle;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! Tell me what\'s in your fridge, or ask for a recipe. I\'ll only use ingredients you have.'**
  String get chatGreeting;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about a recipe…'**
  String get chatHint;

  /// No description provided for @chatSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'What can I cook with salmon?'**
  String get chatSuggestion1;

  /// No description provided for @chatSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'High-protein dinner ideas'**
  String get chatSuggestion2;

  /// No description provided for @chatSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Quick vegan lunch'**
  String get chatSuggestion3;

  /// No description provided for @chatTyping.
  ///
  /// In en, this message translates to:
  /// **'Suppercook is thinking…'**
  String get chatTyping;

  /// No description provided for @chatMockReply.
  ///
  /// In en, this message translates to:
  /// **'Here\'s an idea: {title}. It takes about {minutes} minutes and uses {ingredients}. Want the full recipe?'**
  String chatMockReply(String title, int minutes, String ingredients);

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get navPlanner;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
