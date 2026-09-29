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

  // Set system UI overlay style for dark developer theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF161B22),
      systemNavigationBarIconBrightness: Brightness.light,
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
      title: 'PyStudio IDE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: SplashScreen(authController: _authController),
    );
  }
}
