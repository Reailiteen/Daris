enum QuestionType { multipleChoice, trueOrFalse, openEnded }

class StudyQuestion {
  final String id;
  final String subject;
  final String questionText;
  final QuestionType type;

  // MCQ
  final List<String> options;
  final int correctIndex;

  // True / False
  final bool? correctBool;
  final String? explanation;

  // Open-ended
  final String? expectedAnswer;

  const StudyQuestion({
    required this.id,
    required this.subject,
    required this.questionText,
    required this.type,
    this.options = const [],
    this.correctIndex = -1,
    this.correctBool,
    this.explanation,
    this.expectedAnswer,
  });
}
