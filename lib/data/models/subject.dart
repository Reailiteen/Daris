class Subject {
  final String id;
  final String userId;
  final String name;
  final DateTime? examDate;
  final String? materialNotes;
  final DateTime createdAt;

  const Subject({
    required this.id,
    required this.userId,
    required this.name,
    this.examDate,
    this.materialNotes,
    required this.createdAt,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      examDate: map['exam_date'] != null
          ? DateTime.tryParse(map['exam_date'] as String)
          : null,
      materialNotes: map['material_notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      if (examDate != null) 'exam_date': examDate!.toIso8601String().split('T')[0],
      if (materialNotes != null) 'material_notes': materialNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
