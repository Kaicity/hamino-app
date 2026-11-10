import '../entities/workout_category.dart';
import '../entities/workout_template_entity.dart';

/// Repository định nghĩa các phương thức nghiệp vụ lưu trữ & truy vấn giáo án bài tập
abstract class WorkoutRepository {
  /// Lấy toàn bộ danh sách giáo án (kèm danh sách bài tập con sắp xếp theo thứ tự)
  Future<List<WorkoutTemplateEntity>> getAllWorkouts();

  /// Lọc danh sách giáo án theo từng thể loại Calisthenics cụ thể
  Future<List<WorkoutTemplateEntity>> getWorkoutsByCategory(WorkoutCategory category);

  /// Lấy chi tiết một giáo án theo ID
  Future<WorkoutTemplateEntity?> getWorkoutById(String id);

  /// Lưu giáo án (Tạo mới hoặc cập nhật toàn diện bài tập và động tác con trong Transaction)
  Future<void> saveWorkout(WorkoutTemplateEntity workout);

  /// Xóa giáo án theo ID (Tự động xóa các bài tập con nhờ CASCADE)
  Future<void> deleteWorkout(String id);

  /// Bật/tắt đánh dấu giáo án yêu thích
  Future<void> toggleFavorite(String id, bool isFavorite);
}

