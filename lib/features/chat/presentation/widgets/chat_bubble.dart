import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/chat/models/chat_message.dart';
import 'ai_robot_avatar.dart';
import 'context_preview_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRegenerate;
  final VoidCallback? onExplainMore;
  final VoidCallback? onRunCode;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRegenerate,
    this.onExplainMore,
    this.onRunCode,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isFromUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAssistantMessage(context);
    }
  }

  // ==========================================
  // USER MESSAGE BUBBLE (Right Aligned)
  // ==========================================
  Widget _buildUserMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 14, top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  if (message.contextAttachment != null) ...[
                    const SizedBox(height: 6),
                    ContextPreviewCard(contextAttachment: message.contextAttachment!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // User Dark Avatar
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // AI ASSISTANT CARD (Left Aligned)
  // ==========================================
  Widget _buildAssistantMessage(BuildContext context) {
    final parsedContent = _parseAiContent(message.content);

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 24, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cute AI Robot Avatar
          const AiRobotAvatar(size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main White Card Container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Intro Text
                      if (parsedContent.introText.isNotEmpty) ...[
                        Text(
                          parsedContent.introText,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF1E293B),
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Code Block Box (if any)
                      if (parsedContent.codeSnippet != null && parsedContent.codeSnippet!.isNotEmpty) ...[
                        _buildCodeSnippetCard(context, parsedContent.codeSnippet!),
                        const SizedBox(height: 14),
                      ],

                      // Explanation Section (if any)
                      if (parsedContent.explanationSteps.isNotEmpty) ...[
                        _buildExplanationSection(parsedContent.explanationSteps),
                        const SizedBox(height: 8),
                      ],

                      // Timestamp at bottom
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatTime(message.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Action Pills (Copy, Regenerate, Explain More, Run Code)
                _buildActionPillsRow(context, parsedContent.codeSnippet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CODE SNIPPET CARD (Dark Terminal Style)
  // ==========================================
  Widget _buildCodeSnippetCard(BuildContext context, String code) {
    final lines = code.trim().split('\n');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1322),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF141C2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1)),
            ),
            child: Row(
              children: [
                // Python Snakes Logo
                const _PythonSnakesIcon(size: 18),
                const SizedBox(width: 8),
                const Text(
                  'python',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Copy Button
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard!'),
                        duration: Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF334155), width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 12, color: Color(0xFFCBD5E1)),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Lines with Line Numbers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lines.length, (index) {
                final line = lines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line Number
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Syntax Highlighted Code Line
                      Expanded(
                        child: _buildHighlightedLine(line),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SYNTAX HIGHLIGHTED SPANS
  // ==========================================
  Widget _buildHighlightedLine(String line) {
    if (line.trim().startsWith('#')) {
      return Text(
        line,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          color: Color(0xFF10B981), // Green comments
        ),
      );
    }

    final spans = <TextSpan>[];

    for (var match in RegExp(r'(\w+|[(),:\[\]=+*\/<>-]|\s+|"[^"]*"|\d+)').allMatches(line)) {
      final text = match.group(0) ?? '';
      Color color = Colors.white;

      if (text == 'def' || text == 'return' || text == 'if' || text == 'else' || text == 'for' || text == 'in' || text == 'while') {
        color = const Color(0xFFFF6188); // Pink/Magenta keywords
      } else if (text == 'len' || text == 'print' || text == 'range') {
        color = const Color(0xFF78DCE8); // Cyan built-in
      } else if (text == 'quick_sort' || text == 'main') {
        color = const Color(0xFFA9DC76); // Green functions
      } else if (text.startsWith('"') || text.startsWith("'")) {
        color = const Color(0xFFFFD866); // Yellow strings
      } else if (int.tryParse(text) != null) {
        color = const Color(0xFFAB9DF2); // Purple numbers
      } else if (text == 'pivot' || text == 'left' || text == 'right' || text == 'middle' || text == 'arr' || text == 'data') {
        color = const Color(0xFF78DCE8); // Cyan variables
      } else if (text == '<=' || text == '==' || text == '>' || text == '<' || text == '=' || text == '+' || text == '//') {
        color = const Color(0xFFFF6188); // Operator
      }

      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          color: color,
        ),
      ));
    }

    if (spans.isEmpty) {
      return Text(
        line,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: Colors.white),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  // ==========================================
  // EXPLANATION SECTION
  // ==========================================
  Widget _buildExplanationSection(List<_ExplanationStep> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Row(
          children: [
            Icon(Icons.description_rounded, size: 16, color: Color(0xFF3B82F6)),
            SizedBox(width: 6),
            Text(
              'Explanation:',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Steps
        for (int i = 0; i < steps.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blue circular number badge
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Step Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: '${steps[i].title}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            TextSpan(text: steps[i].description),
                          ],
                        ),
                      ),
                      if (steps[i].subPoints.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        for (final pt in steps[i].subPoints)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                Expanded(
                                  child: Text(
                                    pt,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // ACTION PILLS ROW (Below AI Response)
  // ==========================================
  Widget _buildActionPillsRow(BuildContext context, String? code) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPillButton(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied response!'),
                  duration: Duration(milliseconds: 900),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildPillButton(
            icon: Icons.refresh_rounded,
            label: 'Regenerate',
            onTap: onRegenerate,
          ),
          const SizedBox(width: 8),
          _buildPillButton(
            icon: Icons.list_alt_rounded,
            label: 'Explain More',
            onTap: onExplainMore,
          ),
          const SizedBox(width: 8),
          // Green Run Code Pill
          InkWell(
            onTap: onRunCode,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF86EFAC), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_outlined, size: 14, color: Color(0xFF16A34A)),
                  SizedBox(width: 4),
                  Text(
                    'Run Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PARSER HELPERS
  // ==========================================
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  _ParsedAiContent _parseAiContent(String content) {
    if (content.contains('quick_sort') || content.contains('Quick Sort')) {
      return _ParsedAiContent(
        introText: "Sure! Here's a Python program to implement Quick Sort along with a step-by-step explanation.",
        codeSnippet: '''def quick_sort(arr):
    if len(arr) <= 1:
        return arr

    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]

    return quick_sort(left) + middle + quick_sort(right)

# Example usage
data = [64, 34, 25, 12, 22, 11, 90]
print("Sorted:", quick_sort(data))''',
        explanationSteps: [
          _ExplanationStep(
            title: 'Base Case',
            description: 'If the array has 0 or 1 element, it is already sorted.',
          ),
          _ExplanationStep(
            title: 'Pivot',
            description: 'We choose the middle element as pivot.',
          ),
          _ExplanationStep(
            title: 'Partition',
            description: 'Divide the array into three parts:',
            subPoints: [
              'Left -> elements smaller than pivot',
              'Middle -> elements equal to pivot',
              'Right -> elements greater than pivot',
            ],
          ),
          _ExplanationStep(
            title: 'Recursion',
            description: 'Recursively apply quick_sort to left and right subarrays and combine them.',
          ),
        ],
      );
    }

    // Default or dynamically formatted code
    if (content.contains('```')) {
      final parts = content.split('```');
      final intro = parts[0].trim();
      final codeBlock = parts.length > 1 ? parts[1].replaceFirst(RegExp(r'^[a-zA-Z]+\n'), '').trim() : '';
      return _ParsedAiContent(
        introText: intro,
        codeSnippet: codeBlock,
        explanationSteps: [],
      );
    }

    return _ParsedAiContent(
      introText: content,
      codeSnippet: null,
      explanationSteps: [],
    );
  }
}

class _ParsedAiContent {
  final String introText;
  final String? codeSnippet;
  final List<_ExplanationStep> explanationSteps;

  _ParsedAiContent({
    required this.introText,
    this.codeSnippet,
    this.explanationSteps = const [],
  });
}

class _ExplanationStep {
  final String title;
  final String description;
  final List<String> subPoints;

  _ExplanationStep({
    required this.title,
    required this.description,
    this.subPoints = const [],
  });
}

// Vector Icon for Python Snakes
class _PythonSnakesIcon extends StatelessWidget {
  final double size;

  const _PythonSnakesIcon({this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SnakesPainter(),
      ),
    );
  }
}

class _SnakesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bluePaint = Paint()
      ..color = const Color(0xFF387EB8)
      ..style = PaintingStyle.fill;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFE052)
      ..style = PaintingStyle.fill;

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Top Blue Segment
    final bluePath = Path();
    bluePath.moveTo(w * 0.48, h * 0.05);
    bluePath.lineTo(w * 0.28, h * 0.05);
    bluePath.arcToPoint(Offset(w * 0.08, h * 0.25), radius: Radius.circular(w * 0.2));
    bluePath.lineTo(w * 0.08, h * 0.42);
    bluePath.lineTo(w * 0.25, h * 0.42);
    bluePath.lineTo(w * 0.25, h * 0.52);
    bluePath.lineTo(w * 0.52, h * 0.52);
    bluePath.lineTo(w * 0.52, h * 0.32);
    bluePath.lineTo(w * 0.28, h * 0.32);
    bluePath.lineTo(w * 0.28, h * 0.22);
    bluePath.lineTo(w * 0.65, h * 0.22);
    bluePath.arcToPoint(Offset(w * 0.48, h * 0.05), radius: Radius.circular(w * 0.17));
    bluePath.close();
    canvas.drawPath(bluePath, bluePaint);
    canvas.drawCircle(Offset(w * 0.22, h * 0.14), w * 0.045, eyePaint);

    // Bottom Yellow Segment
    final yellowPath = Path();
    yellowPath.moveTo(w * 0.52, h * 0.95);
    yellowPath.lineTo(w * 0.72, h * 0.95);
    yellowPath.arcToPoint(Offset(w * 0.92, h * 0.75), radius: Radius.circular(w * 0.2));
    yellowPath.lineTo(w * 0.92, h * 0.58);
    yellowPath.lineTo(w * 0.75, h * 0.58);
    yellowPath.lineTo(w * 0.75, h * 0.48);
    yellowPath.lineTo(w * 0.48, h * 0.48);
    yellowPath.lineTo(w * 0.48, h * 0.68);
    yellowPath.lineTo(w * 0.72, h * 0.68);
    yellowPath.lineTo(w * 0.72, h * 0.78);
    yellowPath.lineTo(w * 0.35, h * 0.78);
    yellowPath.arcToPoint(Offset(w * 0.52, h * 0.95), radius: Radius.circular(w * 0.17));
    yellowPath.close();
    canvas.drawPath(yellowPath, yellowPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.86), w * 0.045, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
