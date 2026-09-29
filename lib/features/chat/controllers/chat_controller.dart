import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/message_context.dart';
import '../../../core/network/mock_backend_service.dart';
import '../../../core/network/websocket_client.dart';

class ChatController extends ChangeNotifier {
  final MockBackendService _backendService = MockBackendService();
  final String projectId;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  MessageContext? _pendingContext;

  ChatController({required this.projectId}) {
    _loadMessages();
    _listenToEvents();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  MessageContext? get pendingContext => _pendingContext;

  void _listenToEvents() {
    WebSocketClient().eventStream.listen((event) {
      if (event.event == 'chat.message' && event.data['conversationId'] == projectId) {
        final newMsg = ChatMessage.fromJson(event.data['message'] as Map<String, dynamic>);
        if (!_messages.any((m) => m.id == newMsg.id)) {
          _messages.add(newMsg);
          notifyListeners();
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _backendService.getConversation(projectId);
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
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

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty && _pendingContext == null) return;

    _isSending = true;
    final contextToSend = _pendingContext;
    _pendingContext = null;
    notifyListeners();

    try {
      final msg = await _backendService.sendMessage(
        projectId: projectId,
        content: text.trim().isEmpty ? 'Shared project context' : text.trim(),
        context: contextToSend,
      );
      _messages.add(msg);
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
