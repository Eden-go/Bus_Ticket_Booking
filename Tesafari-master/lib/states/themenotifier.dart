// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizes { Small, Medium, Large }

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
      primaryColor: const Color.fromARGB(255, 47, 72, 88),
      primaryColorDark: const Color.fromARGB(255, 80, 80, 80),
      dividerColor: const Color.fromARGB(255, 95, 120, 138),
      brightness: Brightness.dark,
      backgroundColor: const Color.fromARGB(255, 48, 48, 48),
      textTheme: TextTheme(headline2: TextStyle(color: Colors.white)),
      iconTheme: IconThemeData(color: Colors.white),
      focusColor: Colors.indigoAccent,
      shadowColor: Colors.grey[900]!,
      inputDecorationTheme:
          InputDecorationTheme(focusColor: Colors.indigoAccent),
      textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.white, cursorColor: Colors.white),
      buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: Color.fromARGB(255, 47, 65, 77),
              onPrimary: const Color.fromARGB(255, 47, 72, 88),
              secondary: const Color.fromARGB(255, 47, 72, 88),
              onSecondary: const Color.fromARGB(255, 47, 72, 88),
              error: const Color.fromARGB(255, 47, 72, 88),
              onError: const Color.fromARGB(255, 47, 72, 88),
              background: const Color.fromARGB(255, 47, 72, 88),
              onBackground: const Color.fromARGB(255, 47, 72, 88),
              surface: const Color.fromARGB(255, 47, 72, 88),
              onSurface: const Color.fromARGB(255, 47, 72, 88))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(
                  const Color.fromARGB(255, 82, 102, 107)))));

  final lightTheme = ThemeData(
      primaryColor: Colors.indigoAccent,
      dividerColor: const Color.fromARGB(255, 47, 72, 88),
      primaryColorDark: Color.fromARGB(255, 236, 240, 244),
      brightness: Brightness.light,
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBarTheme: AppBarTheme(color: Colors.indigoAccent),
      textTheme: TextTheme(headline2: TextStyle(color: Colors.black)),
      iconTheme: IconThemeData(color: Colors.black),
      focusColor: Colors.indigoAccent,
      inputDecorationTheme:
          InputDecorationTheme(focusColor: Colors.indigoAccent),
      textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.indigoAccent,
          cursorColor: const Color.fromARGB(255, 47, 72, 88)),
      shadowColor: Colors.grey[400]!,
      buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: const Color.fromARGB(255, 11, 106, 120),
              onPrimary: const Color.fromARGB(255, 11, 106, 120),
              secondary: const Color.fromARGB(255, 11, 106, 120),
              onSecondary: const Color.fromARGB(255, 11, 106, 120),
              error: const Color.fromARGB(255, 11, 106, 120),
              onError: const Color.fromARGB(255, 11, 106, 120),
              background: const Color.fromARGB(255, 11, 106, 120),
              onBackground: const Color.fromARGB(255, 11, 106, 120),
              surface: const Color.fromARGB(255, 11, 106, 120),
              onSurface: const Color.fromARGB(255, 11, 106, 120))),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color?>(Colors.red))));

  bool _disposed = false;

  ThemeData? _themeData;
  ThemeData? getTheme() => _themeData;
  final TextTheme fontTheme = TextTheme(
      titleSmall: TextStyle(
          fontFamily: 'Montserrat', color: Colors.white, fontSize: 15),
      titleMedium: TextStyle(
          fontFamily: 'Montserrat', color: Colors.white, fontSize: 20),
      titleLarge: TextStyle(
          fontFamily: 'Montserrat', color: Colors.white, fontSize: 27),
      headlineSmall: TextStyle(fontSize: 15),
      headlineMedium: TextStyle(fontSize: 25),
      headlineLarge: TextStyle(fontSize: 33),
      labelSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
      labelMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      bodySmall: TextStyle(fontSize: 10, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14.5, color: Colors.black),
      bodyLarge: TextStyle(fontSize: 24, color: Colors.black),
      displaySmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 205, 205, 205)),
      displayMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 205, 205, 205)),
      displayLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 205, 205, 205)));

  FontSizes currentSize = FontSizes.Medium;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  ThemeNotifier() {
    bool? isDark;
    _getPref().then((value) {
      if (value != null) {
        isDark = value["isDarkMode"] ?? false;
        currentSize = FontSizes.values[value['fontSize'] ?? 1];

        if (isDark!)
          _themeData = darkTheme;
        else
          _themeData = lightTheme;
      } else
        _themeData = lightTheme;

      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> _getPref() async {
    final pref = await SharedPreferences.getInstance();
    bool? isDarkMode = pref.getBool("darkMode");
    int? currentFontSize = pref.getInt("fontSize");
    return Future.value(
        {"isDarkMode": isDarkMode, "fontSize": currentFontSize});
  }

  void _setDarkPref(bool value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("darkMode", value);
  }

  void setFontPref(FontSizes value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt("fontSize", value.index);
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _setDarkPref(true);
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _setDarkPref(false);
    notifyListeners();
  }

  void setFontSize(FontSizes preferredSize) async {
    currentSize = preferredSize;
    setFontPref(preferredSize);
    notifyListeners();
  }
}
