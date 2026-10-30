import 'package:flutter/widgets.dart';

import '../../domain/app_language.dart';
import '../../domain/bangla_copy.dart';

class AppLanguageScope extends InheritedWidget {
  const AppLanguageScope({
    super.key,
    required this.language,
    required super.child,
  });

  final AppLanguage language;

  static AppLanguage maybeOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppLanguageScope>()
            ?.language ??
        AppLanguage.english;
  }

  @override
  bool updateShouldNotify(AppLanguageScope oldWidget) {
    return language != oldWidget.language;
  }
}

String uiText(BuildContext context, String english) {
  return localizedUi(AppLanguageScope.maybeOf(context), english);
}
