import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'feature_preview_page.dart';

class ComingSoonTab extends StatefulWidget {
  const ComingSoonTab({super.key});

  @override
  State<ComingSoonTab> createState() => _ComingSoonTabState();
}

class _ComingSoonTabState extends State<ComingSoonTab>
    with TickerProviderStateMixin {
  late final List<AnimationController> _floatCtrl;
  late final List<Animation<double>> _floatAnim;

  static const _features = [
    _Feature(
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFFFB300),
      title: 'Leaderboards',
      subtitle: 'See who studies the hardest in your school',
    ),
    _Feature(
      icon: Icons.groups_rounded,
      color: Color(0xFF1E88E5),
      title: 'Group Studies',
      subtitle: 'Study alongside classmates in real time',
    ),
    _Feature(
      icon: Icons.psychology_rounded,
      color: Color(0xFF8E24AA),
      title: 'AI Tutor',
      subtitle: 'Get instant help from your personal AI',
    ),
    _Feature(
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFE53935),
      title: 'Study Streaks',
      subtitle: 'Build daily habits and track your momentum',
    ),
    _Feature(
      icon: Icons.bolt_rounded,
      color: Color(0xFF00897B),
      title: 'Challenge Mode',
      subtitle: 'Timed quiz battles against your friends',
    ),
  ];

  // Each card floats at a slightly different frequency/phase
  static final _phases = [0.0, 0.6, 1.2, 0.3, 0.9];
  static final _periods = [2800, 3200, 2600, 3400, 3000];

  @override
  void initState() {
    super.initState();
    _floatCtrl = List.generate(_features.length, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _periods[i]),
      )..repeat(reverse: true);
    });
    _floatAnim = List.generate(_features.length, (i) {
      return CurvedAnimation(parent: _floatCtrl[i], curve: Curves.easeInOut);
    });
    // Stagger start positions via phase offset hack: jump to start
    for (var i = 0; i < _floatCtrl.length; i++) {
      _floatCtrl[i].value = _phases[i] / (2 * pi);
    }
  }

  @override
  void dispose() {
    for (final c in _floatCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      color: bg,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Coming soon" pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      "What's next\nfor Daris",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'We\'re building powerful tools to help you\nstudy smarter with your community.',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Floating feature cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  return AnimatedBuilder(
                    animation: _floatAnim[i],
                    builder: (_, child) {
                      final offset = -6.0 + _floatAnim[i].value * 12.0;
                      return Transform.translate(
                        offset: Offset(0, offset),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () => Navigator.of(
                        context,
                      ).push(featurePreviewRoute(kFeatures[i])),
                      child: _FeatureCard(
                        feature: _features[i],
                        cardBg: cardBg,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isDark: isDark,
                      ),
                    ),
                  );
                }, childCount: _features.length),
              ),
            ),

            // Bottom spacer
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  final _Feature feature;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: feature.color.withValues(alpha: isDark ? 0.18 : 0.1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: feature.color.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(feature.icon, color: feature.color, size: 27),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Soon',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: feature.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}
