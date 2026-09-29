import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage cache
  await LocalStorageService().init();

  // Set transparent system overlays for seamless dynamic theme switching
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PyStudioApp());
}

class PyStudioApp extends StatefulWidget {
  const PyStudioApp({super.key});

  @override
  State<PyStudioApp> createState() => _PyStudioAppState();
}

class _PyStudioAppState extends State<PyStudioApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switches between Light and Dark mode based on phone's system settings
      home: SplashScreen(authController: _authController),
    );
  }
}
