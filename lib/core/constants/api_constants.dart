import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base API URL dynamically determined by platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    }
    try {
      if (Platform.isAndroid) {
        // Android Emulator loopback to host localhost
        return 'http://10.0.2.2:5050/api';
      }
    } catch (_) {}
    return 'http://localhost:5050/api';
  }

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';

  // Projects Endpoints
  static const String projects = '/projects';

  // Executions Endpoints
  static const String executions = '/executions';

  // News Endpoints
  static const String news = '/news';

  // Chat & AI Endpoints
  static const String chat = '/chat';
}
