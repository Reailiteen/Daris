import 'package:uuid/uuid.dart';

enum SessionDuration {
  fifteen(15, '15 min'),
  thirty(30, '30 min'),
  fortyfive(45, '45 min'),
  sixty(60, '1 hour'),
  ninety(90, '1.5 hours'),
  onetwenty(120, '2 hours'),
  oneeighty(180, '3 hours');

  final int minutes;
  final String displayName;
  const SessionDuration(this.minutes, this.displayName);

  Duration get duration => Duration(minutes: minutes);
}

class FocusSession {
  final String id;
  final Duration duration;
  final Duration breakDuration;
  final Duration breakInterval;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isActive;
  final bool completedSuccessfully;

  FocusSession({
    String? id,
    required this.duration,
    this.breakDuration = Duration.zero,
    this.breakInterval = Duration.zero,
    this.startTime,
    this.endTime,
    this.isActive = false,
    this.completedSuccessfully = false,
  }) : id = id ?? const Uuid().v4();

  Duration get remainingTime {
    if (startTime == null || !isActive) return duration;
    final elapsed = DateTime.now().difference(startTime!);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progress {
    if (duration.inSeconds == 0) return 0.0;
    return 1.0 - (remainingTime.inSeconds / duration.inSeconds);
  }

  String get formattedRemainingTime {
    final remaining = remainingTime;
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;

    if (h > 0) {
      return '${h.toString()}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration.inSeconds,
      'breakDuration': breakDuration.inSeconds,
      'breakInterval': breakInterval.inSeconds,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
      'completedSuccessfully': completedSuccessfully,
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      duration: Duration(seconds: json['duration']),
      breakDuration: Duration(seconds: json['breakDuration']),
      breakInterval: Duration(seconds: json['breakInterval']),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isActive: json['isActive'] ?? false,
      completedSuccessfully: json['completedSuccessfully'] ?? false,
    );
  }
}
