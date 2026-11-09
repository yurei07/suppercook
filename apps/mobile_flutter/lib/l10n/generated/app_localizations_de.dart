// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Suppercook';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get skip => 'Überspringen';

  @override
  String get back => 'Zurück';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get done => 'Fertig';

  @override
  String get next => 'Weiter';

  @override
  String get search => 'Suchen';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get comingSoon => 'Bald verfügbar';

  @override
  String get comingSoonBody => 'Diese Funktion kommt in der nächsten Version.';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get apply => 'Übernehmen';

  @override
  String get all => 'Alle';

  @override
  String get confirm => 'Bestätigen';

  @override
  String minShort(int minutes) {
    return '$minutes Min.';
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
      other: '$count Portionen',
      one: '1 Portion',
    );
    return '$_temp0';
  }

  @override
  String matchPercent(int percent) {
    return '$percent % passend';
  }

  @override
  String missingLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fehlen',
      one: '1 fehlt',
      zero: 'Nichts fehlt',
    );
    return '$_temp0';
  }

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get viewRecipe => 'Rezept ansehen';

  @override
  String get perServing => 'pro Portion';

  @override
  String get searchRecipes => 'Rezepte suchen';

  @override
  String get languageTitle => 'Wähle deine Sprache';

  @override
  String get languageSubtitle => 'Du kannst sie jederzeit im Profil ändern.';

  @override
  String get languagePreview => 'Heute Abend kochen wir etwas Großartiges.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get onboardingTitle1 => 'Koche mit dem, was du hast';

  @override
  String get onboardingBody1 =>
      'Fotografiere deinen Kühlschrank oder Vorrat und erhalte Rezepte, die zu deinen Zutaten passen.';

  @override
  String get onboardingTitle2 => 'Deine intelligente Einkaufsliste';

  @override
  String get onboardingBody2 =>
      'Wir ergänzen nur, was fehlt – kein doppelter Einkauf, keine Verschwendung.';

  @override
  String get onboardingTitle3 => 'Plane deine Woche in Minuten';

  @override
  String get onboardingBody3 =>
      'Ausgewogene Mahlzeiten, Kalorien und Makros passend zu deinen Zielen.';

  @override
  String get getStarted => 'Los geht\'s';

  @override
  String get onboardingSkip => 'Intro überspringen';

  @override
  String get authTitle => 'Willkommen bei Suppercook';

  @override
  String get authSubtitle => 'Deine Küche, intelligenter.';

  @override
  String get continueWithApple => 'Mit Apple fortfahren';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get continueWithEmail => 'Mit E-Mail fortfahren';

  @override
  String get continueAsGuest => 'Als Gast fortfahren';

  @override
  String get authTerms =>
      'Mit dem Fortfahren stimmst du unseren AGB und der Datenschutzerklärung zu.';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get setupTitle => 'Lass uns deine Küche personalisieren';

  @override
  String get setupSubtitle =>
      'So können wir Mahlzeiten empfehlen, die wirklich zu dir passen.';

  @override
  String get nameQuestion => 'Wie dürfen wir dich nennen?';

  @override
  String get nameHint => 'Dein Name';

  @override
  String get orLabel => 'oder';

  @override
  String get dietTitle => 'Was isst du?';

  @override
  String get dietOmnivore => 'Alles';

  @override
  String get dietVegetarian => 'Vegetarisch';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietPescatarian => 'Pescetarisch';

  @override
  String get dietGlutenFree => 'Glutenfrei';

  @override
  String get allergiesTitle => 'Allergien?';

  @override
  String get allergyNone => 'Keine';

  @override
  String get allergyNuts => 'Nüsse';

  @override
  String get allergyDairy => 'Milchprodukte';

  @override
  String get allergyEggs => 'Eier';

  @override
  String get allergyGluten => 'Gluten';

  @override
  String get allergySoy => 'Soja';

  @override
  String get allergyShellfish => 'Meeresfrüchte';

  @override
  String get goalTitle => 'Dein Ziel';

  @override
  String get goalLose => 'Abnehmen';

  @override
  String get goalMaintain => 'Halten';

  @override
  String get goalGain => 'Muskeln aufbauen';

  @override
  String get caloriesTitle => 'Tägliches Kalorienziel';

  @override
  String caloriesValue(int value) {
    return '$value kcal';
  }

  @override
  String get finishSetup => 'Los kochen';

  @override
  String get setupHint => 'Du kannst alles später ändern.';

  @override
  String greetingMorning(String name) {
    return 'Guten Morgen, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Guten Tag, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Guten Abend, $name';
  }

  @override
  String get homeSubtitle => 'Was kochen wir heute?';

  @override
  String get scanIngredients => 'Zutaten scannen';

  @override
  String get quickScan => 'Scannen';

  @override
  String get quickPantry => 'Vorrat';

  @override
  String get quickPlanner => 'Planer';

  @override
  String get quickChat => 'KI-Koch';

  @override
  String get recommended => 'Für dich empfohlen';

  @override
  String get fromPantry => 'Aus deinem Vorrat';

  @override
  String get noPantryYet =>
      'Füge Zutaten hinzu, um persönliche Rezepte zu sehen';

  @override
  String get addProducts => 'Produkte hinzufügen';

  @override
  String get chefTip => 'Tipp vom Koch';

  @override
  String get scanTitle => 'Zutaten scannen';

  @override
  String get scanSubtitle =>
      'Richte die Kamera auf dein Kühlschrankfach oder lade ein Foto hoch.';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get uploadPhoto => 'Foto hochladen';

  @override
  String get useSample => 'Beispielfoto verwenden';

  @override
  String get analyzing => 'Zutaten werden analysiert…';

  @override
  String get analyzingHint => 'Unsere KI erkennt, was auf dem Foto ist.';

  @override
  String detectedTitle(int count) {
    return 'Wir haben $count Zutaten gefunden';
  }

  @override
  String get detectedSubtitle =>
      'Prüfe die Liste und korrigiere alles, was nicht stimmt.';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get ingredientName => 'Name der Zutat';

  @override
  String get findRecipes => 'Rezepte finden';

  @override
  String get scanError =>
      'Das Foto konnte nicht analysiert werden. Versuche es erneut oder füge Zutaten manuell hinzu.';

  @override
  String get cameraUnavailable =>
      'Die Kamera ist auf diesem Gerät nicht verfügbar. Lade stattdessen ein Foto hoch.';

  @override
  String get suggestionsTitle => 'Rezepte für dich';

  @override
  String suggestionsSubtitle(int count) {
    return '$count Ideen aus deinen Zutaten';
  }

  @override
  String get filterAll => 'Alle';

  @override
  String get filterQuick => 'Unter 20 Min.';

  @override
  String get filterVegan => 'Vegan';

  @override
  String get filterHighProtein => 'Proteinreich';

  @override
  String get loadingRecipes => 'Rezepte werden geladen…';

  @override
  String get liveBadge => 'Live-API';

  @override
  String get demoBadge => 'Demo-Daten';

  @override
  String get noRecipesTitle => 'Noch keine Rezepte';

  @override
  String get noRecipesBody =>
      'Füge noch ein paar Zutaten hinzu und versuche es erneut.';

  @override
  String get matchLabel => 'passend';

  @override
  String get noMissing => 'Du hast alles';

  @override
  String get ingredientsTitle => 'Zutaten';

  @override
  String get stepsTitle => 'Zubereitung';

  @override
  String get youHave => 'Hast du';

  @override
  String get youNeed => 'Brauchst du';

  @override
  String get nutritionTitle => 'Nährwerte pro Portion';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Kohlenhydrate';

  @override
  String get fat => 'Fett';

  @override
  String get calories => 'Kalorien';

  @override
  String get startCooking => 'Los kochen';

  @override
  String get addMissingToList => 'Fehlendes zur Liste';

  @override
  String get addedToList => 'Zur Einkaufsliste hinzugefügt';

  @override
  String get servingsLabel => 'Portionen';

  @override
  String get difficultyEasy => 'Einfach';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get recipeNotFound => 'Rezept nicht gefunden';

  @override
  String stepOf(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get timerLabel => 'Timer';

  @override
  String get startTimer => 'Timer starten';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get nextStep => 'Nächster Schritt';

  @override
  String get previousStep => 'Zurück';

  @override
  String get finishCooking => 'Fertig kochen';

  @override
  String get cookingDoneTitle => 'Guten Appetit!';

  @override
  String get cookingDoneBody =>
      'Guten Appetit! Deine Einkaufsliste wurde aktualisiert.';

  @override
  String get ratePrompt => 'Wie ist es geworden?';

  @override
  String get backToHome => 'Zur Startseite';

  @override
  String get timerDone => 'Zeit ist um!';

  @override
  String get shoppingTitle => 'Einkaufsliste';

  @override
  String shoppingProgress(int checked, int total) {
    return '$checked von $total gekauft';
  }

  @override
  String get shoppingEmpty => 'Deine Liste ist leer';

  @override
  String get shoppingEmptyBody =>
      'Füge fehlende Zutaten aus einem Rezept hinzu.';

  @override
  String get categoryProduce => 'Obst & Gemüse';

  @override
  String get categoryDairy => 'Milchprodukte & Eier';

  @override
  String get categoryPantry => 'Vorrat';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get alreadyAtHome => 'Schon zu Hause';

  @override
  String get clearChecked => 'Gekauftes entfernen';

  @override
  String get addItemTitle => 'Artikel hinzufügen';

  @override
  String get itemName => 'Name des Artikels';

  @override
  String get addToList => 'Zur Liste hinzufügen';

  @override
  String get shoppingAtHomeHint =>
      'Diese Artikel sind bereits in deinem Vorrat';

  @override
  String get noItems => 'Keine Artikel';

  @override
  String get plannerTitle => 'Wochenplan';

  @override
  String get plannerSubtitle => 'Deine Woche auf einen Blick';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get addMeal => 'Mahlzeit hinzufügen';

  @override
  String get generatePlan => 'Plan generieren';

  @override
  String get planGenerated => 'Deine Woche ist geplant';

  @override
  String get today => 'Heute';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSubtitle => 'Einstellungen und Konto';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get dataSourceLabel => 'Datenquelle';

  @override
  String get dataSourceDemo => 'Demo-Daten';

  @override
  String get dataSourceApi => 'Live-API';

  @override
  String get dataSourceHint =>
      'Demo-Daten funktionieren offline. Die Live-API verbindet sich mit dem NestJS-Backend in deinem Netzwerk.';

  @override
  String get dataSourceDemoHint => 'Integrierte Rezepte; kein Backend nötig.';

  @override
  String get dataSourceApiHint =>
      'Rezepte und Fotoerkennung aus der NestJS-API.';

  @override
  String get apiEnabled => 'Live-API aktiviert';

  @override
  String get apiUnreachable =>
      'Die API ist nicht erreichbar. Läuft das Backend?';

  @override
  String get apiSyncFailed =>
      'Synchronisierung fehlgeschlagen – lokale Daten werden angezeigt.';

  @override
  String get dietLabel => 'Ernährung';

  @override
  String get allergiesLabel => 'Allergien';

  @override
  String get goalLabel => 'Ziel';

  @override
  String get notificationsLabel => 'Benachrichtigungen';

  @override
  String get aboutLabel => 'Über Suppercook';

  @override
  String get aboutBody =>
      'Suppercook ist dein smarter Küchenbegleiter. Es verwandelt deine vorhandenen Zutaten in Rezepte, Pläne und eine Einkaufsliste, die nie doppelt kauft.';

  @override
  String get resetDemo => 'Demo-Daten zurücksetzen';

  @override
  String get resetDemoBody =>
      'Dies löscht deinen Vorrat, die Einkaufsliste und den Onboarding-Status.';

  @override
  String get resetDialogTitle => 'Demo zurücksetzen?';

  @override
  String get signOut => 'Abmelden';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get recipesCooked => 'Gekochte Rezepte';

  @override
  String get savedRecipes => 'Gespeicherte Rezepte';

  @override
  String get settingsSection => 'Einstellungen';

  @override
  String get accountSection => 'Konto';

  @override
  String get languageChanged => 'Sprache aktualisiert';

  @override
  String get pantryTitle => 'Mein Vorrat';

  @override
  String pantrySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel zu Hause',
      one: '1 Artikel zu Hause',
    );
    return '$_temp0';
  }

  @override
  String get pantryEmpty => 'Dein Vorrat ist leer';

  @override
  String get pantryEmptyBody =>
      'Scanne deinen Kühlschrank oder füge Artikel manuell hinzu.';

  @override
  String get addProduct => 'Produkt hinzufügen';

  @override
  String get productName => 'Name des Produkts';

  @override
  String get deleteItem => 'Löschen';

  @override
  String get addToPantry => 'Zum Vorrat hinzufügen';

  @override
  String get pantryUpdated => 'Vorrat aktualisiert';

  @override
  String get emptyPantryCta => 'Produkte scannen';

  @override
  String get chatTitle => 'KI-Koch';

  @override
  String get chatSubtitle => 'Koche mit dem, was du hast';

  @override
  String get chatGreeting =>
      'Hallo! Sag mir, was in deinem Kühlschrank ist, oder frag nach einem Rezept. Ich verwende nur Zutaten, die du hast.';

  @override
  String get chatHint => 'Frag nach einem Rezept…';

  @override
  String get chatSuggestion1 => 'Was kann ich mit Lachs kochen?';

  @override
  String get chatSuggestion2 => 'Proteinreiche Abendessen';

  @override
  String get chatSuggestion3 => 'Schnelles veganes Mittagessen';

  @override
  String get chatTyping => 'Suppercook denkt nach…';

  @override
  String chatMockReply(String title, int minutes, String ingredients) {
    return 'Wie wäre es mit $title? Es dauert etwa $minutes Minuten und verwendet $ingredients. Möchtest du das ganze Rezept?';
  }

  @override
  String get chatSend => 'Senden';

  @override
  String get navHome => 'Start';

  @override
  String get navPlanner => 'Planer';

  @override
  String get navScan => 'Scannen';

  @override
  String get navShopping => 'Einkauf';

  @override
  String get navProfile => 'Profil';
}
