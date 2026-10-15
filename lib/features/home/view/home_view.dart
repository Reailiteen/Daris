import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../ai_questions/view/quick_study_view.dart';
import '../../app_selection/controller/app_selection_controller.dart';
import '../../balance/controller/balance_controller.dart';
import '../../demo/controller/demo_mode_controller.dart';
import '../../subjects/controller/subjects_controller.dart';
import '../../subjects/view/course_editor_sheet.dart';
import '../../settings/view/daris_settings_page.dart';
import '../../tasks/controller/tasks_controller.dart';
import '../../tasks/view/task_detail_view.dart';
import '../widgets/spend_confirmation_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, this.demo = false});
  final bool demo;
  @override
  Widget build(BuildContext context) =>
      demo ? const _DemoHome() : const _ProductHome();
}

class _ProductHome extends StatelessWidget {
  const _ProductHome();
  @override
  Widget build(BuildContext context) {
    final balance = Get.find<BalanceController>();
    final tasks = Get.find<TasksController>();
    final subjects = Get.find<SubjectsController>();
    final appSelection = Get.find<AppSelectionController>();
    return _HomeScaffold(
      title: 'Learn. Earn. Spend.',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () => Get.to(() => const DarisSettingsPage()),
        ),
        IconButton(
          icon: const Icon(Icons.menu_book_rounded),
          tooltip: 'Add course',
          onPressed: () => showCourseEditor(context),
        ),
        IconButton(
          icon: const Icon(Icons.apps_rounded),
          tooltip: 'Choose selected apps',
          onPressed: () => Get.find<AppSelectionController>().openPicker(),
        ),
      ],
      wallet: Obx(
        () => WalletCard(
          minutes: balance.availableMinutes.value,
          selectedApps: appSelection.totalSelectedCount.value,
        ),
      ),
      earn: Obx(() {
        if (tasks.tasks.isEmpty)
          return const _EmptyCard(
            message: 'No pending tasks yet. Add a course task to earn minutes.',
          );
        return Column(
          children: tasks.tasks.take(3).map((task) {
            final course =
                subjects.subjects
                    .firstWhereOrNull((subject) => subject.id == task.subjectId)
                    ?.name ??
                'Course';
            return _TaskCard(
              task: task,
              course: course,
              onTap: () =>
                  Get.to(() => TaskDetailView(task: task, course: course)),
            );
          }).toList(),
        );
      }),
      quickStudy: Obx(
        () => _ActionCard(
          icon: Icons.psychology_rounded,
          title: 'Quick Study',
          subtitle: subjects.subjects.isEmpty
              ? 'Add a course before starting a challenge.'
              : 'Five questions. Earn 1 min for every correct answer.',
          action: subjects.subjects.isEmpty
              ? null
              : () => Get.to(() => const QuickStudyView()),
        ),
      ),
      spend: _ActionCard(
        icon: Icons.lock_open_rounded,
        title: 'Your selected apps',
        subtitle: 'Unlock 5 min from your wallet after confirmation.',
        action: () => showSpendConfirmation(context: context, demo: false),
      ),
    );
  }
}

class _DemoHome extends StatelessWidget {
  const _DemoHome();
  @override
  Widget build(BuildContext context) {
    final demo = Get.find<DemoModeController>();
    return _HomeScaffold(
      title: 'Daris demo',
      demoBanner: true,
      wallet: Obx(
        () => WalletCard(minutes: demo.availableMinutes.value, selectedApps: 1),
      ),
      earn: Obx(
        () => demo.tasks.isEmpty
            ? const _EmptyCard(
                message: 'Demo task completed. Try Quick Study next.',
              )
            : Column(
                children: demo.tasks
                    .map(
                      (task) => _TaskCard(
                        task: task,
                        course: 'CHEM101',
                        onTap: () => Get.to(
                          () => TaskDetailView(
                            task: task,
                            course: 'CHEM101',
                            demo: true,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
      quickStudy: _ActionCard(
        icon: Icons.psychology_rounded,
        title: 'Quick Study',
        subtitle: 'CHEM101 · 3 local questions · up to 3 min',
        action: () {
          demo.beginQuiz();
          Get.to(() => const QuickStudyView(demo: true));
        },
      ),
      spend: _ActionCard(
        icon: Icons.play_circle_outline_rounded,
        title: 'Entertainment — Unlock 5 min',
        subtitle: 'Prototype simulation only. No app controls are used.',
        action: () => showSpendConfirmation(context: context, demo: true),
      ),
      footer: TextButton.icon(
        onPressed: demo.reset,
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text('Reset demo'),
      ),
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold({
    required this.title,
    required this.wallet,
    required this.earn,
    required this.quickStudy,
    required this.spend,
    this.demoBanner = false,
    this.footer,
    this.actions,
  });
  final String title;
  final Widget wallet;
  final Widget earn;
  final Widget quickStudy;
  final Widget spend;
  final bool demoBanner;
  final Widget? footer;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundLight,
    appBar: AppBar(
      title: Text(title),
      centerTitle: false,
      actions: demoBanner
          ? const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(child: Text('OFFLINE DEMO')),
              ),
            ]
          : actions,
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          if (demoBanner) const _DemoBanner(),
          wallet,
          const SizedBox(height: 28),
          const _SectionTitle('Earn more'),
          earn,
          const SizedBox(height: 22),
          const _SectionTitle('Quick Study'),
          quickStudy,
          const SizedBox(height: 22),
          const _SectionTitle('Spend your time'),
          spend,
          if (footer != null) Center(child: footer),
        ],
      ),
    ),
  );
}

class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.minutes, this.selectedApps = 0});
  final int minutes;
  final int selectedApps;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SCREEN TIME WALLET',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$minutes min available',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Minutes reset at the start of Sunday.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _WalletMetric(
              icon: Icons.apps_rounded,
              value: '$selectedApps',
              label: 'protected',
            ),
            const SizedBox(width: 20),
            const _WalletMetric(
              icon: Icons.shield_rounded,
              value: 'Ready',
              label: 'to spend',
            ),
          ],
        ),
      ],
    ),
  );
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(width: 6),
      Text(
        '$value ',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70)),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: Theme.of(
        c,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.course,
    required this.onTap,
  });
  final dynamic task;
  final String course;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(child: Icon(Icons.task_alt_rounded)),
      title: Text(task.title),
      subtitle: Text(course),
      trailing: Text(
        '+${task.rewardMinutes} min',
        style: const TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      onTap: action,
      enabled: action != null,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: .12),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext c) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Text(message)),
  );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();
  @override
  Widget build(BuildContext c) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.reward.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.info_outline_rounded),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Offline prototype: unlocks are simulated and never control your apps.',
          ),
        ),
      ],
    ),
  );
}
