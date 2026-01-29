enum AppLanguage {
  en,
  zh,
}

AppLanguage languageFromCode(String? code) {
  switch (code) {
    case 'zh':
      return AppLanguage.zh;
    case 'en':
    default:
      return AppLanguage.en;
  }
}

String languageCode(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.en:
      return 'en';
    case AppLanguage.zh:
      return 'zh';
  }
}

