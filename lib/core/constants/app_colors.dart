import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF3B82F6); // Vibrant Indigo-Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF10B981); // Emerald Green (Python Run/Success)
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);

  // Dark Theme Palette (IDE Focus)
  static const Color background = Color(0xFF0D1117); // GitHub Dark / Modern IDE Dark
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF21262D);
  static const Color surfaceBorder = Color(0xFF30363D);
  static const Color surfaceHover = Color(0xFF2B313A);

  // Editor Surface Palette
  static const Color editorBackground = Color(0xFF090D12);
  static const Color editorGutter = Color(0xFF121820);
  static const Color editorLineHighlight = Color(0xFF1C2330);
  static const Color editorSelection = Color(0xFF264F78);
  static const Color editorCursor = Color(0xFF58A6FF);
  static const Color editorGutterText = Color(0xFF6E7681);

  // Terminal Palette
  static const Color terminalBackground = Color(0xFF080B10);
  static const Color terminalBorder = Color(0xFF21262D);
  static const Color terminalStdout = Color(0xFFE6EDF3);
  static const Color terminalStderr = Color(0xFFFF7B72);
  static const Color terminalPrompt = Color(0xFF7EE787);

  // Text Colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  static const Color textInverse = Color(0xFF0D1117);

  // Status & Execution Colors
  static const Color statusQueued = Color(0xFFFBBF24); // Amber
  static const Color statusRunning = Color(0xFF38BDF8); // Sky Blue
  static const Color statusSuccess = Color(0xFF34D399); // Mint Green
  static const Color statusFailed = Color(0xFFF87171); // Light Red
  static const Color statusTimedOut = Color(0xFFFB923C); // Orange
  static const Color statusCancelled = Color(0xFF9CA3AF); // Gray

  // Python Syntax Highlighting Palette (One Dark / Monokai Inspired)
  static const Color synKeyword = Color(0xFFFF7B72); // def, class, return, if, for, in, import
  static const Color synFunction = Color(0xFFD2A8FF); // function names, methods
  static const Color synString = Color(0xFFA5D6FF); // strings, docstrings
  static const Color synNumber = Color(0xFF79C0FF); // 123, 3.14
  static const Color synComment = Color(0xFF8B949E); // # comments
  static const Color synBuiltin = Color(0xFFFFA657); // print, len, range, str, int, dict
  static const Color synDecorator = Color(0xFF7EE787); // @decorator
  static const Color synVariable = Color(0xFFFFA657); // self, cls, params
  static const Color synPunctuation = Color(0xFFC9D1D9); // :, (, ), [, ], {, }
  static const Color synOperator = Color(0xFFFF7B72); // +, -, *, /, ==, !=

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient runGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stopGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
