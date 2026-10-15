import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A focused loading scene for question generation. It uses one compositor-only
/// animation rather than multiple spinners, and freezes when reduced motion is
/// requested by the operating system.
class AiQuestionGenerationLoader extends StatefulWidget {
  const AiQuestionGenerationLoader({super.key});

  @override
  State<AiQuestionGenerationLoader> createState() =>
      _AiQuestionGenerationLoaderState();
}

class _AiQuestionGenerationLoaderState extends State<AiQuestionGenerationLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final phase = reduceMotion ? 0.15 : _controller.value;
            final step = (phase * 3).floor().clamp(0, 2);
            const labels = [
              'Reading your course context',
              'Composing five questions',
              'Checking every answer choice',
            ];
            const captions = [
              'Using your course name, textbook, and pasted notes.',
              'Building a focused challenge around the material.',
              'Making the quiz ready for immediate feedback.',
            ];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 238,
                  height: 238,
                  child: CustomPaint(
                    painter: _StudySignalPainter(progress: phase),
                    child: Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: .28),
                              blurRadius:
                                  28 + 10 * math.sin(phase * math.pi * 2),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Text(
                    labels[step],
                    key: ValueKey(step),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  captions[step],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _ProgressDots(active: step, animated: !reduceMotion),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.active, required this.animated});
  final int active;
  final bool animated;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      3,
      (index) => AnimatedContainer(
        duration: animated ? const Duration(milliseconds: 260) : Duration.zero,
        curve: Curves.easeOutCubic,
        width: index == active ? 24 : 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: index == active
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    ),
  );
}

class _StudySignalPainter extends CustomPainter {
  const _StudySignalPainter({required this.progress});
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rings = [50.0, 78.0, 106.0];
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var index = 0; index < rings.length; index++) {
      final radius = rings[index];
      base.color = AppColors.primary.withValues(alpha: .12 + index * .05);
      canvas.drawCircle(center, radius, base);
      final direction = index.isEven ? 1.0 : -1.0;
      final angle = (progress * math.pi * 2 * direction) + index * 1.9;
      final node =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final glow = Paint()
        ..color = AppColors.primary.withValues(alpha: .14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(node, 9, glow);
      canvas.drawCircle(
        node,
        4.5,
        Paint()..color = index == 2 ? AppColors.reward : AppColors.primary,
      );
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary.withValues(alpha: .55);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle - .42,
        .7,
        false,
        arc,
      );
    }
    final pulse = 118 + 7 * math.sin(progress * math.pi * 2);
    canvas.drawCircle(
      center,
      pulse,
      Paint()..color = AppColors.primary.withValues(alpha: .025),
    );
  }

  @override
  bool shouldRepaint(covariant _StudySignalPainter old) =>
      old.progress != progress;
}
