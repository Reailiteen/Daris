import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/home_controller.dart';
import '../../app_selection/controller/app_selection_controller.dart';

class StartSessionCard extends GetView<HomeController> {
  const StartSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectionController = Get.find<AppSelectionController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.nights_stay_rounded,
              size: 40,
              color: AppColors.accentPurple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Start a Focus Session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Block distracting apps and stay productive',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          
          Obx(() {
            final hasSelection = selectionController.totalSelectedCount.value > 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasSelection ? Icons.check_circle : Icons.error_outline,
                  size: 16,
                  color: hasSelection ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  hasSelection 
                    ? '${selectionController.totalSelectedCount.value} apps selected'
                    : 'Select apps to block first',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            );
          }),
          
          const SizedBox(height: 20),
          
          Obx(() {
            final hasSelection = selectionController.totalSelectedCount.value > 0;
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: hasSelection ? AppColors.primaryGradient : null,
                color: hasSelection ? null : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: hasSelection ? controller.startSession : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                ),
                child: const Text('Start Focus'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
