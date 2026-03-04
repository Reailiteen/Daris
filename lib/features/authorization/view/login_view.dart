import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_widgets.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient(isDark)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white70 : Colors.black54),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      AuthField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 20),
                      AuthField(
                        controller: passwordController,
                        label: 'Password',
                        hint: 'Your password',
                        obscureText: true,
                        isDark: isDark,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Password is required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => controller.errorMessage.value != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(color: AppColors.accentRed),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 32),
                Obx(() => AuthGradientButton(
                      label: controller.isLoading.value ? null : 'Sign In',
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              if (formKey.currentState?.validate() ?? false) {
                                controller.signIn(
                                  emailController.text.trim(),
                                  passwordController.text,
                                );
                              }
                            },
                    )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () => Get.offNamed('/register'),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppColors.accentPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
