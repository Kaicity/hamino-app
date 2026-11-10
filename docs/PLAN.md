# KẾ HOẠCH TRIỂN KHAI VÀ PHÂN CHIA NHIỆM VỤ CHI TIẾT (PLAN.MD)
## DỰ ÁN: HAMINO WORKOUT - CHUYÊN BIỆT CHO CALISTHENICS

---

| Mục | Thông Tin |
| :--- | :--- |
| **Dự án** | Hamino Workout |
| **Chiến lược phát triển** | Agile / Sprints theo giai đoạn tính năng (Feature-driven) |
| **Tiến độ dự kiến** | 7 Phases (Từ Phase 0 đến Phase 6: Nền tảng ➔ Đóng gói) |
| **Ngày lập kế hoạch** | 10/11/2026 |
| **Trạng thái tài liệu** | Đã phân rã chi tiết thành Actionable Checklist cho từng Phase |

---

## 1. LỘ TRÌNH TỔNG QUAN CÁC GIAI ĐOẠN (ROADMAP OVERVIEW)

```
┌────────────────────────────────────────────────────────────────────────┐
│ PHASE 0: Khởi tạo Kiến trúc, Thư viện & Thiết kế Giao diện dùng chung  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ PHASE 1: Cơ sở dữ liệu Cục bộ (Local DB) & Thư viện Bài tập Mẫu        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ PHASE 2: Quản lý & Trình tạo Bài tập (Workout Builder CRUD)            │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ PHASE 3: Bộ đếm giờ Chuẩn xác & Màn hình Tập luyện (Timer Engine & UI) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ PHASE 4: Hệ thống Giọng nói Thông minh (TTS) & Hiệu ứng Âm thanh (SFX) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ PHASE 5: Wakelock, Chạy nền, Lịch sử Tập luyện & Thống kê              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│ PHASE 6: Cài đặt Hệ thống, Tối ưu Hiệu năng, Kiểm thử & Đóng gói        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. CHECKLIST TIẾN ĐỘ TỔNG HỢP (MASTER PROGRESS TRACKER)

- [x] **Phase 0:** Khởi tạo Nền tảng, Thư viện & Core Architecture *(4/4 Tasks - 14/14 Checklist Items)*
- [x] **Phase 1:** Cơ sở dữ liệu Cục bộ & Preset Mẫu Calisthenics *(4/4 Tasks - 16/16 Checklist Items)*
- [x] **Phase 2:** Quản lý & Trình tạo Bài tập (Workout Builder CRUD) *(4/4 Tasks - 16/16 Checklist Items)*
- [x] **Phase 3:** Bộ đếm giờ Chuẩn xác & Màn hình Tập luyện (Timer Engine & UI) *(5/5 Tasks - 18/18 Checklist Items)*
- [ ] **Phase 4:** Hệ thống Giọng nói Thông minh (TTS) & Âm thanh (Audio Coach) *(0/4 Tasks - 0/15 Checklist Items)*
- [ ] **Phase 5:** Wakelock, Chạy nền & Lịch sử Tập luyện *(0/4 Tasks - 0/14 Checklist Items)*
- [ ] **Phase 6:** Cài đặt Hệ thống, Kiểm thử, Tối ưu & Hoàn thiện *(0/4 Tasks - 0/14 Checklist Items)*

---

## 3. PHÂN CHIA NHIỆM VỤ CHI TIẾT & CHECKLIST TỪNG PHASE

---

### GIAI ĐOẠN 0: KHỞI TẠO NỀN TẢNG, THƯ VIỆN & CORE ARCHITECTURE (PHASE 0)
*Mục tiêu: Thiết lập cấu trúc mã nguồn sạch Clean Architecture, khai báo đầy đủ dependencies, thiết lập Dependency Injection và hệ thống Theme Dark Mode thể thao tương phản cao.*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 0
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-0.1** | Khai báo Dependencies & Assets | Bổ sung các gói thư viện vào `pubspec.yaml` và cấu hình thư mục assets. | Chạy `flutter pub get` thành công không xung đột phiên bản. | P0 |
| **TASK-0.2** | Cấu trúc thư mục Feature-first | Phân chia cây thư mục theo chuẩn Clean Architecture: `core/` và `features/`. | Thư mục rõ ràng, phân tách mạch lạc giữa Domain, Data và UI. | P0 |
| **TASK-0.3** | Core Theme & Typography | Thiết lập bảng màu Dark Mode thể thao, độ tương phản cao cho người tập. | Theme áp dụng đồng bộ qua `ThemeData` và Color tokens. | P1 |
| **TASK-0.4** | Dependency Injection (GetIt) | Cấu hình Service Locator để đăng ký Singletons, Repositories, BLoCs. | Gọi service thông qua `sl<Type>()` trơn tru. | P1 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [x] **TASK-0.1: Khai báo Dependencies & Cấu hình Assets**
  - [x] Khai báo nhóm Core & State: `flutter_bloc: ^8.1.3`, `equatable: ^2.0.5`, `get_it: ^7.6.4`, `uuid: ^4.3.3`, `intl: ^0.19.0` trong `pubspec.yaml`.
  - [x] Khai báo nhóm Lưu trữ: `sqflite: ^2.3.0`, `path: ^1.8.3`, `path_provider: ^2.1.2`, `shared_preferences: ^2.2.2`.
  - [x] Khai báo nhóm Âm thanh & Phần cứng: `flutter_tts: ^4.1.0`, `audioplayers: ^5.2.1`, `audio_session: ^0.1.18`, `wakelock_plus: ^1.1.4`.
  - [x] Khai báo nhóm Giao diện & Tiện ích: `google_fonts: ^6.1.0`, `flutter_local_notifications: ^17.0.0`.
  - [x] Tạo thư mục chứa tài nguyên: `assets/audio/`, `assets/icons/` và đăng ký trong mục `flutter.assets` của `pubspec.yaml`.
  - [x] Chạy lệnh `flutter pub get` và xác nhận không có xung đột phiên bản (no conflicts).

- [x] **TASK-0.2: Thiết lập Cấu trúc Thư mục Feature-First Clean Architecture**
  - [x] Tạo module `lib/core/` chứa:
    - `constants/` (hằng số thời gian, định danh bảng SQLite)
    - `theme/` (màu sắc, typography, theme data)
    - `utils/` (format thời gian `mm:ss`, sound helper)
    - `services/` (audio, tts, wakelock, notification interfaces)
    - `error/` (failures & exceptions handling)
    - `di/` (khởi tạo GetIt container)
  - [x] Tạo module `lib/features/workout_builder/` với 3 tầng: `domain/`, `data/`, `presentation/`.
  - [x] Tạo module `lib/features/workout_player/` với 3 tầng: `domain/`, `data/`, `presentation/`.
  - [x] Tạo module `lib/features/history/` với 3 tầng: `domain/`, `data/`, `presentation/`.
  - [x] Tạo module `lib/features/settings/` với 3 tầng: `domain/`, `data/`, `presentation/`.

- [x] **TASK-0.3: Xây dựng Core Theme, Color Tokens & Typography**
  - [x] Tạo file `lib/core/theme/app_colors.dart`:
    - Nền chính: `bgDark = Color(0xFF121212)`
    - Bề mặt card: `surfaceDark = Color(0xFF1E1E1E)`
    - Trạng thái Work: `workGreen = Color(0xFF00E676)` và `workOrange = Color(0xFFFF6D00)`
    - Trạng thái Rest: `restBlue = Color(0xFF2979FF)`
    - Trạng thái Prepare: `prepareYellow = Color(0xFFFFD600)`
    - Văn bản chính: `textWhite = Color(0xFFFFFFFF)`, phụ: `textMuted = Color(0xFFB0BEC5)`
  - [x] Tạo file `lib/core/theme/app_typography.dart`:
    - Cấu hình Google Font thể thao (Oswald / Roboto Mono / Barlow Condensed)
    - Style Timer khổng lồ: `timerBigDisplay` (kích thước 80-100sp, Bold, Monospace)
    - Style Tiêu đề bài tập: `headlineLarge`, `headlineMedium`
    - Style Badge & Labels: `labelMedium`, `labelSmall`
  - [x] Tạo file `lib/core/theme/app_theme.dart` tích hợp `ThemeData.dark()` đồng bộ trên toàn ứng dụng.

- [x] **TASK-0.4: Thiết lập Service Locator & Main Entry**
  - [x] Tạo file `lib/core/di/injection_container.dart` khởi tạo singleton `GetIt sl = GetIt.instance;`.
  - [x] Viết hàm `Future<void> initDependencies()` để lần lượt đăng ký Database, Services, Repositories và BLoCs.
  - [x] Cập nhật `lib/main.dart` gọi `WidgetsFlutterBinding.ensureInitialized()` và `await initDependencies()` trước `runApp()`.

---

### GIAI ĐOẠN 1: CƠ SỞ DỮ LIỆU CỤC BỘ & PRESET MẪU CALISTHENICS (PHASE 1)
*Mục tiêu: Xây dựng cơ sở dữ liệu SQLite lưu trữ offline 100% các bài tập và cung cấp sẵn bộ giáo án Calisthenics chuẩn mực (EMOM, Endurance, Skill, Tabata).*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 1
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-1.1** | Xây dựng Data Models & Entities | Tạo `WorkoutTemplate`, `Exercise`, `WorkoutCategory`, `WorkoutSessionRecord`. | Đầy đủ thuộc tính, hỗ trợ chuyển đổi Map/JSON 2 chiều. | P0 |
| **TASK-1.2** | Khởi tạo Database Helper (SQLite) | Cấu hình `DatabaseHelper` với `sqflite`, tạo bảng `workouts`, `exercises`, `sessions`. | Bảng dữ liệu tạo thành công, Foreign Key Cascade chuẩn. | P0 |
| **TASK-1.3** | Triển khai Workout Repository | Viết các hàm CRUD truy vấn dữ liệu bất đồng bộ. | Đọc/ghi database nhanh, bắt ngoại lệ chính xác. | P0 |
| **TASK-1.4** | Thư viện Bài tập Mẫu (Presets) | Seed dữ liệu 4 giáo án Calisthenics chuẩn khi mở app lần đầu. | Cài app mới là có sẵn 4 bài mẫu chuẩn để tập ngay. | P1 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [x] **TASK-1.1: Định nghĩa Domain Entities & Data Models**
  - [x] Tạo enum `WorkoutCategory` (`emom`, `endurance`, `skill`, `cardio`) có helper lấy nhãn tiếng Việt và màu sắc đại diện.
  - [x] Tạo Entity `ExerciseEntity` và Data Model `ExerciseModel` (`id`, `workoutId`, `name`, `defaultReps`, `holdSeconds`, `orderIndex`, `notes`) hỗ trợ `toMap()` & `fromMap()`.
  - [x] Tạo Entity `WorkoutTemplateEntity` và Data Model `WorkoutTemplateModel` (`id`, `name`, `category`, `description`, `prepareSeconds`, `defaultRestSeconds`, `timeCapSeconds`, `targetRounds`, `isPreset`, `isFavorite`, `createdAt`, `exercises`).
  - [x] Tạo Entity & Model `WorkoutSessionRecord` (`id`, `workoutId`, `workoutName`, `startedAt`, `finishedAt`, `durationSeconds`, `completedRounds`, `rpeScore`, `notes`).
  - [x] Thêm phương thức `copyWith()` cho tất cả các model để phục vụ State Management.

- [x] **TASK-1.2: Thiết kế & Cấu hình Database Helper (SQLite)**
  - [x] Tạo `lib/core/database/database_helper.dart` quản lý kết nối cơ sở dữ liệu `hamino_workout.db`.
  - [x] Viết câu lệnh DDL tạo bảng `workouts`:
    - `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `category TEXT NOT NULL`
    - `description TEXT`, `prepare_seconds INTEGER DEFAULT 10`
    - `default_rest_seconds INTEGER DEFAULT 60`, `time_cap_seconds INTEGER DEFAULT 0`
    - `target_rounds INTEGER DEFAULT 1`, `is_preset INTEGER DEFAULT 0`
    - `is_favorite INTEGER DEFAULT 0`, `created_at TEXT NOT NULL`
  - [x] Viết câu lệnh DDL tạo bảng `exercises`:
    - `id TEXT PRIMARY KEY`, `workout_id TEXT NOT NULL`
    - `name TEXT NOT NULL`, `default_reps INTEGER DEFAULT 10`
    - `hold_seconds INTEGER DEFAULT 0`, `order_index INTEGER NOT NULL`
    - `notes TEXT`, `FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE`
  - [x] Viết câu lệnh DDL tạo bảng `workout_sessions` ghi nhận lịch sử tập luyện.
  - [x] Tạo chỉ mục (Index) trên cột `workout_id` của bảng `exercises` để tăng tốc độ truy vấn.

