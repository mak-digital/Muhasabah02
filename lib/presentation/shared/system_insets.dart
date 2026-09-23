import 'package:flutter/widgets.dart';

/// Bottom inset for scrollable/sheet content.
///
/// Keyboard (`viewInsets`) replaces system navigation (`viewPadding`) while
/// open so both are not stacked. Adds [spacing] once as design padding.
///
/// Uses [MediaQuery.viewPadding] unless [systemBottom] is passed. A Scaffold
/// with a NavigationBar consumes that MediaQuery inset; tab content must keep
/// the zero so it is not stacked on the bar. Modal sheets overlay the bar and
/// should pass [presentingSystemBottom] instead of reading [View.viewPadding]
/// here, which would also pad tab roots.
double contentBottomInset(
  BuildContext context, {
  double spacing = 16,
  double? systemBottom,
}) {
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  final system = systemBottom ?? MediaQuery.viewPaddingOf(context).bottom;
  return spacing + (keyboard > 0 ? keyboard : system);
}

/// System bottom inset from the presenting route.
///
/// Recovers [View.viewPadding] only when MediaQuery has already been consumed
/// (Scaffold body or modal). An explicit MediaQuery zero on a route that is
/// not overlaying the system UI should call [contentBottomInset] without this.
double presentingSystemBottom(BuildContext context) {
  final media = MediaQuery.viewPaddingOf(context).bottom;
  if (media > 0) return media;
  final view = View.of(context);
  return view.viewPadding.bottom / view.devicePixelRatio;
}

EdgeInsets sheetContentPadding(
  BuildContext context, {
  double spacing = 16,
  double? systemBottom,
}) {
  return EdgeInsets.fromLTRB(
    16,
    0,
    16,
    contentBottomInset(context, spacing: spacing, systemBottom: systemBottom),
  );
}

/// Padding for pushed full-screen lists without a sticky bottom bar.
///
/// Bottom uses [contentBottomInset]. Do not wrap the same list in SafeArea
/// bottom padding.
EdgeInsets pageListPadding(BuildContext context, {double spacing = 16}) {
  return EdgeInsets.fromLTRB(
    spacing,
    spacing,
    spacing,
    contentBottomInset(context, spacing: spacing),
  );
}
