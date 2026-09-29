import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/utils/date_formatter.dart';
import 'package:frontend/features/chat/models/chat_message.dart';
import 'context_preview_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;
    final isDeveloper = message.senderType == MessageSenderType.developer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: isDeveloper ? AppColors.accentPurple : (isDark ? AppColors.surfaceBorder : const Color(0xFFE2E8F0)),
              child: Text(
                message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : 'D',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDeveloper ? AppColors.accentPurple : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatChatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFFE53935)
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isUser ? 14 : 2),
                      bottomRight: Radius.circular(isUser ? 2 : 14),
                    ),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFFDC2626)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                      width: 1,
                    ),
                    boxShadow: isUser || isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUser
                              ? Colors.white
                              : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF111827)),
                          height: 1.35,
                        ),
                      ),
                      if (message.contextAttachment != null)
                        ContextPreviewCard(
                          contextAttachment: message.contextAttachment!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
