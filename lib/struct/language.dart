enum Language {
  en(0),
  fr(1),
  system(2);

  final int value;

  const Language(this.value);

  static Language getLanguageFromString(String language) {
    switch (language) {
      case "en":
        return Language.en;
      case "fr":
        return Language.fr;
      default:
        return Language.system;
    }
  }
}
