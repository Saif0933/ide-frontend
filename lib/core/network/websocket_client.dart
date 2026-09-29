import 'dart:async';

class WebSocketEvent {
  final String event;
  final Map<String, dynamic> data;

  const WebSocketEvent({required this.event, required this.data});
}

class WebSocketClient {
  static final WebSocketClient _instance = WebSocketClient._internal();
  factory WebSocketClient() => _instance;
  WebSocketClient._internal();

  final _eventController = StreamController<WebSocketEvent>.broadcast();
  bool _isConnected = false;

  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  bool get isConnected => _isConnected;

  void connect(String url) {
    _isConnected = true;
  }

  void emit(String event, Map<String, dynamic> data) {
    _eventController.add(WebSocketEvent(event: event, data: data));
  }

  void disconnect() {
    _isConnected = false;
  }

  void dispose() {
    _eventController.close();
  }
}
