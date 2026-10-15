import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/study_task.dart';
import '../../demo/controller/demo_mode_controller.dart';
import '../controller/tasks_controller.dart';
import '../../ai_questions/view/reward_result_view.dart';

class TaskDetailView extends StatefulWidget {
  const TaskDetailView({
    super.key,
    required this.task,
    required this.course,
    this.demo = false,
  });
  final StudyTask task;
  final String course;
  final bool demo;
  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  bool confirmed = false;
  bool saving = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Task details')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.task.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(widget.course),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete “${widget.task.title}” for ${widget.course}, then confirm it below.',
          ),
          const SizedBox(height: 20),
          Text(
            'Reward: +${widget.task.rewardMinutes} min',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          const Text(
            'Confirm that you completed this task yourself. This is a plain self-confirmation, not automated verification.',
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: confirmed,
            onChanged: (v) => setState(() => confirmed = v ?? false),
            contentPadding: EdgeInsets.zero,
            title: const Text('I completed this task'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !confirmed || saving
                  ? null
                  : () async {
                      setState(() => saving = true);
                      final result = widget.demo
                          ? await Get.find<DemoModeController>().completeTask(
                              widget.task,
                            )
                          : await Get.find<TasksController>().completeTask(
                              widget.task.id,
                            );
                      if (!mounted || result == null) return;
                      Get.off(
                        () =>
                            RewardResultView(result: result, demo: widget.demo),
                      );
                    },
              child: Text(saving ? 'Saving…' : 'Mark as completed'),
            ),
          ),
        ],
      ),
    ),
  );
}
