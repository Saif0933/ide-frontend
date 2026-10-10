import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/message_context.dart';
import '../services/chat_api_service.dart';
import '../../../core/network/websocket_client.dart';

class ChatController extends ChangeNotifier {
  final ChatApiService _apiService;
  final String projectId;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  MessageContext? _pendingContext;
  StreamSubscription? _wsSubscription;

  ChatController({
    required this.projectId,
    ChatApiService? apiService,
  }) : _apiService = apiService ?? ChatApiService() {
    _loadMessages();
    _listenToEvents();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  MessageContext? get pendingContext => _pendingContext;

  void _listenToEvents() {
    _wsSubscription = WebSocketClient().eventStream.listen((event) {
      if (event.event == 'chat.message' &&
          (event.data['conversationId'] == projectId || event.data['projectId'] == projectId)) {
        final messageData = event.data['message'];
        if (messageData is Map<String, dynamic>) {
          final newMsg = ChatMessage.fromJson(messageData);
          final existingIndex = _messages.indexWhere((m) => m.id == newMsg.id);
          if (existingIndex == -1) {
            _messages.add(newMsg);
            notifyListeners();
          } else {
            _messages[existingIndex] = newMsg;
            notifyListeners();
          }
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _apiService.getConversation(projectId);
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
      _errorMessage = 'Failed to load conversation history';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPendingContext(MessageContext? context) {
    _pendingContext = context;
    notifyListeners();
  }

  void clearPendingContext() {
    _pendingContext = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? model}) async {
    if (text.trim().isEmpty && _pendingContext == null) return;

    final contentText = text.trim().isEmpty ? 'Shared project context' : text.trim();
    final contextToSend = _pendingContext;
    _pendingContext = null;
    _isSending = true;
    _errorMessage = null;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMsg = ChatMessage(
      id: tempId,
      conversationId: projectId,
      projectId: projectId,
      senderId: 'usr_001',
      senderName: 'You',
      senderType: MessageSenderType.user,
      content: contentText,
      createdAt: DateTime.now(),
      status: MessageDeliveryStatus.sending,
      contextAttachment: contextToSend,
    );

    _messages.add(tempMsg);
    notifyListeners();

    try {
      final response = await _apiService.sendMessage(
        projectId: projectId,
        content: contentText,
        context: contextToSend,
        model: model,
      );

      final index = _messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _messages[index] = response.userMessage;
      } else {
        _messages.add(response.userMessage);
      }

      if (response.aiReply != null) {
        final aiExists = _messages.any((m) => m.id == response.aiReply!.id);
        if (!aiExists) {
          _messages.add(response.aiReply!);
        }
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      _errorMessage = 'Could not deliver message to AI engine';
      final index = _messages.indexWhere((m) => m.id == tempId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageDeliveryStatus.failed);
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> clearConversation() async {
    try {
      await _apiService.clearConversation(projectId);
      _messages.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing conversation: $e');
      _messages.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
