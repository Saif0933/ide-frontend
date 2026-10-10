import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_message.dart';
import '../models/message_context.dart';

class SendMessageResponse {
  final ChatMessage userMessage;
  final ChatMessage? aiReply;

  const SendMessageResponse({
    required this.userMessage,
    this.aiReply,
  });
}

class ChatApiService {
  final ApiClient _apiClient;

  ChatApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch conversation messages for a project
  Future<List<ChatMessage>> getConversation(String projectId) async {
    try {
      final response = await _apiClient.get('${ApiConstants.chat}/$projectId');
      if (response is Map<String, dynamic> && response['data'] is List) {
        final list = response['data'] as List<dynamic>;
        return list
            .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to load conversation: $e');
    }
  }

  /// Send message and trigger AI reply
  Future<SendMessageResponse> sendMessage({
    required String projectId,
    required String content,
    MessageContext? context,
    String? model,
  }) async {
    try {
      final body = <String, dynamic>{
        'projectId': projectId,
        'content': content,
      };

      if (context != null) {
        body['context'] = context.toJson();
      }

      if (model != null && model.isNotEmpty) {
        body['model'] = model;
      }

      final response = await _apiClient.post(
        '${ApiConstants.chat}/send',
        body: body,
      );

      if (response is Map<String, dynamic>) {
        final userData = response['data'] as Map<String, dynamic>?;
        final aiData = response['aiReply'] as Map<String, dynamic>?;

        final userMessage = userData != null
            ? ChatMessage.fromJson(userData)
            : ChatMessage(
                id: 'msg_${DateTime.now().millisecondsSinceEpoch}_user',
                conversationId: projectId,
                projectId: projectId,
                senderId: 'usr_001',
                senderName: 'You',
                senderType: MessageSenderType.user,
                content: content,
                createdAt: DateTime.now(),
                status: MessageDeliveryStatus.delivered,
                contextAttachment: context,
              );

        final aiReply = aiData != null ? ChatMessage.fromJson(aiData) : null;

        return SendMessageResponse(
          userMessage: userMessage,
          aiReply: aiReply,
        );
      }

      throw AppException('Unexpected response from chat service');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to send chat message: $e');
    }
  }

  /// Clear conversation history for a project
  Future<bool> clearConversation(String projectId) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.chat}/$projectId/clear');
      if (response is Map<String, dynamic>) {
        return response['success'] == true;
      }
      return true;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to clear conversation: $e');
    }
  }
}
