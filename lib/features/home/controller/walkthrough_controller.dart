import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/services/supabase_service.dart';

/// Manages the forced first-launch guided walkthrough.
/// Steps:
///   0 → Block apps  (Focus tab, user must select ≥1 app)
///   1 → Add subject (Earn tab, user must create ≥1 subject)
///   2 → Completion  (full-screen recap card)
class WalkthroughController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final RxBool isActive    = false.obs;
  final RxInt  currentStep = 0.obs;

  static const int totalSteps = 3;
  static const String _flagFile = 'walkthrough_complete.flag';

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  // ── Local flag file (path_provider) ───────────────────────────

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_flagFile');
  }

  Future<bool> _isLocalFlagSet() async {
    try {
      return await (await _file()).exists();
    } catch (_) {
      return false;
    }
  }

  Future<void> _writeLocalFlag() async {
    try {
      await (await _file()).writeAsString('1');
    } catch (_) {}
  }

  // ── Startup check ─────────────────────────────────────────────

  Future<void> _initialize() async {
    // 1. Fast local check — avoids a network round-trip on repeat launches
    if (await _isLocalFlagSet()) return;

    // 2. DB check — handles fresh installs / account-level state
    final user = _supabase.currentUser;
    if (user != null) {
      try {
        final profile = await _supabase.getProfile(user.id);
        if (profile?['walkthrough_complete'] == true) {
          await _writeLocalFlag(); // cache for next launch
          return;
        }
      } catch (_) {}
    }

    isActive.value = true;
  }

  // ── Actions ───────────────────────────────────────────────────

  void advance() {
    currentStep.value++;
  }

  Future<void> complete() async {
    isActive.value = false;
    await _writeLocalFlag(); // persist immediately — no network needed
    final user = _supabase.currentUser;
    if (user == null) return;
    try {
      await _supabase.markWalkthroughComplete(user.id);
    } catch (_) {
      // Non-fatal — local flag already written
    }
  }
}
