import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_language.dart';

class AppLanguageProvider extends ChangeNotifier {
  AppLanguageProvider() {
    _load();
  }

  static const _kKey = 'app_language';

  AppLanguage _language = AppLanguage.en;
  bool _loaded = false;

  AppLanguage get language => _language;
  bool get loaded => _loaded;

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_kKey);
    _language = languageFromCode(code);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, languageCode(lang));
  }
}

