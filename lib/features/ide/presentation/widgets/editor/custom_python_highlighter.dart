import 'package:flutter/material.dart';
import 'package:frontend/core/theme/syntax_theme.dart';
import 'package:frontend/core/theme/app_theme.dart';

class PythonSyntaxHighlighter extends TextEditingController {
  SyntaxTheme syntaxTheme;
  double fontSize;

  PythonSyntaxHighlighter({
    super.text,
    required this.syntaxTheme,
    this.fontSize = 13.5,
  });

  static const Set<String> _keywords = {
    'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue',
    'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from',
    'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not',
    'or', 'pass', 'raise', 'return', 'try', 'while', 'with', 'yield',
    'True', 'False', 'None',
  };

  static const Set<String> _builtins = {
    'print', 'len', 'range', 'str', 'int', 'float', 'list', 'dict', 'set',
    'tuple', 'bool', 'type', 'enumerate', 'zip', 'sum', 'min', 'max', 'abs',
    'round', 'open', 'map', 'filter', 'sorted', 'any', 'all', 'super',
    'isinstance', 'issubclass', 'id', 'hash', 'input', 'format',
  };

  static final RegExp _syntaxRegex = RegExp(
    r'(#[^\n]*)|'
    r'("""[\s\S]*?"""|'
    r"'''[\s\S]*?'''|"
    r'f"[^"\\]*(?:\\.[^"\\]*)*"|'
    r"f'[^'\\]*(?:\\.[^'\\]*)*'|"
    r'"[^"\\]*(?:\\.[^"\\]*)*"|'
    r"'[^'\\]*(?:\\.[^'\\]*)*')|"
    r'(@[a-zA-Z_]\w*)|'
    r'(\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b)|'
    r'(\b[a-zA-Z_]\w*(?=\s*\())|'
    r'(\b[a-zA-Z_]\w*\b)|'
    r'([+\-*/%&|^~=<>!:]+)|'
    r'([{}()\[\],.;])',
    multiLine: true,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<TextSpan> spans = [];
    final textContent = text;
    if (textContent.isEmpty) {
      return TextSpan(text: '', style: style);
    }

    int lastMatchEnd = 0;

    for (final match in _syntaxRegex.allMatches(textContent)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: textContent.substring(lastMatchEnd, match.start),
            style: AppTheme.codeStyle(fontSize: fontSize, color: AppTheme.darkTheme.textTheme.bodyLarge?.color ?? Colors.white),
          ),
        );
      }

      final matchText = match.group(0)!;

      if (match.group(1) != null) {
        // Comment
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.comment, fontWeight: FontWeight.w400),
          ),
        );
      } else if (match.group(2) != null) {
        // String
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.string),
          ),
        );
      } else if (match.group(3) != null) {
        // Decorator
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.decorator, fontWeight: FontWeight.w600),
          ),
        );
      } else if (match.group(4) != null) {
        // Number
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.number),
          ),
        );
      } else if (match.group(5) != null) {
        // Function call
        final isBuiltin = _builtins.contains(matchText);
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(
              fontSize: fontSize,
              color: isBuiltin ? syntaxTheme.builtin : syntaxTheme.function,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      } else if (match.group(6) != null) {
        // Keyword or Builtin or Identifier
        if (_keywords.contains(matchText)) {
          spans.add(
            TextSpan(
              text: matchText,
              style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.keyword, fontWeight: FontWeight.w600),
            ),
          );
        } else if (_builtins.contains(matchText)) {
          spans.add(
            TextSpan(
              text: matchText,
              style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.builtin),
            ),
          );
        } else if (matchText == 'self' || matchText == 'cls') {
          spans.add(
            TextSpan(
              text: matchText,
              style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.decorator, fontWeight: FontWeight.w500),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: matchText,
              style: AppTheme.codeStyle(fontSize: fontSize, color: AppTheme.darkTheme.textTheme.bodyLarge?.color ?? Colors.white),
            ),
          );
        }
      } else if (match.group(7) != null) {
        // Operator
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.operator),
          ),
        );
      } else if (match.group(8) != null) {
        // Punctuation
        spans.add(
          TextSpan(
            text: matchText,
            style: AppTheme.codeStyle(fontSize: fontSize, color: syntaxTheme.punctuation),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < textContent.length) {
      spans.add(
        TextSpan(
          text: textContent.substring(lastMatchEnd),
          style: AppTheme.codeStyle(fontSize: fontSize, color: AppTheme.darkTheme.textTheme.bodyLarge?.color ?? Colors.white),
        ),
      );
    }

    return TextSpan(children: spans, style: style);
  }
}
