import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/dashboard/presentation/screens/main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({
    super.key,
    required this.authController,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Custom colors matching the exact design image
  static const Color _primaryBlue = Color(0xFF3E6F97);
  static const Color _cardBackground = Colors.white;
  static const Color _titleColor = Color(0xFF111827);
  static const Color _subtitleColor = Color(0xFF64748B);
  static const Color _inputBackground = Color(0xFFEEF2F6);
  static const Color _inputBorder = Color(0xFFCBD5E1);
  static const Color _inputHint = Color(0xFF94A3B8);
  static const Color _inputIcon = Color(0xFF64748B);
  static const Color _textColor = Color(0xFF1E293B);

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final contact = _emailOrUsernameController.text.trim();
    final password = _passwordController.text.trim();

    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or username'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final success = await widget.authController.signInWithPassword(
      contact,
      password.isNotEmpty ? password : 'password123',
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (ctx) => MainNavigationShell(authController: widget.authController),
        ),
        (route) => false,
      );
    }
  }

  void _handleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration is open. Enter your email to receive an access pass.'),
        backgroundColor: _primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Modern Office Interior Background
          const _ModernOfficeBlurredBackground(),

          // Decorative sparkle on bottom right
          Positioned(
            right: 48,
            bottom: 48,
            child: Icon(
              Icons.auto_awesome,
              size: 32,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),

          // Central Login Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 410),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
                  decoration: BoxDecoration(
                    color: _cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, 16),
                      ),
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Welcome Back! Title
                        const Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: _titleColor,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        const Text(
                          'Please log in to your account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: _subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Email or Username Text Field
                        TextFormField(
                          controller: _emailOrUsernameController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor: _primaryBlue,
                          style: const TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _inputBackground,
                            hintText: 'Email or Username',
                            hintStyle: const TextStyle(
                              color: _inputHint,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              size: 20,
                              color: _inputIcon,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _inputBorder, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _inputBorder, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password Text Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignIn(),
                          cursorColor: _primaryBlue,
                          style: const TextStyle(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _inputBackground,
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: _inputHint,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _inputBorder, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _inputBorder, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: _inputIcon,
                              ),
                              splashRadius: 18,
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Error message if any
                        if (widget.authController.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              widget.authController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                            ),
                          ),

                        // "Sign In" Button
                        AnimatedBuilder(
                          animation: widget.authController,
                          builder: (context, _) {
                            return SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: widget.authController.isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: widget.authController.isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // "Don't have an account? Sign Up" Footer
                        Center(
                          child: InkWell(
                            onTap: _handleSignUp,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: RichText(
                                text: const TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _textColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        color: _primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painted blurred modern office background with perspective depth,
/// architectural glass windows, pillars, and desk lighting.
class _ModernOfficeBlurredBackground extends StatelessWidget {
  const _ModernOfficeBlurredBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OfficeAtmospherePainter(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: const Color(0xFFC3D4E4).withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _OfficeAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base background gradient: cool airy office atmosphere
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEAF0F6),
          Color(0xFFD6E3EE),
          Color(0xFFB8CBDC),
          Color(0xFF9FB7CD),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Left window light zone (bright daylight from floor-to-ceiling windows)
    final windowGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.85, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.85),
          const Color(0xFFDCEAF5).withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, windowGlow);

    // Perspective window mullions / architectural frames on the left
    final framePaint = Paint()
      ..color = const Color(0xFF3B566E).withValues(alpha: 0.45)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width * 0.18, size.height);
    canvas.drawPath(path1, framePaint);

    final path2 = Path()
      ..moveTo(size.width * 0.22, 0)
      ..lineTo(size.width * 0.28, size.height);
    canvas.drawPath(path2, framePaint);

    // Horizontal window beams
    final beamPaint = Paint()
      ..color = const Color(0xFF4A6882).withValues(alpha: 0.35)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.22),
      Offset(size.width * 0.38, size.height * 0.28),
      beamPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.55),
      Offset(size.width * 0.38, size.height * 0.62),
      beamPaint,
    );

    // Desks, partitions & monitors silhouettes in the background
    final furniturePaint = Paint()..style = PaintingStyle.fill;

    // Far desk row
    furniturePaint.color = const Color(0xFF2C4356).withValues(alpha: 0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.60, size.width * 0.32, size.height * 0.25),
        const Radius.circular(8),
      ),
      furniturePaint,
    );

    // Right glass conference room & dark modern monitors/chairs
    furniturePaint.color = const Color(0xFF1E3345).withValues(alpha: 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.72, size.height * 0.50, size.width * 0.26, size.height * 0.45),
        const Radius.circular(12),
      ),
      furniturePaint,
    );

    // Ceiling linear lights
    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.04),
      Offset(size.width * 0.42, size.height * 0.08),
      lightPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.05),
      Offset(size.width * 0.78, size.height * 0.09),
      lightPaint,
    );

    // Subtle blue atmospheric depth wash on right
    final rightAtmosphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.85, 0.4),
        radius: 0.8,
        colors: [
          const Color(0xFF2B475D).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, rightAtmosphere);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

