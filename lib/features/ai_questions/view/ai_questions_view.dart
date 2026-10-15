import 'package:flutter/material.dart';
import 'quick_study_view.dart';

/// Kept as the named-route entry point while QuickStudyView owns the new flow.
class AIQuestionsView extends StatelessWidget {
  const AIQuestionsView({super.key});
  @override
  Widget build(BuildContext context) => const QuickStudyView();
}
