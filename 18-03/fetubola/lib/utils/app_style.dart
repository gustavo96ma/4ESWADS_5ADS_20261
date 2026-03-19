import 'package:flutter/material.dart';

class AppStyle {
  AppStyle._();

  // Colors
  static const Color primaryColor = Colors.green;
  static const Color onPrimaryColor = Colors.white;
  static const Color titleColor = Colors.black;

  // Font
  static const String defaultFontFamily = 'Roboto';
  static const double sectionTitleFontSize = 20.0;

  // Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);

  // Spacing
  static const double smallSpacing = 16.0;
  static const double largeSpacing = 32.0;

  // Text Styles
  static const TextStyle sectionTitleStyle = TextStyle(
    color: titleColor,
    fontSize: sectionTitleFontSize,
  );

  static const TextStyle listTileTitleStyle = TextStyle(
    fontFamily: defaultFontFamily,
  );

  static const TextStyle imageDescriptionStyle = TextStyle(
    fontStyle: FontStyle.italic,
  );

  static const TextStyle authorStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  static const TextStyle appBarTitleStyle = TextStyle(
    color: onPrimaryColor,
  );

  // Icon Theme
  static const IconThemeData appBarIconTheme = IconThemeData(
    color: onPrimaryColor,
  );
}
