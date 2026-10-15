class Subject {
  final String id;
  final String userId;
  final String name;
  final String? syllabusBook;
  final String? syllabusFilePath;
  final String? materialNotes;
  final DateTime? examDate;
  final int numQuizzes;
  final int numAssignments;
  final int numMidterms;
  final int numFinals;
  final int numProjects;
  final DateTime createdAt;

  const Subject({
    required this.id,
    required this.userId,
    required this.name,
    this.syllabusBook,
    this.syllabusFilePath,
    this.materialNotes,
    this.examDate,
    this.numQuizzes = 0,
    this.numAssignments = 0,
    this.numMidterms = 0,
    this.numFinals = 0,
    this.numProjects = 0,
    required this.createdAt,
  });

  int get totalTasks =>
      numQuizzes + numAssignments + numMidterms + numFinals + numProjects;

  int get totalRewardMinutes =>
      numQuizzes * 10 +
      numAssignments * 25 +
      numMidterms * 60 +
      numFinals * 60 +
      numProjects * 60;

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      syllabusBook: map['syllabus_book'] as String?,
      syllabusFilePath: map['syllabus_file_path'] as String?,
      materialNotes: map['material_notes'] as String?,
      examDate: map['exam_date'] != null
          ? DateTime.tryParse(map['exam_date'] as String)
          : null,
      numQuizzes: (map['num_quizzes'] as int?) ?? 0,
      numAssignments: (map['num_assignments'] as int?) ?? 0,
      numMidterms: (map['num_midterms'] as int?) ?? 0,
      numFinals: (map['num_finals'] as int?) ?? 0,
      numProjects: (map['num_projects'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Subject copyWith({
    String? name,
    String? syllabusBook,
    String? materialNotes,
  }) => Subject(
    id: id,
    userId: userId,
    name: name ?? this.name,
    syllabusBook: syllabusBook ?? this.syllabusBook,
    syllabusFilePath: syllabusFilePath,
    materialNotes: materialNotes ?? this.materialNotes,
    examDate: examDate,
    numQuizzes: numQuizzes,
    numAssignments: numAssignments,
    numMidterms: numMidterms,
    numFinals: numFinals,
    numProjects: numProjects,
    createdAt: createdAt,
  );
}
