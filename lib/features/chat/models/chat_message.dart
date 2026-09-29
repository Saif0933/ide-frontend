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
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      projectId: json['projectId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? 'User',
      senderType: MessageSenderType.values.firstWhere(
        (e) => e.name == json['senderType'],
        orElse: () => MessageSenderType.user,
      ),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: MessageDeliveryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageDeliveryStatus.delivered,
      ),
      contextAttachment: json['contextAttachment'] != null
          ? MessageContext.fromJson(json['contextAttachment'] as Map<String, dynamic>)
          : null,
    );
  }
}
