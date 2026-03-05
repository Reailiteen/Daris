enum QuestionType { multipleChoice, flashcard }

class StudyQuestion {
  final String id;
  final String subject;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final QuestionType type;

  const StudyQuestion({
    required this.id,
    required this.subject,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.type,
  });
}
