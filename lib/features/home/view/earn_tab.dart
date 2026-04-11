import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../walkthrough_keys.dart';
import '../../../data/models/study_task.dart';
import '../../balance/controller/balance_controller.dart';
import '../../tasks/controller/tasks_controller.dart';
import '../../subjects/controller/subjects_controller.dart';

class EarnTab extends StatelessWidget {
  const EarnTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.flat(isDark)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EarnHeader(isDark: isDark),
              const SizedBox(height: 20),

              _HeroBalanceCard(isDark: isDark),
              const SizedBox(height: 14),

              _UnlockHourCard(isDark: isDark),
              const SizedBox(height: 28),

              // Subjects header
              Row(
                children: [
                  Text(
                    'My Subjects',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    key: WalkthroughKeys.addSubjectBtn,
                    onTap: () => _showAddSubjectSheet(context, isDark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Add',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SubjectCardList(isDark: isDark),
              const SizedBox(height: 28),

              // Pending tasks header
              Row(
                children: [
                  Text(
                    'Pending Tasks',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed('/tasks'),
                    child: Text('See all',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _TasksPreview(isDark: isDark),
              const SizedBox(height: 28),

              _RewardTable(isDark: isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSubjectSheet(isDark: isDark),
    );
  }
}

// MARK: - Earn Header

class _EarnHeader extends StatelessWidget {
  const _EarnHeader({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earn',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Study hard. Unlock more.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: AppColors.primary, size: 13),
              const SizedBox(width: 6),
              const Text(
                'This Week',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// MARK: - Hero Balance Card

class _HeroBalanceCard extends StatelessWidget {
  const _HeroBalanceCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final balance = Get.find<BalanceController>();
    return Obx(() {
      final earned = balance.earnedMinutesThisWeek.value;
      final hours = earned ~/ 60;
      final minutes = earned % 60;
      final progress = (earned / 300).clamp(0.0, 1.0);
      final sessionsCompleted = 0;
      const sessionsGoal = 5;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — label + badge
            Row(
              children: [
                const Text(
                  'Screen Time Balance',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (balance.isUnlimited)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.all_inclusive_rounded,
                            color: Colors.white54, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'unlimited',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: Colors.white54, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'earned',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Large balance display
            if (balance.isUnlimited)
              const Text(
                'Unlimited!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$hours',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'hr',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$minutes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'min',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Progress section
            if (!balance.isUnlimited) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Weekly goal',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '$sessionsCompleted / $sessionsGoal sessions',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Weekly milestone reached! Enjoy your week.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// MARK: - Unlock 1 Hour Card

class _UnlockHourCard extends StatelessWidget {
  const _UnlockHourCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed('/ai-questions', arguments: {'unlock': true}),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: DarisDecorations.elevatedCard(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_open_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock 1 Hour',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 3),
                  Text(
                    'Answer 10 mixed questions from all your subjects. Complete the quiz to earn 60 minutes.',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }
}

// MARK: - Subject Card List

class _SubjectCardList extends StatelessWidget {
  const _SubjectCardList({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SubjectsController>();
    return Obx(() {
      if (ctrl.subjects.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: DarisDecorations.card(isDark),
          child: Row(
            children: [
              Icon(Icons.school_outlined,
                  color: isDark ? Colors.white24 : Colors.black26, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No subjects yet. Tap Add to get started.',
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        );
      }
      return Column(
        children: ctrl.subjects
            .map((s) => _SubjectCard(subject: s, isDark: isDark))
            .toList(),
      );
    });
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.isDark});
  final dynamic subject;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SubjectsController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: DarisDecorations.card(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name as String,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87),
                    ),
                    if ((subject.syllabusBook as String?) != null &&
                        (subject.syllabusBook as String).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subject.syllabusBook as String,
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    ],
                    if ((subject.syllabusFilePath as String?) != null) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => OpenFilex.open(subject.syllabusFilePath as String),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded,
                                size: 13, color: Color(0xFFE53935)),
                            const SizedBox(width: 4),
                            Text(
                              _pdfBasename(subject.syllabusFilePath as String),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ctrl.deleteSubject(subject.id as String),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18,
                      color: isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ],
          ),

          // Semester components
          if ((subject.totalTasks as int) > 0) ...[
            const SizedBox(height: 14),
            Container(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if ((subject.numQuizzes as int) > 0)
                  _Pill(
                      '${subject.numQuizzes} Quiz${(subject.numQuizzes as int) > 1 ? "zes" : ""}',
                      AppColors.primary),
                if ((subject.numAssignments as int) > 0)
                  _Pill(
                      '${subject.numAssignments} Assignment${(subject.numAssignments as int) > 1 ? "s" : ""}',
                      AppColors.success),
                if ((subject.numMidterms as int) > 0)
                  _Pill(
                      '${subject.numMidterms} Midterm${(subject.numMidterms as int) > 1 ? "s" : ""}',
                      AppColors.reward),
                if ((subject.numFinals as int) > 0)
                  _Pill(
                      '${subject.numFinals} Final${(subject.numFinals as int) > 1 ? "s" : ""}',
                      AppColors.error),
                if ((subject.numProjects as int) > 0)
                  _Pill(
                      '${subject.numProjects} Project${(subject.numProjects as int) > 1 ? "s" : ""}',
                      AppColors.primaryLight),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${subject.totalTasks} tasks  ·  ${subject.totalRewardMinutes} min potential',
              style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white30 : Colors.black38),
            ),
          ],

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/tasks'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 15,
                            color: isDark ? Colors.white54 : Colors.black54),
                        const SizedBox(width: 6),
                        Text('Tasks',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed('/ai-questions', arguments: {
                    'subjectName': subject.name,
                    'syllabusBook': subject.syllabusBook,
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_rounded,
                            size: 15, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Quiz',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _pdfBasename(String path) {
  final name = path.split('/').last;
  return name.length > 30 ? '${name.substring(0, 27)}...' : name;
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// MARK: - Tasks Preview

class _TasksPreview extends StatelessWidget {
  const _TasksPreview({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tasksCtrl = Get.find<TasksController>();
    return Obx(() {
      final tasks = tasksCtrl.tasks.take(3).toList();
      if (tasks.isEmpty) {
        return GestureDetector(
          onTap: () => Get.toNamed('/tasks'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: DarisDecorations.card(isDark),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No tasks yet — add a subject to auto-create them',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Column(
        children: tasks.map((task) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: DarisDecorations.card(isDark),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          '${task.difficulty.label}  ·  +${task.rewardMinutes}m',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.black45)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => tasksCtrl.completeTask(task.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

// MARK: - Reward Table

class _RewardTable extends StatelessWidget {
  const _RewardTable({required this.isDark});
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
              Icon(Icons.info_outline_rounded,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text('How you earn',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          _row('Small task (quiz)', '+10m', isDark),
          _row('Medium task (assignment)', '+25m', isDark),
          _row('Hard task (midterm / final / project)', '+60m', isDark),
          _row('1 correct AI answer', '+2m', isDark),
          _row('Perfect quiz (5/5)', '+5m bonus', isDark),
          _row('Unlock quiz (10 mixed questions)', '+60m flat', isDark),
          const SizedBox(height: 6),
          Text(
            '300m earned = unlimited for the week. Resets every Monday.',
            style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white30 : Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String reward, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54)),
          ),
          Text(reward,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

// MARK: - Add Subject Sheet (2 steps)

class _AddSubjectSheet extends StatefulWidget {
  const _AddSubjectSheet({required this.isDark});
  final bool isDark;

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _bookCtrl = TextEditingController();
  String? _pdfPath;
  String? _pdfDisplayName;
  bool _pickingPdf = false;
  int _quizzes = 0;
  int _assignments = 0;
  int _midterms = 0;
  int _finals = 0;
  int _projects = 0;

  int get _totalTasks =>
      _quizzes + _assignments + _midterms + _finals + _projects;
  int get _totalMinutes =>
      _quizzes * 10 + _assignments * 25 + (_midterms + _finals + _projects) * 60;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bookCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    setState(() => _pickingPdf = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty || result.files.first.path == null) return;
      final picked = result.files.first;
      final docsDir = await getApplicationDocumentsDirectory();
      final syllabusDir = Directory('${docsDir.path}/syllabi');
      await syllabusDir.create(recursive: true);
      final dest = File('${syllabusDir.path}/${picked.name}');
      await File(picked.path!).copy(dest.path);
      setState(() {
        _pdfPath = dest.path;
        _pdfDisplayName = picked.name;
      });
    } finally {
      setState(() => _pickingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildStepIndicator(isDark),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.05, 0), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                ),
                child: _step == 0
                    ? _buildStep1(isDark)
                    : _buildStep2(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: [
        _dot(0, isDark),
        _line(isDark),
        _dot(1, isDark),
      ],
    );
  }

  Widget _dot(int index, bool isDark) {
    final active = _step >= index;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color:
            active ? null : (isDark ? Colors.white12 : Colors.black12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text('${index + 1}',
            style: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white38 : Colors.black38),
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _line(bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: _step >= 1 ? AppColors.primaryGradient : null,
          color: _step >= 1
              ? null
              : (isDark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      key: const ValueKey('s1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject Details',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Text('Tell us about the course',
            style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45)),
        const SizedBox(height: 24),
        _label('Subject Name', isDark),
        const SizedBox(height: 8),
        _field(_nameCtrl, 'e.g. Calculus I', isDark, autofocus: true),
        const SizedBox(height: 16),
        _label('Textbook / Syllabus (optional)', isDark),
        const SizedBox(height: 8),
        _field(_bookCtrl, 'e.g. Stewart Calculus 8th Edition', isDark),
        const SizedBox(height: 10),
        _buildPdfPicker(isDark),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              setState(() => _step = 1);
            },
            child: const Text('Continue',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Column(
      key: const ValueKey('s2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Semester Plan',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Text(
            'How many of each? Tasks are created automatically when you save.',
            style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.4)),
        const SizedBox(height: 20),
        _stepper('Quizzes', _quizzes, AppColors.primary, isDark,
            (v) => setState(() => _quizzes = v)),
        _stepper('Assignments', _assignments, AppColors.success, isDark,
            (v) => setState(() => _assignments = v)),
        _stepper('Midterms', _midterms, AppColors.reward, isDark,
            (v) => setState(() => _midterms = v)),
        _stepper('Finals', _finals, AppColors.error, isDark,
            (v) => setState(() => _finals = v)),
        _stepper('Projects', _projects, AppColors.primaryLight, isDark,
            (v) => setState(() => _projects = v)),
        if (_totalTasks > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                    'Creates $_totalTasks tasks worth $_totalMinutes minutes',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text('Back',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.primary,
                ),
                onPressed: _save,
                child: const Text('Save Subject',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPdfPicker(bool isDark) {
    if (_pdfPath != null && _pdfDisplayName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFFE53935).withValues(alpha: 0.1)
              : const Color(0xFFE53935).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFE53935).withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                size: 18, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _pdfDisplayName!,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _pdfPath = null;
                _pdfDisplayName = null;
              }),
              child: Icon(Icons.close_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: _pickingPdf ? null : _pickPdf,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file_rounded,
                size: 18,
                color: isDark ? Colors.white38 : Colors.black38),
            const SizedBox(width: 8),
            Text(
              _pickingPdf ? 'Selecting...' : 'Attach PDF (optional)',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black54));

  Widget _field(TextEditingController ctrl, String hint, bool isDark,
      {bool autofocus = false}) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _stepper(String label, int value, Color color, bool isDark,
      ValueChanged<int> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87)),
          ),
          GestureDetector(
            onTap: value > 0 ? () => onChanged(value - 1) : null,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove,
                  size: 16,
                  color: value > 0
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
          ),
          GestureDetector(
            onTap: () => onChanged(value + 1),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final ctrl = Get.find<SubjectsController>();
    await ctrl.addSubject(
      name: _nameCtrl.text.trim(),
      syllabusBook:
          _bookCtrl.text.trim().isEmpty ? null : _bookCtrl.text.trim(),
      syllabusFilePath: _pdfPath,
      numQuizzes: _quizzes,
      numAssignments: _assignments,
      numMidterms: _midterms,
      numFinals: _finals,
      numProjects: _projects,
    );
    if (mounted) Navigator.of(context).pop();
  }
}
