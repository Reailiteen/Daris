// lib/data/models/sport.dart
class Sport {
  final String id;
  final String name;
  final String category;
  final List<String> supportedMetrics;
  final String? intensityModel;

  Sport({
    required this.id,
    required this.name,
    required this.category,
    this.supportedMetrics = const [],
    this.intensityModel,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      supportedMetrics: List<String>.from(json['supported_metrics'] ?? []),
      intensityModel: json['intensity_model'],
    );
  }
}

// lib/data/models/activity_session.dart
class ActivitySession {
  final String id;
  final String userId;
  final String sportId;
  final DateTime startTime;
  final DateTime endTime;
  final String duration;
  final double? intensityValue;
  final String source;
  final String validationStatus;

  ActivitySession({
    required this.id,
    required this.userId,
    required this.sportId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.intensityValue,
    this.source = 'manual',
    this.validationStatus = 'pending',
  });

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      id: json['id'],
      userId: json['user_id'],
      sportId: json['sport_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      duration: json['duration'],
      intensityValue: (json['intensity_value'] as num?)?.toDouble(),
      source: json['source'],
      validationStatus: json['validation_status'],
    );
  }
}

// lib/data/models/focus_cycle.dart
class FocusCycle {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String status;

  FocusCycle({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.status,
  });

  factory FocusCycle.fromJson(Map<String, dynamic> json) {
    return FocusCycle(
      id: json['id'],
      userId: json['user_id'],
      weekStart: DateTime.parse(json['week_start']),
      weekEnd: DateTime.parse(json['week_end']),
      status: json['status'],
    );
  }
}

// lib/data/models/screen_budget.dart
class ScreenBudget {
  final String id;
  final String cycleId;
  final String baseAllowance;
  final String? maximumCap;
  final String earnedCredits;
  final String remainingBalance;
  final DateTime? expiresAt;

  ScreenBudget({
    required this.id,
    required this.cycleId,
    required this.baseAllowance,
    this.maximumCap,
    required this.earnedCredits,
    required this.remainingBalance,
    this.expiresAt,
  });

  factory ScreenBudget.fromJson(Map<String, dynamic> json) {
    return ScreenBudget(
      id: json['id'],
      cycleId: json['cycle_id'],
      baseAllowance: json['base_allowance'],
      maximumCap: json['maximum_cap'],
      earnedCredits: json['earned_credits'],
      remainingBalance: json['remaining_balance'],
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }
}
