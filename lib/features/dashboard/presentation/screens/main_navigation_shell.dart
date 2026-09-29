import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/projects/controllers/project_controller.dart';
import 'package:frontend/features/notifications/controllers/notification_controller.dart';
import 'dashboard_screen.dart';
import 'package:frontend/features/projects/presentation/screens/projects_list_screen.dart';
import 'package:frontend/features/chat/presentation/screens/conversations_list_screen.dart';
import 'package:frontend/features/profile/presentation/screens/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final AuthController authController;

  const MainNavigationShell({super.key, required this.authController});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  late ProjectController _projectController;
  late NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _projectController = ProjectController()..fetchProjects();
    _notificationController = NotificationController();
  }

  @override
  void dispose() {
    _projectController.dispose();
    _notificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopOrTablet = !Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      DashboardScreen(
        authController: widget.authController,
        projectController: _projectController,
        notificationController: _notificationController,
        onNavigateToProjects: () => setState(() => _currentIndex = 1),
        onNavigateToChat: () => setState(() => _currentIndex = 2),
      ),
      ProjectsListScreen(projectController: _projectController),
      ConversationsListScreen(projectController: _projectController),
      ProfileScreen(authController: widget.authController),
    ];

    if (isDesktopOrTablet) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        body: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                extended: isDesktop,
                minExtendedWidth: 200,
                selectedIconTheme: const IconThemeData(
                  color: Color(0xFFE53935),
                ),
                unselectedIconTheme: IconThemeData(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF6B7280),
                ),
                selectedLabelTextStyle: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                ),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.newspaper_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 10),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'News',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                ),
                              ),
                              const TextSpan(
                                text: 'Hub',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: Text(AppStrings.navHome),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder_rounded),
                    label: Text(AppStrings.navProjects),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    selectedIcon: Icon(Icons.chat_bubble_rounded),
                    label: Text(AppStrings.navChat),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text(AppStrings.navProfile),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: screens),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFE53935),
          unselectedItemColor: isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF6B7280),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: AppStrings.navProjects,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: AppStrings.navChat,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
