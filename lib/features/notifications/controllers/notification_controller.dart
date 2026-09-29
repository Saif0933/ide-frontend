import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../../../core/network/mock_backend_service.dart';

class NotificationController extends ChangeNotifier {
  final MockBackendService _backendService = MockBackendService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  NotificationController() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    _notifications = _backendService.notifications;
    _isLoading = false;
    notifyListeners();
  }

  void markAsRead(String id) {
    _backendService.markNotificationAsRead(id);
    _notifications = _backendService.notifications;
    notifyListeners();
  }

  void markAllAsRead() {
    _backendService.markAllNotificationsAsRead();
    _notifications = _backendService.notifications;
    notifyListeners();
  }
}
