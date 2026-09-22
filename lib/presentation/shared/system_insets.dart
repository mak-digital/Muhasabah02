import 'package:flutter/widgets.dart';

/// Bottom inset for scrollable/sheet content.
///
/// Keyboard (`viewInsets`) replaces system navigation (`viewPadding`) while
/// open so both are not stacked. Adds [spacing] once as design padding.
double contentBottomInset(BuildContext context, {double spacing = 16}) {
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  final system = MediaQuery.viewPaddingOf(context).bottom;
  return spacing + (keyboard > 0 ? keyboard : system);
}

EdgeInsets sheetContentPadding(BuildContext context, {double spacing = 16}) {
  return EdgeInsets.fromLTRB(
    16,
    0,
    16,
    contentBottomInset(context, spacing: spacing),
  );
}
