import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// FeatureInfo — exported so coming_soon_tab.dart can import and pass it
// ---------------------------------------------------------------------------
class FeatureInfo {
  const FeatureInfo({
    required this.index,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.color,
  });

  final int index;
  final String name;
  final String tagline;
  final IconData icon;
  final Color color;

  /// Slightly darker shade used as the gradient end color.
  Color get colorDark {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }
}

// ---------------------------------------------------------------------------
// Feature catalogue
// ---------------------------------------------------------------------------
const List<FeatureInfo> kFeatures = [
  FeatureInfo(
    index: 0,
    name: 'Leaderboards',
    tagline: 'Rise to the top and claim your glory',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFB300),
  ),
  FeatureInfo(
    index: 1,
    name: 'Group Studies',
    tagline: 'Learn together, grow together',
    icon: Icons.groups_rounded,
    color: Color(0xFF1E88E5),
  ),
  FeatureInfo(
    index: 2,
    name: 'AI Tutor',
    tagline: 'Your personal AI study companion',
    icon: Icons.psychology_rounded,
    color: Color(0xFF8E24AA),
  ),
  FeatureInfo(
    index: 3,
    name: 'Study Streaks',
    tagline: 'Build habits that last a lifetime',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFE53935),
  ),
  FeatureInfo(
    index: 4,
    name: 'Challenge Mode',
    tagline: 'Compete, conquer, and earn rewards',
    icon: Icons.bolt_rounded,
    color: Color(0xFF00897B),
  ),
];

// ---------------------------------------------------------------------------
// Route builder — slide-up + fade transition
// ---------------------------------------------------------------------------
Route<void> featurePreviewRoute(FeatureInfo feature) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        FeaturePreviewPage(feature: feature),
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// FeaturePreviewPage
// ---------------------------------------------------------------------------
class FeaturePreviewPage extends StatefulWidget {
  const FeaturePreviewPage({super.key, required this.feature});

  final FeatureInfo feature;

  @override
  State<FeaturePreviewPage> createState() => _FeaturePreviewPageState();
}