- [x] **TASK-1.3: Hiện thực Repository Pattern cho Workout**
  - [x] Tạo interface `WorkoutRepository` trong tầng Domain (`lib/features/workout_builder/domain/repositories/workout_repository.dart`).
  - [x] Hiện thực `WorkoutRepositoryImpl` trong tầng Data:
    - [x] `Future<List<WorkoutTemplateModel>> getAllWorkouts()` (kèm danh sách bài tập exercises con).
    - [x] `Future<List<WorkoutTemplateModel>> getWorkoutsByCategory(WorkoutCategory category)`.
    - [x] `Future<WorkoutTemplateModel?> getWorkoutById(String id)`.
    - [x] `Future<void> saveWorkout(WorkoutTemplateModel workout)` (hỗ trợ cả Insert và Update trong một Transaction).
    - [x] `Future<void> deleteWorkout(String id)`.
    - [x] `Future<void> toggleFavorite(String id, bool isFavorite)`.
  - [x] Đăng ký `DatabaseHelper` và `WorkoutRepository` vào GetIt DI.

- [x] **TASK-1.4: Xây dựng Thư viện Giáo án Calisthenics Mẫu (Preset Seed Data)**
  - [x] Tạo file `lib/core/database/preset_workouts_data.dart` chứa danh sách 4 bài tập mẫu:
    - [x] **Preset 1 (EMOM):** "EMOM 20m Beast" - 5 rounds, 4 bài (Phút 1: Pull-up 10 reps; Phút 2: Push-up 20 reps; Phút 3: Dips 15 reps; Phút 4: Rest 60s).
    - [x] **Preset 2 (Endurance):** "Endurance 30m Circuit" - 5 rounds, 4 bài (Pull-ups 8 reps, Dips 12 reps, Australian Rows 12 reps, Bodyweight Squats 20 reps, Rest giữa hiệp 90s, Time Cap 30 phút).
    - [x] **Preset 3 (Skill):** "Skill Handstand Mastery" - 6 rounds (Handstand Wall Hold 20s, Rest 90s, Pike Push-ups 8 reps, Rest 90s).
    - [x] **Preset 4 (Cardio):** "Cardio HIIT Tabata" - 8 rounds (Burpees 20s Work / 10s Rest).
  - [x] Viết logic tự động chèn 4 presets vào SQLite trong callback `onCreate` của `DatabaseHelper`.

