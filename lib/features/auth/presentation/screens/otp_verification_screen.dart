import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/shared/widgets/custom_button.dart';
import 'package:frontend/shared/widgets/glass_container.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:frontend/features/dashboard/presentation/screens/main_navigation_shell.dart';

class OtpVerificationScreen extends StatefulWidget {
  final AuthController authController;
  final String contact;

  const OtpVerificationScreen({
    super.key,
    required this.authController,
    required this.contact,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Pre-fill demo OTP 123456
    const demo = '123456';
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = demo[i];
    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerify() async {
    final otp = _getOtpCode();
    if (otp.length != 6) return;

    final success = await widget.authController.verifyOtp(otp);
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (ctx) => MainNavigationShell(authController: widget.authController),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopOrTablet = !Responsive.isMobile(context);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.enterOtpTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${AppStrings.enterOtpSubtitle} ${widget.contact}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),

        // 6-digit OTP Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  if (_getOtpCode().length == 6) {
                    _handleVerify();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

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
              label: AppStrings.verifyAndContinue,
              isGradient: true,
              isLoading: widget.authController.isLoading,
              width: double.infinity,
              onPressed: _handleVerify,
            );
          },
        ),
        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: () {
              widget.authController.requestOtp(widget.contact);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Access code re-sent!')),
              );
            },
            child: const Text(
              'Did not receive code? Resend Code',
              style: TextStyle(fontSize: 12.5, color: AppColors.primaryLight),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: isDesktopOrTablet
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: content,
                    ),
                  )
                : content,
          ),
        ),
      ),
    );
  }
}
