enum TaskDifficulty { small, medium, hard }

extension TaskDifficultyExtension on TaskDifficulty {
  String get label {
    switch (this) {
      case TaskDifficulty.small:
        return 'Small';
      case TaskDifficulty.medium:
        return 'Medium';
      case TaskDifficulty.hard:
        return 'Hard';
    }
  }

  int get rewardMinutes {
    switch (this) {
      case TaskDifficulty.small:
        return 10;
      case TaskDifficulty.medium:
        return 25;
      case TaskDifficulty.hard:
        return 60;
    }
  }

  static TaskDifficulty fromString(String value) {
    switch (value) {
      case 'small':
        return TaskDifficulty.small;
      case 'medium':
        return TaskDifficulty.medium;
      case 'hard':
        return TaskDifficulty.hard;
      default:
        return TaskDifficulty.small;
    }
  }
}

class StudyTask {
  final String id;
  final String userId;
  final String title;
  final String? subjectId;
  final TaskDifficulty difficulty;
  final int rewardMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  const StudyTask({
    required this.id,
    required this.userId,
    required this.title,
    this.subjectId,
    required this.difficulty,
    required this.rewardMinutes,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
  });

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    final difficulty = TaskDifficultyExtension.fromString(map['difficulty'] as String);
    return StudyTask(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      subjectId: map['subject_id'] as String?,
      difficulty: difficulty,
      rewardMinutes: map['reward_minutes'] as int,
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  StudyTask copyWith({bool? isCompleted, DateTime? completedAt}) {
    return StudyTask(
      id: id,
      userId: userId,
      title: title,
      subjectId: subjectId,
      difficulty: difficulty,
      rewardMinutes: rewardMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}
