import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme({Color? primary, double? fontScale}) => ThemeData(
    brightness: Brightness.light,
    primarySwatch: primary != null ? MaterialColor(primary.value, _swatch(primary)) : Colors.blue,
    textTheme: _scaledTextTheme(ThemeData.light().textTheme, fontScale),
  );
  static ThemeData darkTheme({Color? primary, double? fontScale}) => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: primary != null ? MaterialColor(primary.value, _swatch(primary)) : Colors.blue,
    textTheme: _scaledTextTheme(ThemeData.dark().textTheme, fontScale),
  );
  static Map<String, Color> presetColors = {
    'Biru': Colors.blue,
    'Merah': Colors.red,
    'Hijau': Colors.green,
    'Ungu': Colors.purple,
    'Oranye': Colors.orange,
  };
  static Map<String, double> fontScales = {
    'Kecil': 0.85,
    'Normal': 1.0,
    'Besar': 1.2,
  };
  static Map<int, Color> _swatch(Color color) {
    return {
      50: color.withOpacity(.1),
      100: color.withOpacity(.2),
      200: color.withOpacity(.3),
      300: color.withOpacity(.4),
      400: color.withOpacity(.5),
      500: color.withOpacity(.6),
      600: color.withOpacity(.7),
      700: color.withOpacity(.8),
      800: color.withOpacity(.9),
      900: color.withOpacity(1),
    };
  }
  static TextTheme _scaledTextTheme(TextTheme base, double? scale) {
    if (scale == null || scale == 1.0) return base;
    return base.copyWith(
      headline1: base.headline1?.copyWith(fontSize: base.headline1!.fontSize! * scale),
      headline2: base.headline2?.copyWith(fontSize: base.headline2!.fontSize! * scale),
      headline3: base.headline3?.copyWith(fontSize: base.headline3!.fontSize! * scale),
      headline4: base.headline4?.copyWith(fontSize: base.headline4!.fontSize! * scale),
      headline5: base.headline5?.copyWith(fontSize: base.headline5!.fontSize! * scale),
      headline6: base.headline6?.copyWith(fontSize: base.headline6!.fontSize! * scale),
      bodyText1: base.bodyText1?.copyWith(fontSize: base.bodyText1!.fontSize! * scale),
      bodyText2: base.bodyText2?.copyWith(fontSize: base.bodyText2!.fontSize! * scale),
      subtitle1: base.subtitle1?.copyWith(fontSize: base.subtitle1!.fontSize! * scale),
      subtitle2: base.subtitle2?.copyWith(fontSize: base.subtitle2!.fontSize! * scale),
      caption: base.caption?.copyWith(fontSize: base.caption!.fontSize! * scale),
      button: base.button?.copyWith(fontSize: base.button!.fontSize! * scale),
      overline: base.overline?.copyWith(fontSize: base.overline!.fontSize! * scale),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;
  double _fontScale = 1.0;
  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  double get fontScale => _fontScale;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }
}