import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class EmailVerificationView extends GetView<AuthController> {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Arguments are set when navigating programmatically; fall back to the
    // current user's email when this is the initialRoute on app start.
    final email = (Get.arguments as Map?)?['email'] as String?
        ?? controller.currentUserEmail;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient(isDark)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                const Spacer(),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 72,
                    color: AppColors.accentBlue,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Verify your email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'We sent a verification link to',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                if (email.isNotEmpty)
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.accentPurple,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 16),

                Text(
                  'Click the link in the email, then come back and tap the button below.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                Obx(() => controller.errorMessage.value != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(color: AppColors.accentRed),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),

                Obx(() => AuthGradientButton(
                      label: controller.isLoading.value
                          ? null
                          : 'I\'ve verified my email',
                      onTap: controller.isLoading.value
                          ? null
                          : controller.checkEmailVerified,
                    )),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => controller.resendVerificationEmail(email),
                  child: Text(
                    'Resend verification email',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => Get.offAllNamed('/landing'),
                  child: const Text(
                    'Wrong email? Go back',
                    style: TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
