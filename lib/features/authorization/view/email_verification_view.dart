import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class EmailVerificationView extends GetView<AuthController> {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments are set when navigating programmatically; fall back to the
    // current user's email when this is the initialRoute on app start.
    final email = (Get.arguments as Map?)?['email'] as String?
        ?? controller.currentUserEmail;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Check your inbox',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle with email
              Text(
                email.isNotEmpty
                    ? 'We sent a verification link to\n$email'
                    : 'We sent a verification link to your email.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondaryDark,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Step hints card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: const [
                    _StepHint(
                      number: '1',
                      text: 'Open the email we sent you',
                    ),
                    SizedBox(height: 16),
                    _StepHint(
                      number: '2',
                      text: 'Tap the verification link inside',
                    ),
                    SizedBox(height: 16),
                    _StepHint(
                      number: '3',
                      text: 'Come back here and tap the button below',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Error message
              Obx(() => controller.errorMessage.value != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        controller.errorMessage.value!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink()),

              // Verified CTA
              Obx(() => AuthGradientButton(
                    label: controller.isLoading.value
                        ? null
                        : "I've verified my email",
                    onTap: controller.isLoading.value
                        ? null
                        : controller.checkEmailVerified,
                  )),

              const SizedBox(height: 16),

              // Resend button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => controller.resendVerificationEmail(email),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.40),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Resend verification email',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Open mail / go back
              TextButton(
                onPressed: () => Get.offAllNamed('/landing'),
                child: const Text(
                  'Wrong email? Go back',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step hint row
// ---------------------------------------------------------------------------

class _StepHint extends StatelessWidget {
  const _StepHint({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
