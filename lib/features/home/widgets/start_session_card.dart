import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/home_controller.dart';
import '../../../data/models/focus_session.dart';
import '../../app_selection/controller/app_selection_controller.dart';

class StartSessionCard extends GetView<HomeController> {
  const StartSessionCard({super.key});

  void _showNameDialog() {
    final textController = TextEditingController(text: controller.sessionName.value);
    Get.dialog(
      AlertDialog(
        title: const Text('Session Name'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Deep Work'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) controller.sessionName.value = name;
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      _DurationPickerSheet(controller: controller, isDark: isDark),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      _DifficultyPickerSheet(controller: controller, isDark: isDark),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectionController = Get.find<AppSelectionController>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.nights_stay_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        controller.sessionName.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.selectedDuration.value.displayName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      )),
                ],
              ),
            ),

            // Config rows
            _ConfigRow(
              icon: Icons.edit_outlined,
              label: 'Name',
              onTap: _showNameDialog,
              trailing: Obx(() => _TrailingText(
                    controller.sessionName.value,
                    isDark: isDark,
                  )),
            ),
            _RowDivider(),
            _ConfigRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              onTap: () => _showDurationPicker(context),
              trailing: Obx(() => _TrailingText(
                    controller.selectedDuration.value.displayName,
                    isDark: isDark,
                  )),
            ),
            _RowDivider(),
            _ConfigRow(
              icon: Icons.apps_rounded,
              label: 'Block',
              onTap: selectionController.openPicker,
              trailing: Obx(() {
                final count = selectionController.totalSelectedCount.value;
                return Text(
                  count > 0 ? '$count selected' : 'None selected',
                  style: TextStyle(
                    color: count > 0 ? AppColors.accentPurple : Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ),
            _RowDivider(),
            _ConfigRow(
              icon: Icons.shield_outlined,
              label: 'Breaks',
              onTap: () => _showDifficultyPicker(context),
              trailing: Obx(() => _TrailingText(
                    controller.selectedDifficulty.value.label,
                    isDark: isDark,
                  )),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: controller.startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Start Blocking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailingText extends StatelessWidget {
  final String text;
  final bool isDark;
  const _TrailingText(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white54 : Colors.black45,
        fontSize: 14,
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const _ConfigRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accentPurple),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              trailing,
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 54,
      color: Colors.grey.withOpacity(0.15),
    );
  }
}

// ── Duration picker ───────────────────────────────────────────────────────────

class _DurationPickerSheet extends StatelessWidget {
  final HomeController controller;
  final bool isDark;
  const _DurationPickerSheet(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Session Duration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...SessionDuration.values.map((d) => Obx(() {
                final selected = controller.selectedDuration.value == d;
                return ListTile(
                  title: Text(d.displayName),
                  trailing: selected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.accentPurple)
                      : null,
                  tileColor: selected
                      ? AppColors.accentPurple.withOpacity(0.08)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    controller.selectedDuration.value = d;
                    Get.back();
                  },
                );
              })),
        ],
      ),
    );
  }
}

// ── Difficulty picker ─────────────────────────────────────────────────────────

class _DifficultyPickerSheet extends StatelessWidget {
  final HomeController controller;
  final bool isDark;
  const _DifficultyPickerSheet(
      {required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          const Text(
            'Breaks Allowed?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose how strict your focus session will be',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...SessionDifficulty.values.map((d) => Obx(() {
                final selected = controller.selectedDifficulty.value == d;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedDifficulty.value = d;
                      Get.back();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentPurple.withOpacity(0.1)
                            : isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentPurple
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(d.icon, color: d.color, size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  d.description,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle,
                                color: AppColors.accentPurple, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              })),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
