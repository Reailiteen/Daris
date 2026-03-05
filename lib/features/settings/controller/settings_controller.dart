import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';

class SettingsController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxBool notificationsEnabled = true.obs;
  final RxString displayName = ''.obs;
  final RxString email = ''.obs;
  final RxBool profileLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    email.value = _supabaseService.currentUser?.email ?? '';
    final userId = _supabaseService.currentUser?.id;
    if (userId == null) return;
    profileLoading.value = true;
    try {
      final profile = await _supabaseService.getProfile(userId);
      if (profile != null) {
        displayName.value = (profile['display_name'] as String?) ?? '';
      }
    } catch (_) {
    } finally {
      profileLoading.value = false;
    }
  }

  Future<void> updateDisplayName(String name) async {
    final userId = _supabaseService.currentUser?.id;
    if (userId == null || name.trim().isEmpty) return;
    await _supabaseService.updateProfileDisplayName(userId, name.trim());
    displayName.value = name.trim();
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    Get.offAllNamed('/landing');
  }

  Future<void> revokeAuthorization() async {}
}
