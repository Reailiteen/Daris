import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/home_controller.dart';
import '../widgets/active_session_card.dart';
import '../widgets/start_session_card.dart';
import '../widgets/today_stats_summary.dart';
import '../../../data/models/focus_session.dart';

class HomeTab extends GetView<HomeController> {
  const HomeTab({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 24),
              Obx(() => controller.isSessionActive.value
                ? const ActiveSessionCard()
                : const StartSessionCard()
              ),
              const SizedBox(height: 24),
              const TodayStatsSummary(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final hour = DateTime.now().hour;
    String greeting = 'Focus Session';
    if (hour >= 5 && hour < 12) greeting = 'Good morning';
    else if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
    else if (hour >= 17 && hour < 21) greeting = 'Good evening';
    else greeting = 'Good night';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          'Ready to focus?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _QuickActionButton(
              icon: Icons.timer_outlined,
              label: '15 min',
              color: AppColors.accentTeal,
              onTap: () {
                controller.selectedDuration.value = SessionDuration.fifteen;
                controller.startSession();
              },
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.timer_outlined,
              label: '30 min',
              color: AppColors.accentBlue,
              onTap: () {
                controller.selectedDuration.value = SessionDuration.thirty;
                controller.startSession();
              },
            ),
            const SizedBox(width: 12),
            _QuickActionButton(
              icon: Icons.timer_outlined,
              label: '1 hour',
              color: AppColors.accentPurple,
              onTap: () {
                controller.selectedDuration.value = SessionDuration.sixty;
                controller.startSession();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
