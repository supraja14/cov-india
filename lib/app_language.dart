import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale ?? Locale("en");

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('en');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    print(type.languageCode);
    if (_appLocale == type) {
      return;
    }
    _appLocale = type;
    await prefs.setString('language_code', type.languageCode);
    notifyListeners();
  }
}
