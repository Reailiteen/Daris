import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../controller/screen_time_health_controller.dart';

class ScreenTimeHealthView extends StatelessWidget {
  const ScreenTimeHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScreenTimeHealthController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Screen Time health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: controller.refreshHealth,
          ),
        ],
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshHealth,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _HealthHero(
                healthy: controller.isHealthy,
                label: controller.healthLabel,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your selected apps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'iOS keeps individual app names private. Daris can show the health of your protected selection, not app identities.',
              ),
              const SizedBox(height: 14),
              _StatusCard(
                icon: Icons.verified_user_rounded,
                color: controller.isAuthorized.value
                    ? AppColors.success
                    : AppColors.warning,
                title: 'Screen Time permission',
                value: controller.isAuthorized.value
                    ? 'Authorized'
                    : 'Not authorized',
                detail: controller.isAuthorized.value
                    ? 'Daris can protect your selected apps.'
                    : 'Allow Screen Time to use app protection.',
              ),
              _StatusCard(
                icon: Icons.apps_rounded,
                color: controller.selectedApps.value > 0
                    ? AppColors.success
                    : AppColors.warning,
                title: 'Selected apps',
                value: '${controller.selectedApps.value} protected',
                detail: controller.selectedApps.value > 0
                    ? 'Your selection is ready for an earned unlock.'
                    : 'Choose apps or categories to protect.',
              ),
              _StatusCard(
                icon: controller.unlockActive.value
                    ? Icons.lock_open_rounded
                    : Icons.lock_outline_rounded,
                color: controller.unlockActive.value
                    ? AppColors.primary
                    : AppColors.textSecondary,
                title: 'Current unlock',
                value: controller.unlockActive.value
                    ? '${controller.remainingMinutes.value} min remaining'
                    : 'No unlock active',
                detail: controller.unlockActive.value
                    ? 'Your selected apps are temporarily available.'
                    : 'Earn minutes, then explicitly spend them to unlock.',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Get.find<AppSelectionController>().openPicker();
                    await controller.refreshHealth();
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(
                    controller.selectedApps.value == 0
                        ? 'Choose apps & categories'
                        : 'Edit selected apps',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.healthy, required this.label});
  final bool healthy;
  final String label;
  @override
  Widget build(BuildContext context) {
    final color = healthy ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              healthy
                  ? Icons.favorite_rounded
                  : Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  healthy
                      ? 'Your Screen Time setup is ready.'
                      : 'Finish setup to protect your apps.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.detail,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String detail;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