---

### GIAI ĐOẠN 2: TRÌNH TẠO & QUẢN LÝ BÀI TẬP (WORKOUT BUILDER CRUD) (PHASE 2)
*Mục tiêu: Xây dựng giao diện hiển thị thư viện bài tập, phân loại theo thể loại, cho phép người dùng tự thiết kế bài tập tùy biến linh hoạt.*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 2
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-2.1** | Màn hình Danh mục Bài tập (Catalog) | Hiển thị danh sách bài tập, Filter chips phân loại thể loại. | Lọc bài tập mượt mà; có nút "+" để tạo bài tập mới. | P0 |
| **TASK-2.2** | Thẻ hiển thị bài tập (Workout Card) | Widget hiển thị thông tin bài, badge thể loại, nút Start & Options. | Thẻ trực quan, đầy đủ thông số hiệp, cap time, động tác. | P1 |
| **TASK-2.3** | Màn hình Tạo/Sửa Bài tập (Builder UI) | Form nhập thông tin bài: Tên, category, prepare, rest, time cap, rounds. | Validate dữ liệu chuẩn; hỗ trợ cả tạo mới và chỉnh sửa. | P0 |
| **TASK-2.4** | Quản lý Động tác trong bài | Thêm, sửa, xóa, kéo thả sắp xếp bài tập (`ReorderableListView`). | Kéo thả đổi thứ tự bài tập mượt mà, lưu DB chính xác. | P1 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [x] **TASK-2.1: Màn hình Danh mục Bài tập (Catalog UI & State)**
  - [x] Tạo `WorkoutCatalogBloc` / `Cubit` với các State: `CatalogLoading`, `CatalogLoaded`, `CatalogError`.
  - [x] Xây dựng thanh Category Filter Chips nằm ngang: "Tất cả", "EMOM", "Endurance", "Skill", "Cardio".
  - [x] Hiện thực logic lọc danh sách bài tập tương ứng khi người dùng bấm vào chip.
  - [x] Thiết kế `EmptyStateWidget` thể thao khi một danh mục chưa có bài tập nào.
  - [x] Đặt Floating Action Button "+" nổi bật để chuyển sang màn hình Builder.

