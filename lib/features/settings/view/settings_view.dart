import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Account ────────────────────────────────────────
          _sectionLabel('Account', isDark),
          Obx(() {
            final name = controller.displayName.value;
            final mail = controller.email.value;
            final initials = _initials(name, mail);
            return Column(
              children: [
                // Profile row
                _Tile(
                  isDark: isDark,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  title: name.isNotEmpty ? name : 'Set your name',
                  subtitle: mail,
                  titleColor: name.isEmpty
                      ? (isDark ? Colors.white38 : Colors.black38)
                      : null,
                  onTap: () => _showEditNameDialog(context, isDark, name),
                ),
                // Sign out
                _Tile(
                  isDark: isDark,
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  color: AppColors.accentRed,
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            );
          }),

          const SizedBox(height: 28),

          // ── General ────────────────────────────────────────
          _sectionLabel('General', isDark),
          _Tile(
            isDark: isDark,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            trailing: Obx(() => Switch.adaptive(
                  value: controller.notificationsEnabled.value,
                  onChanged: (v) => controller.notificationsEnabled.value = v,
                  activeColor: AppColors.accentPurple,
                )),
          ),
          _Tile(
            isDark: isDark,
            icon: Icons.alarm_rounded,
            title: 'Focus Reminders',
            onTap: () {},
          ),

          const SizedBox(height: 28),

          // ── Privacy & Access ────────────────────────────────
          _sectionLabel('Privacy & Access', isDark),
          _Tile(
            isDark: isDark,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _Tile(
            isDark: isDark,
            icon: Icons.no_accounts_outlined,
            title: 'Revoke Screen Time Authorization',
            color: AppColors.accentRed,
            onTap: controller.revokeAuthorization,
          ),

          const SizedBox(height: 28),

          // ── Support ────────────────────────────────────────
          _sectionLabel('Support', isDark),
          _Tile(
            isDark: isDark,
            icon: Icons.star_outline_rounded,
            title: 'Rate App',
            onTap: () {},
          ),
          _Tile(
            isDark: isDark,
            icon: Icons.mail_outline_rounded,
            title: 'Contact Support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isDark ? Colors.white38 : Colors.black38),
      ),
    );
  }

  String _initials(String name, String mail) {
    if (name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.trim()[0].toUpperCase();
    }
    if (mail.isNotEmpty) return mail[0].toUpperCase();
    return '?';
  }

  void _showEditNameDialog(BuildContext context, bool isDark, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2228) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Display Name',
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Your first name',
            hintStyle:
                TextStyle(color: isDark ? Colors.white30 : Colors.black38),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38)),
          ),
          TextButton(
            onPressed: () async {
              await controller.updateDisplayName(ctrl.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2228) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?',
            style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.signOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared tile widget
// ─────────────────────────────────────────────

class _Tile extends StatelessWidget {
  const _Tile({
    required this.isDark,
    required this.title,
    this.icon,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
    this.titleColor,
  });

  final bool isDark;
  final String title;
  final IconData? icon;
  final Widget? leading;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? (isDark ? Colors.white70 : Colors.black87);
    final effectiveTitleColor = titleColor ?? tileColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading ??
            (icon != null ? Icon(icon, color: tileColor, size: 22) : null),
        title: Text(title,
            style: TextStyle(
                color: effectiveTitleColor, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38))
            : null,
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white24 : Colors.black26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
