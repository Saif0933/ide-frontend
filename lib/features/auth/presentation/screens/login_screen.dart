import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/custom_text_field.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'otp_verification_screen.dart';

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
  final _contactController = TextEditingController(text: 'alex.rivera@dev.io');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (_formKey.currentState?.validate() != true) return;

    final contact = _contactController.text.trim();
    final success = await widget.authController.requestOtp(contact);

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => OtpVerificationScreen(
            authController: widget.authController,
            contact: contact,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopOrTablet = !Responsive.isMobile(context);

    Widget formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.code_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 24),

          const Text(
            AppStrings.loginTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.loginSubtitle,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 28),

          CustomTextField(
            label: AppStrings.enterEmailOrPhone,
            hintText: 'e.g. dev@pystudio.io or +15550001',
            controller: _contactController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: AppColors.textMuted),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email or phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          if (widget.authController.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.authController.errorMessage!,
                style: const TextStyle(fontSize: 12, color: AppColors.accentRed),
              ),
            ),

          AnimatedBuilder(
            animation: widget.authController,
            builder: (context, _) {
              return CustomButton(
                label: AppStrings.sendOtp,
                isGradient: true,
                isLoading: widget.authController.isLoading,
                width: double.infinity,
                onPressed: _handleSendOtp,
              );
            },
          ),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              AppStrings.termsNotice,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: isDesktopOrTablet
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: formContent,
                    ),
                  )
                : formContent,
          ),
        ),
      ),
    );
  }
}
