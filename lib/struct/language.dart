enum Language {
  system(0),
  en(1),
  fr(2),
  de(3);

  final int value;

  const Language(this.value);

  static Language getLanguageFromString(String language) {
    switch (language) {
      case "en":
        return Language.en;
      case "fr":
        return Language.fr;
      case "de":
        return Language.de;
      default:
        return Language.system;
    }
  }
}
