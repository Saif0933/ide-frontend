import 'package:flutter/material.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'package:frontend/features/chat/controllers/chat_controller.dart';
import 'package:frontend/features/chat/models/message_context.dart';
import '../widgets/chatgpt_sidebar_drawer.dart';
import '../widgets/chatgpt_attachment_popup.dart';
import '../widgets/waveform_icon.dart';
import '../widgets/chat_bubble.dart';

class DeveloperChatScreen extends StatefulWidget {
  final String projectId;
  final String projectName;
  final IdeController? ideController;
  final MessageContext? initialContext;

  const DeveloperChatScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.ideController,
    this.initialContext,
  });

  @override
  State<DeveloperChatScreen> createState() => _DeveloperChatScreenState();
}

class _DeveloperChatScreenState extends State<DeveloperChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _plusButtonKey = GlobalKey();
  late ChatController _chatController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedModel = 'ChatGPT';
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(projectId: widget.projectId);

    if (widget.initialContext != null) {
      _chatController.setPendingContext(widget.initialContext);
    }

    _textController.addListener(() {
      final hasNow = _textController.text.trim().isNotEmpty;
      if (hasNow != _hasText) {
        if (mounted) setState(() => _hasText = hasNow);
      }
    });

    _chatController.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatController.removeListener(_scrollToBottom);
    _chatController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty && _chatController.pendingContext == null) return;
    _chatController.sendMessage(text, model: _selectedModel);
    _textController.clear();
  }

  void _handleAttachmentAction(String action) {
    if (action == 'Thinking') {
      setState(() => _selectedModel = 'ChatGPT (Thinking)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thinking mode enabled'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating),
      );
    } else if (action == 'Create image') {
      _textController.text = 'Create an image of ';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$action option selected'), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chatController,
      builder: (context, _) {
        final messages = _chatController.messages;
        final isConversationEmpty = messages.isEmpty;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          drawer: ChatGptSidebarDrawer(
            onNewChat: () {
              _chatController.clearConversation();
            },
            onSelectChat: (title) {
              _handleSend('Let\'s discuss: $title');
            },
          ),
          // ==========================================
          // 1. TOP APP BAR
          // ==========================================
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleSpacing: 0,
            leading: IconButton(
              icon: const _TwoLinesMenuIcon(size: 22),
              tooltip: 'Open sidebar',
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: PopupMenuButton<String>(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 36),
              onSelected: (model) {
                setState(() => _selectedModel = model);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'ChatGPT 4o',
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF3B82F6)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ChatGPT 4o', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          Text('Great for most everyday tasks', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'ChatGPT 4o-mini',
                  child: Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 18, color: Color(0xFF10B981)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ChatGPT 4o-mini', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          Text('Faster for lightweight tasks', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'ChatGPT o1',
                  child: Row(
                    children: [
                      Icon(Icons.psychology_rounded, size: 18, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ChatGPT o1', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                          Text('Uses advanced reasoning', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedModel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 24, color: Color(0xFF334155)),
                tooltip: 'New conversation',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await _chatController.clearConversation();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Chat reset'), duration: Duration(milliseconds: 900), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ==========================================
                // 2. MAIN CENTER BODY (EMPTY OR MESSAGES)
                // ==========================================
                Expanded(
                  child: isConversationEmpty
                      ? const Center(
                          child: Text(
                            'Ready when you are.',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            return ChatBubble(
                              message: msg,
                              onRegenerate: () {
                                _handleSend('Regenerate response');
                              },
                              onExplainMore: () {
                                _handleSend('Can you explain in more detail?');
                              },
                              onRunCode: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Running code snippet in sandbox...'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                // ==========================================
                // 3. BOTTOM CAPSULE INPUT SECTION
                // ==========================================
                _buildBottomCapsuleInput(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // BOTTOM CAPSULE INPUT CARD
  // ==========================================
  Widget _buildBottomCapsuleInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input Field
            TextField(
              controller: _textController,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: 'Ask anything',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
            const SizedBox(height: 10),

            // Bottom Buttons Row (Plus button on left, Mic, Voice Waveform & Send Button on right)
            Row(
              children: [
                // Plus Button (+)
                InkWell(
                  key: _plusButtonKey,
                  onTap: () {
                    ChatGptAttachmentPopup.show(
                      context: context,
                      plusButtonKey: _plusButtonKey,
                      onActionSelected: _handleAttachmentAction,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // Mic Icon Button
                InkWell(
                  onTap: () {
                    _textController.text = 'Write a Python program for quick sort and explain the code.';
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mic_none_rounded,
                        size: 20,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Voice Waveform Button (when empty)
                if (!_hasText) ...[
                  InkWell(
                    onTap: () {
                      _handleSend('Hello ChatGPT, I am ready to code!');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: WaveformIcon(size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Explicit Message Send Button (Upward Arrow / Send)
                InkWell(
                  onTap: () => _handleSend(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _hasText ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      boxShadow: _hasText
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 21,
                        color: _hasText ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Two horizontal lines menu icon painter matching ChatGPT
class _TwoLinesMenuIcon extends StatelessWidget {
  final double size;

  const _TwoLinesMenuIcon({this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TwoLinesPainter(),
      ),
    );
  }
}

class _TwoLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Line 1 (Top)
    canvas.drawLine(Offset(w * 0.15, h * 0.38), Offset(w * 0.85, h * 0.38), paint);

    // Line 2 (Bottom)
    canvas.drawLine(Offset(w * 0.15, h * 0.62), Offset(w * 0.85, h * 0.62), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
