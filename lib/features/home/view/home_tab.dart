import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/home_controller.dart';
import '../widgets/active_session_card.dart';
import '../widgets/start_session_card.dart';
import '../widgets/today_stats_summary.dart';
import '../../authorization/controller/authorization_controller.dart';
import '../../statistics/controller/statistics_controller.dart';
import '../../balance/controller/balance_controller.dart';
import '../../tasks/controller/tasks_controller.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.flat(isDark),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 20),

              if (AuthorizationController.isAuthorizationSkipped) ...[
                _buildAuthorizationBanner(isDark),
                const SizedBox(height: 16),
              ],

              Obx(() => controller.isSessionActive.value
                  ? const ActiveSessionCard()
                  : const StartSessionCard()),
              const SizedBox(height: 20),

              const _QuickStatsRow(),
              const SizedBox(height: 20),

              const TodayStatsSummary(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening';
    } else {
      greeting = 'Good night';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            Text(
              'Ready to focus?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorizationBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Screen Time Not Authorized',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Focus features disabled. Grant permission in Settings.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              // Navigate to Settings tab — no-op placeholder kept intentional
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: const Text(
                '→ Settings',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _QuickStatsRow
// ---------------------------------------------------------------------------

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Safely locate controllers — they are always registered before HomeTab
    // renders (HomeBinding.dependencies runs first), but guard with
    // Get.isRegistered for defensive correctness.
    final statsCtrl = Get.isRegistered<StatisticsController>()
        ? Get.find<StatisticsController>()
        : null;
    final balanceCtrl = Get.isRegistered<BalanceController>()
        ? Get.find<BalanceController>()
        : null;
    final tasksCtrl = Get.isRegistered<TasksController>()
        ? Get.find<TasksController>()
        : null;

    final valStyle = TextStyle(
      color: isDark ? Colors.white : AppColors.textPrimaryLight,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.reward,
            label: 'Streak',
            valueWidget: statsCtrl != null
                ? Obx(() => Text(
                      '${statsCtrl.dayStreak.value} days',
                      style: valStyle,
                    ))
                : Text('0 days', style: valStyle),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon: Icons.timer_rounded,
            iconColor: AppColors.primary,
            label: 'Balance',
            valueWidget: balanceCtrl != null
                ? Obx(() => Text(
                      balanceCtrl.formattedBalance,
                      style: valStyle,
                    ))
                : Text('0 min', style: valStyle),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            label: 'Today',
            valueWidget: tasksCtrl != null
                ? Obx(() {
                    final today = DateTime.now();
                    final done = tasksCtrl.tasks
                        .where((t) =>
                            t.isCompleted &&
                            t.completedAt != null &&
                            t.completedAt!.year == today.year &&
                            t.completedAt!.month == today.month &&
                            t.completedAt!.day == today.day)
                        .length;
                    return Text('$done done', style: valStyle);
                  })
                : Text('0 done', style: valStyle),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget valueWidget;
  final bool isDark;

  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueWidget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DarisDecorations.card(isDark),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          valueWidget,
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
