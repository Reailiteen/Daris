import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';

class BalanceController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxInt earnedMinutesThisWeek = 0.obs;

  bool get isUnlimited => earnedMinutesThisWeek.value >= 300;

  String get formattedBalance {
    final total = earnedMinutesThisWeek.value;
    final h = total ~/ 60;
    final m = total % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  DateTime get _weekStart {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  @override
  void onInit() {
    super.onInit();
    loadBalance();
  }

  Future<void> loadBalance() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    try {
      final total = await _supabaseService.getWeeklyEarnings(user.id, _weekStart);
      earnedMinutesThisWeek.value = total;
    } catch (_) {}
  }

  Future<void> addEarning(String source, int minutes) async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    try {
      await _supabaseService.addEarning(
        userId: user.id,
        source: source,
        minutes: minutes,
        weekStart: _weekStart,
      );
      earnedMinutesThisWeek.value += minutes;
    } catch (_) {}
  }
}
