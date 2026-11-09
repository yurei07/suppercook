import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension BrightnessContext on BuildContext {
  bool get isDesktopLayout => MediaQuery.sizeOf(this).width >= 900;

  double get pagePadding => isDesktopLayout ? 32 : 20;
}
