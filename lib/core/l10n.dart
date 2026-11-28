import 'package:flutter/widgets.dart';

import 'package:scoreboards/l10n/app_localizations.dart';

export 'package:scoreboards/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// The app's texts in the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
