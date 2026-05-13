import 'package:flutter/material.dart';


class SignLocale {
  final String word;
  final String? description;

  const SignLocale({
    required this.word,
    this.description,
  });
}

class Sign {
  final String modelLabel;

  final String name;

  final String emoji;

  final Color color;

  final String imagePath;


  final String? videoPath;

  final Map<String, SignLocale> locales;

  const Sign({
    required this.modelLabel,
    required this.name,
    required this.emoji,
    required this.color,
    required this.imagePath,
    required this.locales,
    this.videoPath,
  });

  String get displayName => name.replaceAll('_', ' ');

  String wordFor(String localeCode) =>
      locales[localeCode]?.word ?? locales['en']!.word;

  String descriptionFor(String localeCode) =>
      locales[localeCode]?.description ??
      locales['en']!.description ??
      '';

  Iterable<String> get availableLocales => locales.keys;
}