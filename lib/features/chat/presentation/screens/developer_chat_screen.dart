import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/features/ide/controllers/ide_controller.dart';
import 'package:frontend/features/chat/controllers/chat_controller.dart';
import 'package:frontend/features/chat/models/message_context.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/context_attachment_sheet.dart';
import '../widgets/context_preview_card.dart';

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
  late ChatController _chatController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(projectId: widget.projectId);

    if (widget.initialContext != null) {
      _chatController.setPendingContext(widget.initialContext);
    }

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

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isEmpty && _chatController.pendingContext == null) return;
    _chatController.sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopOrTablet = !Responsive.isMobile(context);

    return AnimatedBuilder(
      animation: _chatController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accentPurple,
                      child: Text('M', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.statusSuccess,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marcus Vance (Staff Eng)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Project: ${widget.projectName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktopOrTablet ? 900 : double.infinity),
              child: Column(
                children: [
                  // Message List
                  Expanded(
                    child: _chatController.isLoading
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : _chatController.messages.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.forum_outlined, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Start Developer Conversation',
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Ask questions about your code, attach error logs, or discuss architectural decisions.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                itemCount: _chatController.messages.length,
                                itemBuilder: (context, index) {
                                  return ChatBubble(
                                    message: _chatController.messages[index],
                                  );
                                },
                              ),
                  ),

                  // Pending Context Attachment Banner (if any)
                  if (_chatController.pendingContext != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      color: AppColors.surface,
                      child: Row(
                        children: [
                          Expanded(
                            child: ContextPreviewCard(
                              contextAttachment: _chatController.pendingContext!,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            onPressed: _chatController.clearPendingContext,
                          ),
                        ],
                      ),
                    ),

                  // Chat Input Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          if (widget.ideController != null)
                            IconButton(
                              icon: const Icon(Icons.attachment_rounded, size: 20, color: AppColors.accentCyan),
                              tooltip: 'Attach Code / Error Context',
                              onPressed: () {
                                ContextAttachmentSheet.show(
                                  context,
                                  widget.ideController!,
                                  (ctx) => _chatController.setPendingContext(ctx),
                                );
                              },
                            ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Message mentor about code...',
                                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                                filled: true,
                                fillColor: AppColors.surfaceLight,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _handleSend(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: _chatController.isSending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                              onPressed: _chatController.isSending ? null : _handleSend,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
