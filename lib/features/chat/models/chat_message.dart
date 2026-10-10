import 'message_context.dart';

enum MessageSenderType {
  user,
  developer,
  system,
}

enum MessageDeliveryStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String projectId;
  final String senderId;
  final String senderName;
  final MessageSenderType senderType;
  final String content;
  final DateTime createdAt;
  final MessageDeliveryStatus status;
  final MessageContext? contextAttachment;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.createdAt,
    this.status = MessageDeliveryStatus.delivered,
    this.contextAttachment,
  });

  bool get isFromUser => senderType == MessageSenderType.user;

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? projectId,
    String? senderId,
    String? senderName,
    MessageSenderType? senderType,
    String? content,
    DateTime? createdAt,
    MessageDeliveryStatus? status,
    MessageContext? contextAttachment,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      projectId: projectId ?? this.projectId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      contextAttachment: contextAttachment ?? this.contextAttachment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'projectId': projectId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'contextAttachment': contextAttachment?.toJson(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageSenderType parseSenderType(dynamic val) {
      final str = val?.toString().toLowerCase() ?? 'user';
      if (str == 'developer' || str == 'assistant' || str == 'ai' || str == 'bot') {
        return MessageSenderType.developer;
      }
      if (str == 'system') {
        return MessageSenderType.system;
      }
      return MessageSenderType.user;
    }

    MessageDeliveryStatus parseStatus(dynamic val) {
      final str = val?.toString().toLowerCase() ?? 'delivered';
      if (str == 'sending') return MessageDeliveryStatus.sending;
      if (str == 'sent') return MessageDeliveryStatus.sent;
      if (str == 'read') return MessageDeliveryStatus.read;
      if (str == 'failed') return MessageDeliveryStatus.failed;
      return MessageDeliveryStatus.delivered;
    }

    MessageContext? parseContext(dynamic val) {
      if (val == null) return null;
      if (val is Map<String, dynamic>) {
        return MessageContext.fromJson(val);
      }
      return null;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return ChatMessage(
      id: json['id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: json['conversationId']?.toString() ?? json['projectId']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? 'usr_001',
      senderName: json['senderName']?.toString() ?? (parseSenderType(json['senderType']) == MessageSenderType.developer ? 'AI Assistant' : 'You'),
      senderType: parseSenderType(json['senderType']),
      content: json['content']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      status: parseStatus(json['status']),
      contextAttachment: parseContext(json['contextAttachment']),
    );
  }
}
