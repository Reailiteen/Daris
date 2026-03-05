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
