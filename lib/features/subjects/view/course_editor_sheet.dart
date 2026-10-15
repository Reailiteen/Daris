import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/subject.dart';
import '../controller/subjects_controller.dart';

Future<void> showCourseEditor(BuildContext context, {Subject? subject}) async {
  final name = TextEditingController(text: subject?.name ?? '');
  final textbook = TextEditingController(text: subject?.syllabusBook ?? '');
  final notes = TextEditingController(text: subject?.materialNotes ?? '');
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          var saving = false;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject == null ? 'Add course' : 'Edit course',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Course name',
                    hintText: 'CHEM101',
                  ),
                ),
                TextField(
                  controller: textbook,
                  decoration: const InputDecoration(
                    labelText: 'Textbook name (optional)',
                  ),
                ),
                TextField(
                  controller: notes,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Pasted course material (optional)',
                    hintText:
                        'Paste concise notes, topics, or a study guide. PDFs stay local and are not sent.',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving || name.text.trim().isEmpty
                        ? null
                        : () async {
                            setState(() => saving = true);
                            final controller = Get.find<SubjectsController>();
                            if (subject == null) {
                              await controller.addSubject(
                                name: name.text,
                                syllabusBook: textbook.text,
                                materialNotes: notes.text,
                              );
                            } else {
                              await controller.updateSubject(
                                subject: subject,
                                name: name.text,
                                syllabusBook: textbook.text,
                                materialNotes: notes.text,
                              );
                            }
                            if (sheetContext.mounted)
                              Navigator.pop(sheetContext);
                          },
                    child: Text(saving ? 'Saving…' : 'Save course'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
  name.dispose();
  textbook.dispose();
  notes.dispose();
}