class _FeaturePreviewPageState extends State<FeaturePreviewPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  // Used for the pulsing dot animation in Study Streaks slide 2
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _pageController.addListener(_onPageChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final feature = widget.feature;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(feature),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildCarousel(feature, isDark),
                const SizedBox(height: 16),
                _buildPageIndicator(feature.color),
                const Spacer(),
                _buildNotifyButton(feature),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // Header
  // ------------------------------------------------------------------
  Widget _buildHeader(FeatureInfo feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [feature.color, feature.colorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            children: [
              // Back button row
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Icon circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature.icon,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              // Feature name
              Text(
                feature.name,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              // Tagline
              Text(
                feature.tagline,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.70),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Carousel
  // ------------------------------------------------------------------
  Widget _buildCarousel(FeatureInfo feature, bool isDark) {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        itemBuilder: (context, index) {
          final isActive = index == _currentPage;
          return AnimatedScale(
            scale: isActive ? 1.0 : 0.94,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: feature.color.withValues(alpha: isActive ? 0.14 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildSlide(feature, index, isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------
  // Slide dispatcher
  // ------------------------------------------------------------------
  Widget _buildSlide(FeatureInfo feature, int slideIndex, bool isDark) {
    switch (feature.index) {
      case 0:
        return _LeaderboardSlide(slideIndex: slideIndex, color: feature.color, isDark: isDark);
      case 1:
        return _GroupStudiesSlide(slideIndex: slideIndex, color: feature.color, isDark: isDark);
      case 2:
        return _AITutorSlide(slideIndex: slideIndex, color: feature.color, isDark: isDark);
      case 3:
        return _StudyStreaksSlide(
          slideIndex: slideIndex,
          color: feature.color,
          isDark: isDark,
          pulseAnimation: _pulseAnimation,
        );
      case 4:
        return _ChallengeModeSlide(slideIndex: slideIndex, color: feature.color, isDark: isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ------------------------------------------------------------------
  // Page indicator
  // ------------------------------------------------------------------
  Widget _buildPageIndicator(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          width: isActive ? 22 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ------------------------------------------------------------------
  // Notify button
  // ------------------------------------------------------------------
  Widget _buildNotifyButton(FeatureInfo feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [feature.color, feature.colorDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: feature.color.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("You'll be notified when ${feature.name} launches!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.notifications_outlined, size: 20),
            label: const Text(
              "Notify me when it's ready",
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 54),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// LEADERBOARDS SLIDES
// ===========================================================================
class _LeaderboardSlide extends StatelessWidget {
  const _LeaderboardSlide({
    required this.slideIndex,
    required this.color,
    required this.isDark,
  });
  final int slideIndex;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return switch (slideIndex) {
      0 => _LeaderboardPodium(color: color, isDark: isDark),
      1 => _LeaderboardBarChart(color: color, isDark: isDark),
      _ => _LeaderboardYourRank(color: color, isDark: isDark),
    };
  }
}

class _LeaderboardPodium extends StatelessWidget {
  const _LeaderboardPodium({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final podium = [
      {'emoji': '🥇', 'name': 'Sara K.', 'hours': '48h', 'color': const Color(0xFFFFD700)},
      {'emoji': '🥈', 'name': 'Ali M.', 'hours': '42h', 'color': const Color(0xFFC0C0C0)},
      {'emoji': '🥉', 'name': 'Noor R.', 'hours': '38h', 'color': const Color(0xFFCD7F32)},
    ];
    final others = [
      {'rank': '4', 'name': 'Faisal H.', 'hours': '31h'},
      {'rank': '5', 'name': 'Layla T.', 'hours': '27h'},
      {'rank': '6', 'name': 'Omar S.', 'hours': '22h'},
    ];

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leaderboard', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('This Month', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 18),
          // Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PodiumEntry(data: podium[1], height: 72, isDark: isDark),
              _PodiumEntry(data: podium[0], height: 96, isDark: isDark),
              _PodiumEntry(data: podium[2], height: 56, isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: isDark ? AppColors.dividerDark : AppColors.divider, height: 1),
          const SizedBox(height: 12),
          ...others.map((o) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(o['rank']!, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                    ),
                    const SizedBox(width: 10),
                    _MockAvatar(name: o['name']!, size: 28, color: color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(o['name']!, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: textPrimary))),
                    Text(o['hours']!, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PodiumEntry extends StatelessWidget {
  const _PodiumEntry({required this.data, required this.height, required this.isDark});
  final Map<String, Object> data;
  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final podiumColor = data['color'] as Color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(data['emoji'] as String, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        _MockAvatar(name: data['name'] as String, size: 36, color: podiumColor),
        const SizedBox(height: 4),
        Text(data['name'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: textPrimary)),
        const SizedBox(height: 2),
        Text(data['hours'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: podiumColor)),
        const SizedBox(height: 6),
        Container(
          width: 56,
          height: height,
          decoration: BoxDecoration(
            color: podiumColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: podiumColor.withValues(alpha: 0.4), width: 1.5),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardBarChart extends StatelessWidget {
  const _LeaderboardBarChart({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final heights = [0.55, 0.72, 0.48, 1.0, 0.63];
    const myIndex = 3; // Thursday is highlighted

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('Study hours per day', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final isMe = i == myIndex;
                final barH = heights[i] * 130;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isMe)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('You', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    if (isMe) const SizedBox(height: 4),
                    Container(
                      width: 36,
                      height: barH,
                      decoration: BoxDecoration(
                        color: isMe ? color : color.withValues(alpha: 0.28),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(days[i], style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: isMe ? color : textSecondary, fontWeight: isMe ? FontWeight.w700 : FontWeight.w400)),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: color, size: 16),
                const SizedBox(width: 8),
                Text('Your best day: Thursday (6.2h)', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: color, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardYourRank extends StatelessWidget {
  const _LeaderboardYourRank({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('Your Rank', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, color: textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 0.88,
                    strokeWidth: 10,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('#12', style: TextStyle(fontFamily: 'Outfit', fontSize: 36, fontWeight: FontWeight.w800, color: textPrimary)),
                    Text('out of 248', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Top 5%  🏆', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatPill(label: 'Study hrs', value: '42h', color: color, isDark: isDark),
              const SizedBox(width: 12),
              _StatPill(label: 'Sessions', value: '28', color: color, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// GROUP STUDIES SLIDES
// ===========================================================================
class _GroupStudiesSlide extends StatelessWidget {
  const _GroupStudiesSlide({required this.slideIndex, required this.color, required this.isDark});
  final int slideIndex;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return switch (slideIndex) {
      0 => _GroupRoomList(color: color, isDark: isDark),
      1 => _GroupActiveRoom(color: color, isDark: isDark),
      _ => _GroupScoreboard(color: color, isDark: isDark),
    };
  }
}

class _GroupRoomList extends StatelessWidget {
  const _GroupRoomList({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    final rooms = [
      {'name': 'CS 201 Finals 🔥', 'members': 3, 'max': 5, 'topic': 'Data Structures'},
      {'name': 'Math Analysis 📐', 'members': 2, 'max': 4, 'topic': 'Calculus II'},
      {'name': 'Physics Lab Prep ⚗️', 'members': 4, 'max': 6, 'topic': 'Electromagnetism'},
      {'name': 'English Writing ✍️', 'members': 1, 'max': 3, 'topic': 'Essay review'},
    ];

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Study Rooms', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('Join a room and study together', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 14),
          ...rooms.map((r) {
            final members = r['members'] as int;
            final max = r['max'] as int;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['name'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                        Text(r['topic'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(max, (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: i < members ? AppColors.success : color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                  const SizedBox(width: 6),
                  Text('$members/$max', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GroupActiveRoom extends StatelessWidget {
  const _GroupActiveRoom({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final avatars = ['Sara', 'Ali', 'Noor', 'Faisal'];
    final colors = [const Color(0xFFFFB300), const Color(0xFF1E88E5), const Color(0xFF8E24AA), const Color(0xFF00897B)];
    final positions = [
      const Offset(-90, -60),
      const Offset(90, -60),
      const Offset(-90, 60),
      const Offset(90, 60),
    ];

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CS 201 Finals', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('LIVE', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Pomodoro session in progress', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Timer circle
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 0.58,
                        strokeWidth: 8,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeCap: StrokeCap.round,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('35', style: TextStyle(fontFamily: 'Outfit', fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary)),
                          Text('min left', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Avatars around the circle
                ...List.generate(4, (i) => Transform.translate(
                  offset: positions[i],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MockAvatar(name: avatars[i], size: 34, color: colors[i]),
                      const SizedBox(height: 2),
                      Text(avatars[i], style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: textSecondary)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupScoreboard extends StatelessWidget {
  const _GroupScoreboard({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    final rows = [
      {'name': 'Sara K.', 'tasks': '8', 'xp': '+240'},
      {'name': 'Ali M.', 'tasks': '6', 'xp': '+180'},
      {'name': 'You', 'tasks': '5', 'xp': '+150'},
      {'name': 'Noor R.', 'tasks': '3', 'xp': '+90'},
    ];
    final rowColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      color,
      const Color(0xFFCD7F32),
    ];

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Room Scoreboard', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('CS 201 Finals • Session 2', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 14),
          ...List.generate(rows.length, (i) {
            final isMe = rows[i]['name'] == 'You';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? color.withValues(alpha: 0.12) : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: isMe ? Border.all(color: color.withValues(alpha: 0.35), width: 1.5) : null,
              ),
              child: Row(
                children: [
                  Text('${i + 1}', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: rowColors[i])),
                  const SizedBox(width: 10),
                  _MockAvatar(name: rows[i]['name']!, size: 30, color: rowColors[i]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rows[i]['name']!, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: isMe ? FontWeight.w700 : FontWeight.w500, color: textPrimary))),
                  Text('${rows[i]['tasks']} tasks', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(rows[i]['xp']!, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ===========================================================================
// AI TUTOR SLIDES
// ===========================================================================
class _AITutorSlide extends StatelessWidget {
  const _AITutorSlide({required this.slideIndex, required this.color, required this.isDark});
  final int slideIndex;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return switch (slideIndex) {
      0 => _AIChatSlide(color: color, isDark: isDark),
      1 => _AIGenerateQuizSlide(color: color, isDark: isDark),
      _ => _AIConceptCardSlide(color: color, isDark: isDark),
    };
  }
}

class _AIChatSlide extends StatelessWidget {
  const _AIChatSlide({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final aiBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.psychology_rounded, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Tutor', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text('Always ready to help', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // User message 1
          _ChatBubble(text: "Can you explain Big O notation?", isUser: true, color: color),
          const SizedBox(height: 8),
          // AI response 1
          _ChatBubble(text: "Big O notation describes how algorithm complexity grows. O(n) means linear time — if you double input, time doubles.", isUser: false, bgColor: aiBg, textColor: textPrimary),
          const SizedBox(height: 8),
          // User message 2
          _ChatBubble(text: "What's the difference between O(n) and O(n²)?", isUser: true, color: color),
          const SizedBox(height: 8),
          // AI response 2
          _ChatBubble(text: "O(n²) grows quadratically — a nested loop over n items is O(n²). O(n) is much faster at scale! 🚀", isUser: false, bgColor: aiBg, textColor: textPrimary),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser, this.color, this.bgColor, this.textColor});
  final String text;
  final bool isUser;
  final Color? color;
  final Color? bgColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? color : bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 14),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            color: isUser ? Colors.white : textColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _AIGenerateQuizSlide extends StatelessWidget {
  const _AIGenerateQuizSlide({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generate Quiz', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('From your study notes', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.description_outlined, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calculus_Notes.pdf', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
                    Text('From your notes • 14 pages', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuizOptionChip(label: '10 Qs', selected: true, color: color, isDark: isDark),
              const SizedBox(width: 8),
              _QuizOptionChip(label: '20 Qs', selected: false, color: color, isDark: isDark),
              const SizedBox(width: 8),
              _QuizOptionChip(label: '30 Qs', selected: false, color: color, isDark: isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuizOptionChip(label: 'Easy', selected: false, color: color, isDark: isDark),
              const SizedBox(width: 8),
              _QuizOptionChip(label: 'Medium', selected: true, color: color, isDark: isDark),
              const SizedBox(width: 8),
              _QuizOptionChip(label: 'Hard', selected: false, color: color, isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Generate 10 Questions', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _QuizOptionChip extends StatelessWidget {
  const _QuizOptionChip({required this.label, required this.selected, required this.color, required this.isDark});
  final String label;
  final bool selected;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final chipBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.15) : chipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? color.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}

class _AIConceptCardSlide extends StatelessWidget {
  const _AIConceptCardSlide({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Concept Card', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('AI-generated explanation', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(Icons.lightbulb_outline_rounded, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text('Integration by Parts', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text('Calculus II', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                ),
                const SizedBox(height: 6),
                Text(
                  'A technique to integrate products of functions. Uses the formula: ∫u dv = uv − ∫v du, where you choose u to simplify on differentiation.',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Got it ✓', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Show more', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// STUDY STREAKS SLIDES
// ===========================================================================
class _StudyStreaksSlide extends StatelessWidget {
  const _StudyStreaksSlide({
    required this.slideIndex,
    required this.color,
    required this.isDark,
    required this.pulseAnimation,
  });
  final int slideIndex;
  final Color color;
  final bool isDark;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return switch (slideIndex) {
      0 => _StreaksHeatmap(color: color, isDark: isDark),
      1 => _StreaksCounter(color: color, isDark: isDark, pulseAnimation: pulseAnimation),
      _ => _StreaksGoalRings(color: color, isDark: isDark),
    };
  }
}

class _StreaksHeatmap extends StatelessWidget {
  const _StreaksHeatmap({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final emptyColor = isDark ? AppColors.surfaceElevated : const Color(0xFFEEEEEE);

    // 5 weeks × 7 days, 1 = studied, 0 = not, -1 = future
    final grid = [
      [1, 1, 0, 1, 1, 1, 0],
      [1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 0, 1, 1, 0],
      [0, 1, 1, 1, 1, 0, 1],
      [1, 1, 1, -1, -1, -1, -1],
    ];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Study Heatmap', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('Last 5 weeks', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 14),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: days.map((d) => SizedBox(
              width: 30,
              child: Text(d, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary), textAlign: TextAlign.center),
            )).toList(),
          ),
          const SizedBox(height: 6),
          ...grid.map((week) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: week.map((val) {
                Color cellColor;
                if (val == -1) {
                  cellColor = emptyColor.withValues(alpha: 0.4);
                } else if (val == 0) {
                  cellColor = emptyColor;
                } else {
                  cellColor = color.withValues(alpha: 0.85);
                }
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cellColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }).toList(),
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: emptyColor, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 5),
              Text('No study', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
              const SizedBox(width: 14),
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 5),
              Text('Studied', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreaksCounter extends StatelessWidget {
  const _StreaksCounter({required this.color, required this.isDark, required this.pulseAnimation});
  final Color color;
  final bool isDark;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                Text('42', style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text('days in a row', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: textSecondary)),
          const SizedBox(height: 6),
          Text('Personal best: 56 days', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary)),
          const SizedBox(height: 22),
          // 7 day indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (i) {
              final isToday = i == 6;
              final isFilled = i < 6;
              if (isToday) {
                return AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (ctx, _) => Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: pulseAnimation.value),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: const Center(child: Text('T', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                );
              }
              return Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isFilled ? color : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    ['M', 'T', 'W', 'T', 'F', 'S'][i],
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w700, color: isFilled ? Colors.white : color),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: const Text('Keep it up! 1 more day for a new record 🚀', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.success), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _StreaksGoalRings extends StatelessWidget {
  const _StreaksGoalRings({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final goals = [
      {'label': 'Study Time', 'pct': 0.80, 'value': '80%', 'color': color},
      {'label': 'Tasks', 'pct': 0.60, 'value': '60%', 'color': const Color(0xFF1E88E5)},
      {'label': 'Quizzes', 'pct': 1.0, 'value': '100%', 'color': AppColors.success},
    ];

    return Container(
      color: bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Goals', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('April 7 – 13, 2026', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: goals.map((g) {
              final ringColor = g['color'] as Color;
              return Column(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: g['pct'] as double,
                            strokeWidth: 7,
                            backgroundColor: ringColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(g['value'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(g['label'] as String, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevated : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Overall completion', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
                    Text('80%', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.80,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// CHALLENGE MODE SLIDES
// ===========================================================================
class _ChallengeModeSlide extends StatelessWidget {
  const _ChallengeModeSlide({required this.slideIndex, required this.color, required this.isDark});
  final int slideIndex;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return switch (slideIndex) {
      0 => _ChallengeMatchmaking(color: color, isDark: isDark),
      1 => _ChallengeLiveQuiz(color: color, isDark: isDark),
      _ => _ChallengeResults(color: color, isDark: isDark),
    };
  }
}

class _ChallengeMatchmaking extends StatelessWidget {
  const _ChallengeMatchmaking({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text('Challenge Mode', style: TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
          Text('1v1 Quiz Battle', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary)),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  _MockAvatar(name: 'You', size: 56, color: color),
                  const SizedBox(height: 6),
                  Text('You', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text('Rank #12', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: textSecondary)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('VS', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w900, color: color)),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_outline_rounded, color: textSecondary, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text('???', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  Text('Finding...', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                ),
                const SizedBox(width: 10),
                Text('Finding opponent...', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Matching by subject: Data Structures', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: textSecondary)),
        ],
      ),
    );
  }
}

class _ChallengeLiveQuiz extends StatelessWidget {
  const _ChallengeLiveQuiz({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final optBg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    final options = ['O(log n)', 'O(n)', 'O(n log n)', 'O(n²)'];
    const correctIndex = 2;

    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Question 2/10', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600, color: color)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 12, color: AppColors.error),
                    SizedBox(width: 3),
                    Text('0:14', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.2,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What is the time complexity of Merge Sort?',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4),
          ),
          const SizedBox(height: 14),
          ...List.generate(4, (i) {
            final isSelected = i == correctIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.success.withValues(alpha: 0.15) : optBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.success.withValues(alpha: 0.5) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.success : color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + i),
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(options[i], style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.success : textPrimary)),
                  if (isSelected) ...[const Spacer(), const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16)],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChallengeResults extends StatelessWidget {
  const _ChallengeResults({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      color: bg,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('You Won!', style: TextStyle(fontFamily: 'Outfit', fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary)),
          const SizedBox(height: 4),
          Text('Great performance in Data Structures', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScoreColumn(name: 'You', score: '8/10', color: color, isDark: isDark, isWinner: true),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('vs', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: textSecondary)),
              ),
              _ScoreColumn(name: 'Ali M.', score: '5/10', color: const Color(0xFF1E88E5), isDark: isDark, isWinner: false),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.reward.withValues(alpha: 0.9), AppColors.rewardDark.withValues(alpha: 0.9)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('+150 XP', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: const Text('Play Again', style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({required this.name, required this.score, required this.color, required this.isDark, required this.isWinner});
  final String name;
  final String score;
  final Color color;
  final bool isDark;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      children: [
        _MockAvatar(name: name, size: 44, color: color),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
        const SizedBox(height: 2),
        Text(score, style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        if (isWinner)
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
            child: const Text('Winner', style: TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
          )
        else
          Text(textSecondary.toString() == textSecondary.toString() ? '' : '', style: const TextStyle(fontSize: 0)),
      ],
    );
  }
}

// ===========================================================================
// Shared helper widgets
// ===========================================================================

class _MockAvatar extends StatelessWidget {
  const _MockAvatar({required this.name, required this.size, required this.color});
  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value, required this.color, required this.isDark});
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final bg = isDark ? AppColors.surfaceElevated : AppColors.backgroundLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: textSecondary)),
        ],
      ),
    );
  }
}

// Prevent unused import warning for math
// ignore: unused_element
double _unused() => math.pi;