- [x] **TASK-2.2: Thiết kế Thẻ Bài tập (WorkoutCard Widget)**
  - [x] Tạo widget `WorkoutCard` hiển thị:
    - Badge thể loại với màu đặc trưng riêng biệt (EMOM: Cam, Endurance: Xanh lá, Skill: Tím, Cardio: Đỏ).
    - Tên bài tập (In đậm, rõ nét).
    - Thông số tổng quan: Giới hạn thời gian (VD: `Cap: 20m` hoặc `No Cap`), Số hiệp (`5 rounds`), Số lượng động tác (`4 động tác`).
  - [x] Nút action chính: "Bắt đầu tập" (Quick Start Button) điều hướng trực tiếp sang màn hình Player.
  - [x] Nút ngôi sao yêu thích (Favorite Toggle) gọi repository cập nhật tức thì.
  - [x] Menu 3 chấm (Popup Menu): Chỉnh sửa (Edit), Nhân bản (Duplicate), Xóa (Delete) có hộp thoại xác nhận.

- [x] **TASK-2.3: Xây dựng Form Tạo / Chỉnh sửa Bài tập (Workout Builder UI)**
  - [x] Tạo `WorkoutBuilderBloc` quản lý trạng thái form tạo/chỉnh sửa.
  - [x] Thiết kế Input Tên bài tập (bắt buộc, tối thiểu 3 ký tự).
  - [x] SegmentedButton hoặc ChoiceChips chọn thể loại (`WorkoutCategory`).
  - [x] Bộ chọn thời gian chuẩn bị (Prepare Time): 5s, 10s, 15s.
  - [x] Bộ chọn thời gian nghỉ mặc định (Default Rest): 30s, 60s, 90s, 120s, 180s.
  - [x] Cài đặt Giới hạn thời gian (Time Cap): Switch bật/tắt giới hạn + Slider chọn 10, 15, 20, 30, 45, 60 phút.
  - [x] Cài đặt Số hiệp mục tiêu (Target Rounds): Bộ đếm tăng/giảm từ 1 đến 30 hiệp.

- [x] **TASK-2.4: Quản lý Danh sách Động tác (Exercise List Manager)**
  - [x] Tích hợp `ReorderableListView` cho phép kéo thả sắp xếp thứ tự động tác trong bài.
  - [x] Xây dựng Dialog / Modal BottomSheet thêm mới động tác:
    - Ô nhập Tên động tác (VD: "Kéo xà đơn - Pull-up").
    - Toggle chọn chế độ: Theo số lần (Reps) hoặc Theo thời gian giữ (Hold Seconds).
    - Ô nhập số Reps (mặc định 10) hoặc số giây Hold (VD: 20s).
    - Ghi chú kỹ thuật ngắn (tùy chọn).
  - [x] Thao tác vuốt để xóa (Dismissible) hoặc nút thùng rác xóa từng động tác.
  - [x] Nút "Lưu bài tập": Kiểm tra điều kiện bài tập phải có ít nhất 1 động tác, lưu vào SQLite và quay lại kèm SnackBar thành công.

---

### GIAI ĐOẠN 3: BỘ ĐẾM GIỜ CHUẨN XÁC & MÀN HÌNH TẬP LUYỆN (TIMER ENGINE & PLAYER) (PHASE 3)
*Mục tiêu: Xây dựng trái tim của ứng dụng - Đồng hồ đếm giờ không bị trôi thời gian do CPU throttle và giao diện tập luyện toàn màn hình trực quan từ khoảng cách 2 mét.*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 3
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-3.1** | Precision Ticker Engine | Hiện thực hóa Stream đếm giờ bằng Timestamp Delta (`DateTime.now()`). | Không trôi giây dù chạy 60 phút hay CPU bị tiết chế. | P0 |
| **TASK-3.2** | WorkoutPlayerBloc (FSM) | Máy trạng thái: `Prepare` ➔ `Work` ➔ `Rest` ➔ `Completed`. | Chuyển trạng thái chuẩn 100%, tính đúng số hiệp và thời gian. | P0 |
| **TASK-3.3** | Màn hình Tập Toàn màn hình | UI đếm giờ cỡ chữ lớn, đổi màu nền theo trạng thái Work/Rest/Prepare. | Nhìn rõ số từ 2m; hiển thị rõ số hiệp `Hiệp 3/8`. | P0 |
| **TASK-3.4** | Bảng điều khiển thao tác to bản | Nút Play/Pause lớn, Next, Back, +10s Nghỉ, Chế độ Khóa màn hình chạm. | Thao tác nhạy, không bấm nhầm khi tay ướt mồ hôi. | P1 |
| **TASK-3.5** | Widget Tiến độ & Next Up | Hiển thị tổng thời gian đã trôi qua và xem trước bài tập kế tiếp. | Người tập luôn nắm bắt được khối lượng còn lại của buổi tập. | P2 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [x] **TASK-3.1: Xây dựng High-Precision Ticker Engine (Timestamp-Delta)**
  - [x] Tạo file `lib/features/workout_player/domain/services/precision_ticker.dart`.
  - [x] Tạo hàm stream tick với chu kỳ 100ms: `Stream<DateTime> tick({Duration interval = const Duration(milliseconds: 100)})`.
  - [x] Thiết lập thuật toán tính toán thời gian thực tế:
    $$\text{remainingSeconds} = \text{targetSeconds} - \left(\frac{\text{DateTime.now()} - \text{startedAt}}{1000}\right) + \text{accumulatedPauseSeconds}$$
  - [x] Đảm bảo cơ chế tính độc lập với tốc độ callback của hệ điều hành, triệt tiêu hoàn toàn Timer Drift.

