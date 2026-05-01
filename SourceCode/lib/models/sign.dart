import 'package:flutter/material.dart';

class Sign {

  final String modelLabel;
  final String name;
  String get displayName => name.replaceAll('_', ' ');
  final String translation;
  final String secondTranslation;
  final Color color;
  final String imagePath;
  final String? videoPath;
  final String description;
  final String emoji;

  const Sign({
    required this.modelLabel,
    required this.name,
    required this.translation,
    required this.secondTranslation,
    required this.color,
    required this.imagePath,
    required this.description,
    required this.emoji,
    this.videoPath,
  });
}