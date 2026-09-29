import 'package:flutter/material.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/main_navigation_shell.dart';
import '../../features/ide/presentation/screens/ide_workspace_screen.dart';
import '../../features/projects/models/project_model.dart';
import '../../features/chat/presentation/screens/developer_chat_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String ide = '/ide';
  static const String chat = '/chat';

  static Route<dynamic> generateRoute(RouteSettings settings, AuthController authController) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen(authController: authController));
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen(authController: authController));
      case main:
        return MaterialPageRoute(builder: (_) => MainNavigationShell(authController: authController));
      case ide:
        final project = settings.arguments as ProjectModel;
        return MaterialPageRoute(builder: (_) => IdeWorkspaceScreen(project: project));
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DeveloperChatScreen(
            projectId: args['projectId'] as String,
            projectName: args['projectName'] as String,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen(authController: authController));
    }
  }
}
