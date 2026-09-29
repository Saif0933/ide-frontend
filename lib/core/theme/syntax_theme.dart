import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SyntaxThemePreset {
  oneDark,
  monokaiPro,
  dracula,
  githubDark,
}

class SyntaxTheme {
  final String name;
  final Color background;
  final Color gutterBackground;
  final Color gutterText;
  final Color currentLine;
  final Color keyword;
  final Color function;
  final Color string;
  final Color number;
  final Color comment;
  final Color builtin;
  final Color decorator;
  final Color punctuation;
  final Color operator;

  const SyntaxTheme({
    required this.name,
    required this.background,
    required this.gutterBackground,
    required this.gutterText,
    required this.currentLine,
    required this.keyword,
    required this.function,
    required this.string,
    required this.number,
    required this.comment,
    required this.builtin,
    required this.decorator,
    required this.punctuation,
    required this.operator,
  });

  static const SyntaxTheme oneDark = SyntaxTheme(
    name: 'One Dark Pro',
    background: AppColors.editorBackground,
    gutterBackground: AppColors.editorGutter,
    gutterText: AppColors.editorGutterText,
    currentLine: AppColors.editorLineHighlight,
    keyword: AppColors.synKeyword,
    function: AppColors.synFunction,
    string: AppColors.synString,
    number: AppColors.synNumber,
    comment: AppColors.synComment,
    builtin: AppColors.synBuiltin,
    decorator: AppColors.synDecorator,
    punctuation: AppColors.synPunctuation,
    operator: AppColors.synOperator,
  );

  static const SyntaxTheme monokaiPro = SyntaxTheme(
    name: 'Monokai Pro',
    background: Color(0xFF1E1F22),
    gutterBackground: Color(0xFF17181A),
    gutterText: Color(0xFF5B5F66),
    currentLine: Color(0xFF282A2E),
    keyword: Color(0xFFFF6188),
    function: Color(0xFFA9DC76),
    string: Color(0xFFFFD866),
    number: Color(0xFFAB9DF2),
    comment: Color(0xFF727072),
    builtin: Color(0xFF78DCE8),
    decorator: Color(0xFFFC9867),
    punctuation: Color(0xFFF7F1FF),
    operator: Color(0xFFFF6188),
  );

  static const SyntaxTheme dracula = SyntaxTheme(
    name: 'Dracula',
    background: Color(0xFF282A36),
    gutterBackground: Color(0xFF21222C),
    gutterText: Color(0xFF6272A4),
    currentLine: Color(0xFF44475A),
    keyword: Color(0xFFFF79C6),
    function: Color(0xFF50FA7B),
    string: Color(0xFFF1FA8C),
    number: Color(0xFFBD93F9),
    comment: Color(0xFF6272A4),
    builtin: Color(0xFF8BE9FD),
    decorator: Color(0xFFFFB86C),
    punctuation: Color(0xFFF8F8F2),
    operator: Color(0xFFFF79C6),
  );

  static SyntaxTheme getPreset(SyntaxThemePreset preset) {
    switch (preset) {
      case SyntaxThemePreset.oneDark:
        return oneDark;
      case SyntaxThemePreset.monokaiPro:
        return monokaiPro;
      case SyntaxThemePreset.dracula:
        return dracula;
      case SyntaxThemePreset.githubDark:
        return oneDark;
    }
  }
}