- [x] **TASK-3.2: Xây dựng WorkoutPlayerBloc (Finite State Machine)**
  - [x] Định nghĩa các States trong `workout_player_state.dart`:
    - `PlayerInitial`: Đang tải giáo án, chuẩn bị vào bài.
    - `PlayerPrepare`: Đang đếm ngược chuẩn bị (VD: 10s... 1s).
    - `PlayerWork`: Đang trong hiệp tập (hiển thị thời gian trôi qua hoặc đếm lùi thời gian hold).
    - `PlayerRest`: Đang trong thời gian nghỉ giữa hiệp.
    - `PlayerPaused`: Toàn bộ timer tạm dừng, lưu mốc thời gian pause.
    - `PlayerCompleted`: Hoàn thành toàn bộ số hiệp hoặc chạm Time Cap.
  - [x] Định nghĩa các Events trong `workout_player_event.dart`:
    - `StartWorkoutEvent(WorkoutTemplateModel workout)`
    - `TimerTickEvent(DateTime currentTime)`
    - `PauseWorkoutEvent()` & `ResumeWorkoutEvent()`
    - `SkipNextEvent()` (chuyển sang nghỉ hoặc bài tiếp theo)
    - `PreviousStepEvent()` (quay lại bài hoặc hiệp trước)
    - `AddRestTimeEvent(int additionalSeconds)` (cộng thêm 10s/30s nghỉ)
    - `FinishWorkoutEarlyEvent()` (kết thúc sớm có chủ đích)
  - [x] Xử lý logic chuyển đổi trạng thái tuần tự và chuyển round trong `WorkoutPlayerBloc`.

- [x] **TASK-3.3: Màn hình Tập luyện Toàn màn hình (Player Screen UI)**
  - [x] Tạo `WorkoutPlayerScreen` với giao diện Fullscreen đắm chìm (Immersive mode).
  - [x] Áp dụng hiệu ứng đổi màu nền động theo trạng thái:
    - Khi Work: Nền đen ánh xanh lá `#0D2818` với đường viền / accent `#00E676` (hoặc Cam `#FF6D00` cho EMOM).
    - Khi Rest: Nền đen ánh xanh dương `#0A192F` với accent `#2979FF`.
    - Khi Prepare: Nền đen ánh vàng `#2A2605` với accent `#FFD600`.
  - [x] Hiển thị đồng hồ đếm số khổng lồ (Format `mm:ss`), chiều cao tối thiểu 90sp sử dụng Monospace Font.
  - [x] Hiển thị thông tin bài tập hiện tại: Tên động tác, Số reps cần hoàn thành (hoặc số giây hold).
  - [x] Hiển thị tiến độ hiệp tập: `HIỆP 3 / 8` (chữ to, dễ đọc).

- [x] **TASK-3.4: Bảng Điều Khiển Cảm Ứng & Khóa Chạm (Touch Controls & Screen Lock)**
  - [x] Thiết kế nút Play/Pause kích thước lớn (tối thiểu 76x76px) nằm ở trung tâm tầm tay người dùng.
  - [x] Nút "Bỏ qua / Xong hiệp" (Next) và "Quay lại" (Previous) to bản.
  - [x] Nút "+10s Nghỉ" và "+30s Nghỉ" (chỉ hiển thị và sáng lên khi trạng thái là `PlayerRest`).
  - [x] Tính năng Khóa Màn Hình (Screen Lock Mode):
    - [x] Nút biểu tượng ổ khóa ở góc màn hình.
    - [x] Khi bật: Vô hiệu hóa toàn bộ các nút bấm và cử chỉ chạm (tránh mồ hôi rơi trúng màn hình làm nhảy bài).
    - [x] Mở khóa bằng cơ chế giữ 2 giây: `GestureDetector.onLongPress` kèm animation tròn đếm mở khóa.

- [x] **TASK-3.5: Widget Tiến Độ Tổng Thể & Thẻ Xem Trước "Next Up"**
  - [x] Thanh ProgressBar mảnh trên cùng thể hiện tổng thời lượng đã tập so với Time Cap.
  - [x] Thẻ "Next Up" ở cạnh dưới: Hiển thị tên động tác tiếp theo và số reps (giúp người tập chuẩn bị tinh thần và dụng cụ xà/tạ trước khi hết giờ nghỉ).

---

