import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class SessionStatistic {
  final String id;
  final DateTime date;
  final Duration duration;
  final bool completedSuccessfully;
  final int blockedAppsCount;

  SessionStatistic({
    String? id,
    DateTime? date,
    required this.duration,
    required this.completedSuccessfully,
    this.blockedAppsCount = 0,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  String get formattedDate {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  String get formattedDuration {
    int minutes = duration.inMinutes;
    if (minutes >= 60) {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
    return '$minutes min';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
      'completedSuccessfully': completedSuccessfully,
      'blockedAppsCount': blockedAppsCount,
    };
  }

  factory SessionStatistic.fromJson(Map<String, dynamic> json) {
    return SessionStatistic(
      id: json['id'],
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration']),
      completedSuccessfully: json['completedSuccessfully'],
      blockedAppsCount: json['blockedAppsCount'] ?? 0,
    );
  }
}
