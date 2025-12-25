import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.backgroundGradient(isDark),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildSection(context, 'General', [
                _SettingsTile(
                  title: 'Notifications',
                  icon: Icons.notifications_none,
                  trailing: Obx(() => Switch.adaptive(
                    value: controller.notificationsEnabled.value,
                    onChanged: (v) => controller.notificationsEnabled.value = v,
                    activeColor: AppColors.accentPurple,
                  )),
                ),
                _SettingsTile(
                  title: 'Focus Reminders',
                  icon: Icons.alarm,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 32),
              _buildSection(context, 'Account & Privacy', [
                _SettingsTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Revoke Authorization',
                  icon: Icons.no_accounts_outlined,
                  color: AppColors.accentRed,
                  onTap: controller.revokeAuthorization,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSection(context, 'Support', [
                _SettingsTile(
                  title: 'Rate App',
                  icon: Icons.star_outline,
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Contact Support',
                  icon: Icons.mail_outline,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsTile({
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? (isDark ? Colors.white70 : Colors.black87)),
        title: Text(
          title,
          style: TextStyle(color: color ?? (isDark ? Colors.white : Colors.black87)),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