### GIAI ĐOẠN 4: HỆ THỐNG GIỌNG NÓI THÔNG MINH (TTS) & ÂM THANH (AUDIO COACH) (PHASE 4)
*Mục tiêu: Tích hợp giọng đọc huấn luyện viên tiếng Việt/tiếng Anh và còi hiệu thể thao, giúp người tập không cần nhìn vào màn hình điện thoại.*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 4
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-4.1** | Tích hợp SFX & Assets âm thanh | Thêm audio files chuẩn, khởi tạo `audioplayers` với độ trễ thấp. | Âm thanh phát ngay tức thì (latency < 50ms). | P0 |
| **TASK-4.2** | Giọng đọc ảo (Flutter TTS) | Xây dựng `TtsService`: hỗ trợ Tiếng Việt (`vi-VN`), Tiếng Anh (`en-US`). | Giọng đọc tự nhiên, phát âm chuẩn tên bài tập và số giây. | P0 |
| **TASK-4.3** | Bộ điều phối Âm thanh (AudioCueManager) | Lắng nghe BLoC để tự động kích hoạt Voice & Beep đúng thời điểm. | Hoạt động mượt mà, không overlap giữa giọng nói và tiếng còi. | P0 |
| **TASK-4.4** | Audio Focus & Ducking | Cấu hình `audio_session`: tự động giảm nhạc nền khi có giọng đọc Hamino. | Trải nghiệm vừa nghe Spotify vừa nhận khẩu lệnh rõ ràng. | P1 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [ ] **TASK-4.1: Tích hợp SFX & Kho File Âm Thanh Thể Thao**
  - [ ] Chuẩn bị các file âm thanh chất lượng cao đặt trong `assets/audio/`:
    - `beep_short.wav` (tiếng bíp nhẹ cho chuẩn bị)
    - `beep_high.wav` (tiếng bíp cao độ đếm 3, 2, 1)
    - `whistle_start.wav` (tiếng còi thể thao bắt đầu hiệp)
    - `rest_chime.wav` (âm chuông nhẹ báo vào giờ nghỉ)
    - `victory_fanfare.wav` (âm thanh chúc mừng hoàn thành bài tập)
  - [ ] Tạo file `lib/core/services/audio_sfx_service.dart` quản lý `AudioPlayer`.
  - [ ] Thực hiện pre-cache (tải trước) toàn bộ file âm thanh vào bộ nhớ khi app khởi động để đảm bảo độ trễ phát dưới 50ms.

- [ ] **TASK-4.2: Tích hợp Dịch vụ Giọng Nói Trợ Lý Ảo (TtsService)**
  - [ ] Tạo file `lib/core/services/tts_service.dart` bọc thư viện `flutter_tts`.
  - [ ] Cấu hình tham số đọc chuẩn thể thao:
    - Hỗ trợ ngôn ngữ: `vi-VN` (Tiếng Việt) và `en-US` (Tiếng Anh).
    - `speechRate: 0.52` (tốc độ đọc vừa phải, dứt khoát).
    - `pitch: 1.0` (cao độ tự nhiên, rõ ràng).
  - [ ] Viết hàm `speak(String text, {bool awaitCompletion = false})` và `stop()`.
  - [ ] Xử lý fallback an toàn: Nếu máy chưa tải gói giọng đọc tiếng Việt thì tự động fallback tiếng Anh hoặc chuyển sang chỉ dùng âm SFX.

- [ ] **TASK-4.3: Xây dựng Bộ Điều Phối Âm Thanh (AudioCueManager)**
  - [ ] Tạo class `AudioCueManager` lắng nghe State Stream từ `WorkoutPlayerBloc`.
  - [ ] Định nghĩa các quy tắc kích hoạt âm thanh tự động:
    - [ ] **Bắt đầu chuẩn bị:** Đọc: *"Chuẩn bị: [Tên bài tập]"*.
    - [ ] **Đếm ngược 3 giây cuối:** Phát `beep_high` ở các giây 3, 2, 1 (hoặc đọc *"Ba, Hai, Một"*).
    - [ ] **Bắt đầu hiệp (0s):** Phát `whistle_start` + đọc *"Bắt đầu!"* hoặc *"Hiệp [X], Bắt đầu!"*.
    - [ ] **Chuyển sang nghỉ (Rest):** Phát `rest_chime` + đọc *"Nghỉ [Y] giây"*.
    - [ ] **Nhắc nhở sắp hết giờ nghỉ:** Khi còn đúng 10 giây nghỉ, phát tiếng bíp nhẹ + đọc *"Còn 10 giây, chuẩn bị [Bài kế tiếp]"*.
    - [ ] **Hoàn thành bài tập:** Phát `victory_fanfare` + đọc *"Chúc mừng bạn đã hoàn thành bài tập xuất sắc!"*.
  - [ ] Thiết lập logic chống chồng lấn (No Overlap): Nếu TTS đang đọc thì tạm dừng âm SFX phụ hoặc đợi dứt câu.

- [ ] **TASK-4.4: Cấu hình Quản Lý Audio Focus & Ducking**
  - [ ] Tạo `lib/core/services/audio_focus_service.dart` sử dụng `audio_session`.
  - [ ] Cấu hình Android Audio Attributes: `contentType = speech`, `usage = assistant`.
  - [ ] Thiết lập `AudioSessionCategory.playback` với tùy chọn `duckOthers`:
    - Khi Hamino Workout phát tiếng nói, âm lượng nhạc từ các app khác (Spotify, Zing MP3, Apple Music) tự động giảm xuống 25%.
    - Khi giọng đọc kết thúc, âm lượng nhạc nền tự động phục hồi về 100%.

---

