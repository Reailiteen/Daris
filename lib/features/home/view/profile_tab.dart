import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../balance/controller/balance_controller.dart';
import '../../settings/controller/settings_controller.dart';
import '../../settings/view/settings_view.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.flat(isDark)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile header ────────────────────────────
              _ProfileHeader(isDark: isDark),
              const SizedBox(height: 24),

              // ── Balance summary ───────────────────────────
              _BalanceSummaryCard(isDark: isDark),
              const SizedBox(height: 24),

              // ── Weekly activity ───────────────────────────
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _ChartCard(isDark: isDark),
              const SizedBox(height: 24),

              // ── Streak & stats ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Current Streak',
                      value: '0 days',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.reward,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Avg. Daily',
                      value: '0 min',
                      icon: Icons.timer_rounded,
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Recent sessions placeholder ───────────────
              Text(
                'Recent Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: DarisDecorations.card(isDark),
                child: Center(
                  child: Text('No sessions recorded yet',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 14)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Profile header — avatar, name, email, gear
// ─────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final name = settings.displayName.value;
      final mail = settings.email.value;
      final initials = _initials(name, mail);

      return Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Welcome!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87),
                ),
                if (mail.isNotEmpty)
                  Text(
                    mail,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black45),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Gear → settings
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const _SettingsPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_rounded,
                color: isDark ? Colors.white60 : Colors.black54,
                size: 22,
              ),
            ),
          ),
        ],
      );
    });
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
}

// ─────────────────────────────────────────────
// Settings page — pushed from gear icon
// ─────────────────────────────────────────────

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration:
            BoxDecoration(color: AppColors.flat(isDark)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title row
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Settings content
              const Expanded(child: SettingsView()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Balance summary card
// ─────────────────────────────────────────────

class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final balance = Get.find<BalanceController>();

    return Obx(() {
      final earned = balance.earnedMinutesThisWeek.value;
      final progress = (earned / 300).clamp(0.0, 1.0);
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: DarisDecorations.card(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.phone_android_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balance.isUnlimited
                        ? 'Unlimited!'
                        : balance.formattedBalance,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    balance.isUnlimited
                        ? 'Weekly milestone reached 🎉'
                        : '$earned / 300 min this week',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black45),
                  ),
                  if (!balance.isUnlimited) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.06),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.success),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────
// Weekly activity bar chart
// ─────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: DarisDecorations.card(isDark),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 60,
          barGroups: [
            _bar(0, 15, AppColors.success),
            _bar(1, 30, AppColors.success),
            _bar(2, 45, AppColors.success),
            _bar(3, 20, AppColors.success),
            _bar(4, 55, AppColors.success),
            _bar(5, 30, AppColors.success),
            _bar(6, 10, AppColors.success),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Text(days[v.toInt()],
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 14,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 60,
            color: Colors.grey.withOpacity(0.08),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Info card (streak / avg daily)
// ─────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DarisDecorations.card(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87)),
          Text(title,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black45,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
