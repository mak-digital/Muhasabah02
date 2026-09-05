class ProgressMarker {
  ProgressMarker._();

  static const double size = 14;
}

class AppDimensions {
  AppDimensions._();

  static const double progressMarker = ProgressMarker.size;
  static const double progressMarkerGap = 4;
  static const double progressMarkerStroke = 1.5;
  static const double progressMarkerSymbol = progressMarker * 0.48;
  static const double progressMarkerStar = progressMarker * 0.65;
  static const double progressMarkerCaptionHeight = 14;
  static const double progressWeekdayLabelWidth = 16;
  static const double progressCalendarHeaderHeight = 16;

  static const double progressCalendarStride =
      progressMarker + progressMarkerGap;
}
