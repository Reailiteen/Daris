import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class ActiveSessionCard extends GetView<HomeController> {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  // Session label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34C759),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                            controller.sessionName.value,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Circular timer
                  _buildTimer(),

                  const SizedBox(height: 28),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _SessionButton(
                          label: 'Take a Break',
                          icon: Icons.coffee_rounded,
                          onTap: () {
                            // Break functionality — placeholder
                            Get.snackbar(
                              'Break',
                              'Break feature coming soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          outlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SessionButton(
                          label: 'End Session',
                          icon: Icons.stop_rounded,
                          onTap: controller.endSession,
                          outlined: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          SizedBox(
            width: 210,
            height: 210,
            child: Obx(() => CircularProgressIndicator(
                  value: controller.progress.value,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                )),
          ),
          // Inner content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.nights_stay_rounded,
                color: Colors.white54,
                size: 22,
              ),
              const SizedBox(height: 6),
              Obx(() => Text(
                    controller.remainingTimeString.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2,
                    ),
                  )),
              const Text(
                'remaining',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _SessionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.outlined,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
