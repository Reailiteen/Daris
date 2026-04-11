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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero header ───────────────────────────────
              _ProfileHero(isDark: isDark),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats grid ────────────────────────────────
                    _StatsGrid(isDark: isDark),
                    const SizedBox(height: 24),

                    // ── Weekly activity ───────────────────────────
                    Text(
                      'Weekly Activity',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ChartCard(isDark: isDark),
                    const SizedBox(height: 24),

                    // ── Recent sessions ───────────────────────────
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
                        child: Text(
                          'No sessions recorded yet',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero header — gradient banner, avatar, name, email, settings
// ─────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.flat(isDark),
          ],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: settings button
          Row(
            children: [
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const _SettingsPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Avatar + name + email centred
          Center(
            child: Obx(() {
              final name = settings.displayName.value;
              final mail = settings.email.value;
              final initials = _initials(name, mail);
              return Column(
                children: [
                  // 72x72 gradient avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name.isNotEmpty ? name : 'Welcome!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (mail.isNotEmpty)
                    Text(
                      mail,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              );
            }),
          ),
        ],
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
}

// ─────────────────────────────────────────────
// Settings page — pushed from hero gear icon
// ─────────────────────────────────────────────

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.flat(isDark)),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Expanded(child: SettingsView()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2x2 stats grid
// ─────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final balance = Get.find<BalanceController>();

    return Obx(() {
      final balanceValue = balance.isUnlimited
          ? 'Unlimited'
          : balance.formattedBalance;

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.reward,
            label: 'Streak',
            value: '0 days',
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.timer_rounded,
            color: AppColors.primary,
            label: 'Balance',
            value: balanceValue,
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.school_rounded,
            color: AppColors.success,
            label: 'Sessions',
            value: '0',
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.trending_up_rounded,
            color: AppColors.warning,
            label: 'Avg Daily',
            value: '0 min',
            isDark: isDark,
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────
// Individual stat card
// ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DarisDecorations.card(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
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
      height: 216,
      padding: const EdgeInsets.all(16),
      decoration: DarisDecorations.elevatedCard(isDark),
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
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Text(
                    days[v.toInt()],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  );
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
            color: Colors.grey.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}
