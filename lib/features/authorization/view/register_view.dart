import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Create your',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Merit Account',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),

            // Divider separator
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 20),
              color: AppColors.border,
            ),

            // Form
            Form(
              key: formKey,
              child: Column(
                children: [
                  AuthField(
                    controller: emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    isDark: true,
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Min 8 chars, 1 uppercase, 1 number',
                    obscureText: true,
                    isDark: true,
                    validator: controller.validatePassword,
                  ),
                  const SizedBox(height: 20),
                  AuthField(
                    controller: confirmController,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    obscureText: true,
                    isDark: true,
                    validator: (v) => controller.validateConfirmPassword(
                        v, passwordController.text),
                  ),
                ],
              ),
            ),

            // Error message
            Obx(() => controller.errorMessage.value != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      controller.errorMessage.value!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink()),

            const SizedBox(height: 32),

            // Create Account CTA
            Obx(() => AuthGradientButton(
                  label: controller.isLoading.value ? null : 'Create Account',
                  onTap: controller.isLoading.value
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            controller.register(
                              emailController.text.trim(),
                              passwordController.text,
                            );
                          }
                        },
                )),

            const SizedBox(height: 20),

            // Bottom navigation link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?  ',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.offNamed('/login'),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
