import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../screen_time/view/screen_time_health_view.dart';
import '../controller/settings_controller.dart';

class DarisSettingsPage extends StatelessWidget {
  const DarisSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const _SettingsHeading(icon: Icons.person_rounded, title: 'Account'),
          Obx(
            () => _SettingsTile(
              icon: Icons.badge_outlined,
              color: AppColors.primary,
              title: settings.displayName.value.isEmpty
                  ? 'Set your display name'
                  : settings.displayName.value,
              subtitle: settings.email.value.isEmpty
                  ? 'Your Daris account'
                  : settings.email.value,
              onTap: () => _editName(context, settings),
            ),
          ),
          const SizedBox(height: 22),
          const _SettingsHeading(
            icon: Icons.shield_rounded,
            title: 'Screen Time',
          ),
          _SettingsTile(
            icon: Icons.health_and_safety_rounded,
            color: AppColors.success,
            title: 'App health',
            subtitle: 'Check setup, selected apps, and unlock status',
            onTap: () => Get.to(() => const ScreenTimeHealthView()),
          ),
          _SettingsTile(
            icon: Icons.apps_rounded,
            color: AppColors.primary,
            title: 'Selected apps',
            subtitle: 'Choose the apps and categories Daris protects',
            onTap: () => Get.find<AppSelectionController>().openPicker(),
          ),
          const SizedBox(height: 22),
          const _SettingsHeading(icon: Icons.tune_rounded, title: 'Experience'),
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            color: AppColors.warning,
            title: 'Study reminders',
            subtitle: 'Get a nudge when it is time to earn',
            trailing: Obx(
              () => Switch.adaptive(
                value: settings.notificationsEnabled.value,
                onChanged: (value) =>
                    settings.notificationsEnabled.value = value,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            title: 'How the wallet works',
            subtitle: 'Earn from tasks and Quick Study; spend explicitly',
            onTap: () => _walletInfo(context),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, SettingsController settings) {
    final field = TextEditingController(text: settings.displayName.value);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: field,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await settings.updateDisplayName(field.text);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _walletInfo(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    builder: (context) => const Padding(
      padding: EdgeInsets.all(24),
      child: Wrap(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primary,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'Your Screen Time Wallet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          Text(
            'Tasks and Quick Study add minutes. Earning never unlocks apps automatically. You choose when to spend your minutes, and the wallet resets each Sunday.',
          ),
          SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class _SettingsHeading extends StatelessWidget {
  const _SettingsHeading({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing:
          trailing ??
          (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
    ),
  );
}