### GIAI ĐOẠN 5: WAKELOCK, CHẠY NỀN & LỊCH SỬ TẬP LUYỆN (PHASE 5)
*Mục tiêu: Đảm bảo màn hình không bị tắt khi tập, hỗ trợ hiển thị đếm giờ khi ra ngoài màn hình và ghi lại nhật ký kết quả buổi tập.*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 5
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-5.1** | Giữ sáng màn hình (Wakelock) | Tích hợp `wakelock_plus` tự động kích hoạt khi vào màn hình Player. | Màn hình luôn sáng trong suốt buổi tập, không bị sleep. | P0 |
| **TASK-5.2** | Màn hình Tóm tắt Buổi tập | Sau khi hoàn thành: hiển thị thời gian, số hiệp, chấm điểm RPE, ghi chú. | Bấm "Lưu kết quả" ghi dữ liệu vào bảng `workout_sessions`. | P0 |
| **TASK-5.3** | Màn hình Lịch sử & Thống kê | Hiển thị Timeline các buổi tập đã qua và tổng hợp số buổi trong tuần. | Xem lại chi tiết từng buổi tập dễ dàng, nhanh chóng. | P1 |
| **TASK-5.4** | Thông báo Chạy nền (Notification) | Hiển thị thông báo trạng thái timer khi chuyển app hoặc tắt màn hình. | Notification ngoài màn hình khóa cập nhật đúng số giây. | P2 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [ ] **TASK-5.1: Tích hợp Giữ Sáng Màn Hình (Wakelock Service)**
  - [ ] Tạo file `lib/core/services/wakelock_service.dart` bọc `wakelock_plus`.
  - [ ] Gọi `WakelockPlus.enable()` tự động khi `WorkoutPlayerScreen` được khởi tạo (`initState`).
  - [ ] Gọi `WakelockPlus.disable()` khi người dùng thoát hoặc hoàn thành bài tập (`dispose`).
  - [ ] Bổ sung cờ cấu hình trong Settings cho phép người dùng tắt tính năng này nếu muốn tiết kiệm pin tối đa.

- [ ] **TASK-5.2: Màn hình Tổng Kết Buổi Tập (Workout Summary Screen)**
  - [ ] Tạo `WorkoutSummaryScreen` tự động mở ra khi BLoC chuyển trạng thái `PlayerCompleted` hoặc người dùng xác nhận dừng sớm.
  - [ ] Hiển thị thông số tổng kết nổi bật:
    - Tổng thời gian tập luyện thực tế (Format: `X phút Y giây`).
    - Số hiệp đã hoàn thành trên tổng số hiệp mục tiêu (VD: `8 / 8 Hiệp - 100%`).
  - [ ] Bảng đánh giá độ khó buổi tập (RPE Scale từ 1 đến 10) bằng Slider hoặc 5 biểu tượng trạng thái sức lực.
  - [ ] Ô nhập nhật ký ngắn (Personal Notes: cảm giác cơ bắp, mức tạ, số rep tối đa đạt được).
  - [ ] Nút "Lưu kết quả": Tạo bản ghi `WorkoutSessionRecordModel`, lưu vào SQLite và điều hướng về trang chủ kèm hiệu ứng chúc mừng.

- [ ] **TASK-5.3: Màn hình Lịch Sử & Nhật Ký Tập Luyện (History & Stats Screen)**
  - [ ] Tạo `HistoryBloc` truy vấn bảng `workout_sessions` từ database.
  - [ ] Xây dựng giao diện Timeline lịch sử tập luyện xếp theo ngày mới nhất.
  - [ ] Thiết kế `HistorySessionCard` hiển thị: Tên bài tập, Thể loại, Thời gian hoàn thành, Điểm đánh giá RPE.
  - [ ] Thẻ thống kê nhanh trên đầu trang: "Tổng số buổi tuần này", "Tổng thời lượng vận động (phút)".
  - [ ] Modal xem lại chi tiết bài tập cũ và nút xóa bản ghi lịch sử nếu muốn.

- [ ] **TASK-5.4: Thông Báo Trạng Thái Chạy Nền (Ongoing Timer Notification)**
  - [ ] Tạo file `lib/core/services/notification_service.dart` sử dụng `flutter_local_notifications`.
  - [ ] Cấu hình Notification Channel thể thao độ ưu tiên cao (`importance: max`, `ongoing: true`).
  - [ ] Lắng nghe BLoC: Khi người dùng nhấn nút Home hoặc chuyển app, cập nhật notification hiển thị:
    - Tiêu đề: Tên bài tập + Tên động tác hiện tại.
    - Nội dung: `[ĐANG TẬP] Còn 25s` hoặc `[ĐANG NGHỈ] Còn 45s (Hiệp 3/8)`.
  - [ ] Thêm nút hành động nhanh (Action Buttons) ngay trên notification: Tạm dừng / Tiếp tục.
  - [ ] Tự động hủy notification khi buổi tập hoàn thành hoặc bị hủy bỏ.

---

### GIAI ĐOẠN 6: CÀI ĐẶT HỆ THỐNG, KIỂM THỬ, TỐI ƯU & HOÀN THIỆN (PHASE 6)
*Mục tiêu: Cung cấp màn hình cài đặt tùy biến, viết kiểm thử tự động cho Timer BLoC, tối ưu hiệu năng tiêu thụ pin và đóng gói ứng dụng.*

#### Bảng Tóm Tắt Nhiệm Vụ Phase 6
| Mã Task | Tên Nhiệm Vụ | Nội Dung Thực Hiện | Tiêu Chí Nghiệm Thu | Ưu Tiên |
| :--- | :--- | :--- | :--- | :--- |
| **TASK-6.1** | Màn hình Cài đặt (Settings) | Cung cấp các công tắc bật/tắt TTS, SFX, chọn ngôn ngữ, tốc độ đọc. | Cài đặt lưu vào `SharedPreferences`, áp dụng ngay. | P1 |
| **TASK-6.2** | Unit Test Timer Engine & BLoC | Viết kiểm thử cho `PrecisionTicker`, máy trạng thái BLoC và SQLite. | 100% test cases timer và state transition pass. | P0 |
| **TASK-6.3** | Tối ưu Hiệu năng & Tiết kiệm Pin | Tối ưu repaint boundary, hủy triệt để stream subscription. | CPU dưới 5% khi đếm giờ, máy mát mẻ khi tập lâu. | P1 |
| **TASK-6.4** | Hoàn thiện Tài liệu & Đóng gói | Cập nhật `README.md`, icon ứng dụng, splash screen, build release. | Ứng dụng sẵn sàng chạy mượt mà trên Android và iOS. | P2 |

