import 'package:get/get.dart';
import '../../../data/models/subject.dart';
import '../../../data/services/supabase_service.dart';

class SubjectsController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<Subject> subjects = <Subject>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    isLoading.value = true;
    try {
      final rows = await _supabaseService.getSubjects(user.id);
      subjects.assignAll(rows.map(Subject.fromMap));
    } catch (e) {
      // ignore — empty list shown
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubject(String name, {DateTime? examDate}) async {
    final user = _supabaseService.currentUser;
    if (user == null || name.trim().isEmpty) return;
    try {
      final row = await _supabaseService.insertSubject(
        userId: user.id,
        name: name.trim(),
        examDate: examDate,
      );
      subjects.add(Subject.fromMap(row));
    } catch (_) {}
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      await _supabaseService.deleteSubject(subjectId);
      subjects.removeWhere((s) => s.id == subjectId);
    } catch (_) {}
  }
}
