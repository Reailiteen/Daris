import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/walkthrough_controller.dart';
import '../walkthrough_keys.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../subjects/controller/subjects_controller.dart';
import 'home_tab.dart';
import 'earn_tab.dart';
import 'profile_tab.dart';
import 'coming_soon_tab.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  WalkthroughController get _wt => Get.find<WalkthroughController>();

  void _advance() {
    final step = _wt.currentStep.value;
    _wt.advance();
    if (step == 0) setState(() => _selectedIndex = 1); // go to Earn tab
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final active = _wt.isActive.value;
      final step = _wt.currentStep.value;

      // Compute done by reading the SOURCE observables directly.
      // Obx tracks every .value read here and rebuilds whenever any changes —
      // no timing issues with ever() listeners.
      final bool done;
      if (!active || step >= 2) {
        done = false;
      } else if (step == 0) {
        done = Get.find<AppSelectionController>().totalSelectedCount.value > 0;
      } else {
        done = Get.find<SubjectsController>().subjects.isNotEmpty;
      }

      // Resolve spotlight rect from the key attached to the live widget
      Rect? spot;
      if (active && step < 2) {
        final key = step == 0
            ? WalkthroughKeys.blockRow
            : WalkthroughKeys.addSubjectBtn;
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null && box.attached) {
          spot = (box.localToGlobal(Offset.zero) & box.size).inflate(6);
        }
      }

      return Stack(
        children: [
          // ── App scaffold ───────────────────────────────────────
          Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: const [HomeTab(), EarnTab(), ProfileTab(), ComingSoonTab()],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: active
                  ? (_) {} // locked during walkthrough
                  : (i) => setState(() => _selectedIndex = i),
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.15),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.nights_stay_outlined),
                  selectedIcon:
                      Icon(Icons.nights_stay, color: AppColors.primary),
                  label: 'Focus',
                ),
                NavigationDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school, color: AppColors.primary),
                  label: 'Earn',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon:
                      Icon(Icons.explore_rounded, color: AppColors.primary),
                  label: 'Explore',
                ),
              ],
            ),
          ),

          // ── Walkthrough layer ──────────────────────────────────
          if (active)
            _WalkthroughLayer(
              step: step,
              stepDone: done,
              spotlight: spot,
              isDark: isDark,
              onAdvance: _advance,
              onComplete: _wt.complete,
            ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Walkthrough layer — visual guide, never blocks touches to the main UI
// ─────────────────────────────────────────────────────────────────────────────

class _WalkthroughLayer extends StatelessWidget {
  const _WalkthroughLayer({
    required this.step,
    required this.stepDone,
    required this.spotlight,
    required this.isDark,
    required this.onAdvance,
    required this.onComplete,
  });

  final int step;
  final bool stepDone;
  final Rect? spotlight;
  final bool isDark;
  final VoidCallback onAdvance;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    if (step == 2) {
      return _CompletionScreen(isDark: isDark, onComplete: onComplete);
    }

    return Stack(
      children: [
        // ── Dimmed backdrop (IgnorePointer = taps still reach the real UI)
        Positioned.fill(
          child: IgnorePointer(
            child: spotlight != null
                ? CustomPaint(
                    painter: _DimWithHolePainter(hole: spotlight!),
                  )
                : ColoredBox(
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
          ),
        ),

        // ── Animated pulsing ring over the target (also IgnorePointer)
        if (spotlight != null)
          Positioned.fromRect(
            rect: spotlight!,
            child: const IgnorePointer(child: _PulsingRing()),
          ),

        // ── Callout card (fully interactive — not wrapped in IgnorePointer)
        Positioned(
          left: 20,
          right: 20,
          bottom: 90, // above the bottom nav bar
          child: _CalloutCard(
            step: step,
            stepDone: stepDone,
            isDark: isDark,
            onNext: onAdvance,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dim overlay with a transparent rectangular hole at the spotlight
// ─────────────────────────────────────────────────────────────────────────────

class _DimWithHolePainter extends CustomPainter {
  const _DimWithHolePainter({required this.hole});
  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(hole, const Radius.circular(12)),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DimWithHolePainter old) => old.hole != hole;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated pulsing ring around the spotlight target
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingRing extends StatefulWidget {
  const _PulsingRing();

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(
              alpha: 0.5 + _anim.value * 0.5,
            ),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: 0.15 + _anim.value * 0.25,
              ),
              blurRadius: 14 + _anim.value * 10,
              spreadRadius: 2 + _anim.value * 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Callout card (steps 0 & 1) — matches app theme
// ─────────────────────────────────────────────────────────────────────────────

class _CalloutCard extends StatelessWidget {
  const _CalloutCard({
    required this.step,
    required this.stepDone,
    required this.isDark,
    required this.onNext,
  });

  final int step;
  final bool stepDone;
  final bool isDark;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final (
      IconData icon,
      Color iconColor,
      String waitTitle,
      String waitBody,
      String doneTitle,
      String doneBody,
      String btnLabel,
    ) = step == 0
        ? (
            Icons.apps_rounded,
            AppColors.error,
            'Choose apps to block',
            'Tap the Block row above — pick every app that distracts you from studying. They\'ll be blocked automatically during every focus session.',
            'Apps selected!',
            'Those apps will be blocked during every session. Now let\'s add your first subject.',
            'Next  →',
          )
        : (
            Icons.school_rounded,
            AppColors.primary,
            'Create your first subject',
            'Tap the + Add button above — enter a subject you\'re currently studying. Merit will generate tasks and quizzes to help you earn screen time.',
            'Subject created!',
            'You\'re all set. Here\'s a quick recap of how Merit works before you dive in.',
            'Finish  →',
          );

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header row: step dots + status badge ────────────
            Row(
              children: [
                _StepDot(active: step == 0),
                const SizedBox(width: 6),
                _StepDot(active: step == 1),
                const Spacer(),
                if (stepDone)
                  _StatusChip(
                    label: 'Done',
                    icon: Icons.check_rounded,
                    color: AppColors.success,
                  )
                else
                  _StatusChip(
                    label: 'Step ${step + 1} of 2',
                    color: AppColors.primary,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Icon + title ─────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stepDone ? doneTitle : waitTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: stepDone ? AppColors.success : textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Body text ────────────────────────────────────────
            Text(
              stepDone ? doneBody : waitBody,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            // ── CTA ──────────────────────────────────────────────
            if (stepDone)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onNext,
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          btnLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 15,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap the highlighted element above',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: active ? 22 : 6,
      height: 6,
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : AppColors.divider,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Completion full-screen card
// ─────────────────────────────────────────────────────────────────────────────

class _CompletionScreen extends StatelessWidget {
  const _CompletionScreen({required this.isDark, required this.onComplete});

  final bool isDark;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final divColor = isDark ? AppColors.dividerDark : AppColors.divider;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: AppColors.elevatedShadow,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "You're ready!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Here's how Merit works:",
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                      const SizedBox(height: 24),

                      _LoopTile(
                        icon: Icons.menu_book_rounded,
                        color: AppColors.primary,
                        title: 'Study',
                        subtitle: 'Complete tasks & quizzes in the Earn tab',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      Divider(height: 1, color: divColor),
                      _LoopTile(
                        icon: Icons.timer_rounded,
                        color: AppColors.success,
                        title: 'Earn minutes',
                        subtitle: 'Every completed task pays in screen time',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      Divider(height: 1, color: divColor),
                      _LoopTile(
                        icon: Icons.block_rounded,
                        color: AppColors.error,
                        title: 'Block & focus',
                        subtitle: 'Sessions block the apps you picked earlier',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onComplete,
                              borderRadius: BorderRadius.circular(14),
                              child: const Center(
                                child: Text(
                                  'Start Studying!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoopTile extends StatelessWidget {
  const _LoopTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