#### Checklist Chi Tiết Thực Hiện (Action Items)
- [ ] **TASK-6.1: Xây dựng Màn hình Cài đặt Hệ thống (Settings Screen)**
  - [ ] Tạo `SettingsCubit` và `SettingsState` lưu trữ trạng thái vào `SharedPreferences`.
  - [ ] Nhóm Cài đặt Âm thanh & Huấn Luyện Viên:
    - [ ] Switch: Bật / Tắt Giọng đọc Trợ lý ảo (TTS Voice Assistant).
    - [ ] Lựa chọn ngôn ngữ: Radio chọn `Tiếng Việt` hoặc `English`.
    - [ ] Slider: Tốc độ giọng đọc (Speech Rate) từ 0.3x đến 1.0x kèm nút "Nghe thử mẫu".
    - [ ] Switch: Bật / Tắt Hiệu ứng âm thanh còi & tiếng bíp (SFX).
    - [ ] Switch: Tự động giảm âm lượng nhạc ngoài (Audio Ducking).
  - [ ] Nhóm Cài đặt Màn hình & Pin:
    - [ ] Switch: Luôn sáng màn hình trong lúc tập (Wakelock).
    - [ ] Lựa chọn thời gian đếm chuẩn bị mặc định (5s / 10s / 15s).
  - [ ] Mục Giới thiệu: Hiển thị Phiên bản ứng dụng (`v1.0.0`), lời cảm ơn cộng đồng Calisthenics.

- [ ] **TASK-6.2: Viết Kiểm Thử Tự Động (Unit Test & BLoC Test)**
  - [ ] Tạo `test/features/workout_player/precision_ticker_test.dart`:
    - Kiểm tra `PrecisionTicker` đếm đúng chu kỳ và không bị lệch thời gian khi delay luồng.
  - [ ] Tạo `test/features/workout_player/workout_player_bloc_test.dart`:
    - Kiểm tra chu trình chuyển trạng thái: `Prepare` ➔ `Work` ➔ `Rest` ➔ `Completed`.
    - Kiểm tra sự kiện `Pause` và `Resume` không làm sai lệch số giây còn lại.
    - Kiểm tra sự kiện `AddRestTimeEvent` cộng thêm đúng 10s/30s vào thời gian nghỉ hiện tại.
  - [ ] Tạo `test/features/workout_builder/workout_repository_test.dart`:
    - Kiểm tra các hàm CRUD thêm, sửa, xóa, lấy danh sách bài tập bằng cơ sở dữ liệu SQLite in-memory (`sqflite_common_ffi`).

- [ ] **TASK-6.3: Tối ưu Hiệu Năng & Tiêu Thụ Pin (Battery & Performance Optimization)**
  - [ ] Tối ưu hóa Rebuild cây Widget:
    - Đặt `RepaintBoundary` bao quanh widget đồng hồ số.
    - Sử dụng `buildWhen` trong `BlocBuilder` để chỉ build lại duy nhất Text đồng hồ khi số giây thay đổi, giữ nguyên phần còn lại của giao diện.
  - [ ] Quản lý bộ nhớ (Memory Leak Check):
    - Kiểm tra toàn bộ `StreamSubscription`, `AnimationController`, `TextEditingController` được đóng trong `dispose()`.
  - [ ] Đo lường hiệu năng bằng Flutter DevTools: Đảm bảo app duy trì 60 FPS mượt mà và mức sử dụng CPU tối thiểu.

- [ ] **TASK-6.4: Đóng Gói Ứng Dụng & Hoàn Thiện Tài Liệu Bàn Giao**
  - [ ] Thiết kế và tạo Icon ứng dụng thể thao phong cách Calisthenics bằng `flutter_launcher_icons`.
  - [ ] Cấu hình Splash Screen nền đen với logo Hamino bằng `flutter_native_splash`.
  - [ ] Cập nhật toàn bộ `README.md` của dự án:
    - Giới thiệu tổng quan tính năng.
    - Hướng dẫn clone mã nguồn và chạy lệnh `flutter run`.
    - Hướng dẫn build Release APK (`flutter build apk --release`) và iOS Bundle.
  - [ ] Bàn giao sản phẩm hoàn chỉnh theo đúng tiêu chuẩn đề ra trong `PRD.md` và `TECH_ARCHITECTURE.md`.

---

## 4. QUY TRÌNH THỰC THI & KIỂM TRA MỖI PHASE (EXECUTION WORKFLOW)

Khi tiến hành code từng Phase, lập trình viên hoặc AI Agent cần tuân theo quy trình chuẩn sau:

1. **Bắt đầu Phase:** Đọc lại các tiêu chí nghiệm thu của Phase đó trong bảng tóm tắt và danh sách checklist.
2. **Thực thi tuần tự:** Làm từng checklist item từ trên xuống dưới, hoàn thành đến đâu đánh dấu `[x]` vào file `docs/PLAN.md`.
3. **Kiểm tra cục bộ (Local Verification):**
   - Chạy `flutter analyze` để đảm bảo code sạch, không warning/error.
   - Chạy `flutter test` nếu Phase đó có unit tests.
4. **Nghiệm thu Phase:** Đối chiếu với tiêu chí nghiệm thu (Acceptance Criteria), đảm bảo ứng dụng chạy ổn định trước khi chuyển sang Phase tiếp theo.
