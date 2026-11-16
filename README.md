# Hamino Workout - Ứng Dụng Bấm Giờ & Quản Lý Giáo Án Calisthenics Chuyên Nghiệp

<p align="center">
  <img src="assets/icons/hamino_logo.png" width="120" alt="Hamino Workout Logo" />
</p>

<p align="center">
  <b>Calisthenics Precision Training • Sets & Reps • EMOM • TABATA • Smart Audio Coach</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-00E676" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/State%20Management-BLoC-blue" alt="BLoC" />
  <img src="https://img.shields.io/badge/Database-SQLite%20(sqflite)-4169E1" alt="SQLite" />
  <img src="https://img.shields.io/badge/AI%20Powered-Gemini%20API-FF6D00" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/Tests-134%20Passed%20(100%25)-success" alt="Tests" />
</p>

---

## 1. Giới Thiệu Dự Án (Overview)

**Hamino Workout** là ứng dụng di động mã nguồn mở được thiết kế và tối ưu hoá chuyên biệt cho cộng đồng tập luyện thể thao đường phố (**Calisthenics & Street Workout**). 

Khác với các ứng dụng đếm giờ thông thường vốn chỉ hỗ trợ các khoảng thời gian cố định, Hamino Workout giải quyết triệt để các bài toán đặc thù của người tập xà đơn, xà kép:
- **Động tác linh hoạt:** Hỗ trợ kết hợp nhuần nhuyễn cả động tác tính theo **Số lần (Reps)** lẫn động tác **Giữ tĩnh (Static Hold/Seconds)** trong cùng một buổi tập.
- **Đa dạng thể thức:** Hỗ trợ đầy đủ các thể thức tập luyện phổ biến nhất: **Sets & Reps (Endurance)**, **EMOM (Every Minute on the Minute)**, **TABATA (HIIT)**, **AMRAP** và các bài tập kỹ năng (**Skill Work**).
- **Trợ lý ảo & Âm thanh thực chiến:** Giọng đọc Huấn luyện viên thông minh (TTS - Text-to-Speech) phát khẩu lệnh, còi hiệu SFX độ trễ thấp (< 50ms), tự động giảm âm lượng nhạc ngoài (Audio Ducking) khi phát tín hiệu.
- **Nhập giáo án nhanh bằng Gemini AI:** Dán văn bản bài tập thô bất kỳ từ ghi chú, hội nhóm Facebook hoặc tin nhắn để AI tự động trích xuất và tạo giáo án chuẩn xác.
- **Trải nghiệm tập luyện không gián đoạn:** Màn hình tập toàn màn hình tương phản cao, khoá cảm ứng tránh chạm nhầm mồ hôi, giữ sáng màn hình (Wakelock), thông báo đếm giờ nền và nhật ký lịch sử tập luyện SQLite.

---

## 2. Kiến Trúc Hệ Thống (Architecture)

Dự án áp dụng chặt chẽ mô hình **Clean Architecture** kết hợp phương pháp quản lý trạng thái **BLoC / Cubit** (Business Logic Component) nhằm đảm bảo tính phân tách độc lập giữa các tầng, dễ mở rộng và dễ kiểm thử tự động (100% Test Coverage):

```
lib/
├── core/                       # Thành phần dùng chung (Core & Foundation)
│   ├── constants/              # Hằng số hệ thống, DbConstants, AppConstants
│   ├── database/               # DatabaseHelper (SQLite), Seed Data (4 Presets)
│   ├── di/                     # Service Locator toàn cục (GetIt Dependency Injection)
│   ├── error/                  # Failures & Exceptions định danh
│   ├── services/               # SFX Service, TTS Service, AudioFocus, Wakelock, Notifications, Gemini
│   ├── theme/                  # Neon Calisthenics Dark Theme, Typography, Colors
│   └── utils/                  # TimeFormatter, DateFormatter
├── features/
│   ├── workout_builder/        # Quản lý giáo án, CRUD bài tập, Gemini AI Import
│   │   ├── data/               # Models, SQLite Repositories
│   │   ├── domain/             # Entities (WorkoutTemplate, Exercise), Repositories
│   │   └── presentation/       # BLoC, Catalog Page, Builder Page, Widgets
│   ├── workout_player/         # Động cơ đếm giờ độ chính xác cao & Màn hình tập luyện
│   │   ├── domain/services/    # PrecisionTicker (Triệt tiêu timer drift)
│   │   └── presentation/       # WorkoutPlayerBloc FSM, Immersive Player Page, RepaintBoundary
│   ├── history/                # Nhật ký buổi tập, Đánh giá RPE & Thống kê
│   │   ├── data/               # WorkoutSessionRecordModel, LocalDataSource
│   │   ├── domain/             # HistoryRepository
│   │   └── presentation/       # HistoryBloc, WorkoutSummaryPage, HistoryPage
│   └── settings/               # Cài đặt âm thanh, TTS, Wakelock, chuẩn bị mặc định
│       ├── data/               # SharedPreferences LocalDataSource
│       ├── domain/             # UserSettingsEntity, SettingsRepository
│       └── presentation/       # SettingsCubit, SettingsPage
└── main.dart                   # Điểm khởi chạy ứng dụng & Thiết lập cấu hình hệ thống
```

---

## 3. Các Tính Năng Nổi Bật Qua 6 Giai Đoạn (Key Features)

### 3.1. Thư Viện Giáo Án & Cơ Sở Dữ Liệu SQLite (Phase 1)
- Cơ sở dữ liệu SQLite cục bộ được mã hóa cấu trúc chặt chẽ với cơ chế toàn vẹn dữ liệu khoá ngoại (`ON DELETE CASCADE`) và giao dịch an toàn (`Transaction`).
- Sẵn sàng với **4 bộ giáo án Calisthenics chuẩn** ngay khi khởi động app:
  1. *Full Body Basics (Endurance Sets & Reps)*
  2. *EMOM Pull-up & Dip Power (10 Phút)*
  3. *Core & Front Lever Foundation (Static Holds)*
  4. *Tabata Fat Burner (Cardio HIIT)*

### 3.2. Quản Lý Giáo Án & Trợ Lý Trí Tuệ Nhân Tạo Gemini (Phase 2)
- Trình tạo bài tập trực quan: Đổi tên, phân loại, sắp xếp thứ tự động tác bằng kéo thả (`ReorderableListView`), cấu hình số hiệp (`Target Rounds`), thời gian nghỉ mặc định (`Default Rest`) và giới hạn thời gian (`Time Cap`).
- **Gemini AI Workout Importer:** Tự động phân tích các dòng văn bản tự do, nhận diện bài tập Reps hoặc Hold và đưa vào trình chỉnh sửa chỉ trong 1 chạm.

### 3.3. Động Cơ Đếm Giờ & Màn Hình Tập Toàn Màn Hình (Phase 3)
- Máy trạng thái hữu hạn (**FSM WorkoutPlayerBloc**): `Prepare` ➔ `Work` ➔ `Rest` ➔ `Completed`.
- **PrecisionTicker:** Đo đếm theo mốc thời gian tuyệt đối (`DateTime.now()`), không bị ảnh hưởng bởi hiện tượng trôi giờ do CPU tiết kiệm pin.
- Giao diện Neon Dark Mode tương phản cao: Đồng hồ hiển thị siêu lớn (`90sp`), màu nền đổi động theo trạng thái (Vàng chuẩn bị, Xanh lá tập luyện, Xanh dương nghỉ ngơi).
- Tính năng mở rộng: Cộng thêm `+10s` / `+30s` nghỉ tức thì, Khóa cảm ứng chống chạm nhầm (`Screen Lock Overlay`).

### 3.4. Huấn Luyện Viên Giọng Nói & Âm Thanh Thể Thao (Phase 4)
- **SFX Engine độ trễ thấp (< 50ms):** Sử dụng các luồng âm thanh chuyên biệt nạp sẵn vào RAM cho còi xuất phát, tiếng bíp đếm ngược 3-2-1, chuông báo nghỉ và khúc nhạc chiến thắng.
- **Trợ lý đọc khẩu lệnh Text-to-Speech:** Hỗ trợ Tiếng Việt và Tiếng Anh.
- **Audio Ducking Focus:** Tự động hạ âm lượng các ứng dụng phát nhạc nền (Spotify, Apple Music, Zing MP3) khi có khẩu lệnh và tự phục hồi âm lượng ngay khi đọc xong.

### 3.5. Màn Hình Tổng Kết, Lịch Sử & Chạy Nền (Phase 5)
- **Workout Summary:** Tổng kết số hiệp hoàn thành, tỷ lệ đạt được, tổng thời lượng thực tế, chấm điểm thể lực theo thang đo **RPE Scale (1 - 10)** và ghi chép cảm nhận cơ bắp.
- **History Timeline & Stats:** Theo dõi tiến độ tập luyện theo dòng thời gian, thẻ thống kê nhanh tổng số buổi trong tuần và tổng số phút vận động.
- **Dịch vụ phần cứng:** Giữ sáng màn hình (`WakelockPlus`), thông báo trạng thái bài tập liên tục (`Ongoing Notification`) khi người dùng ẩn app.

### 3.6. Cài Đặt Hệ Thống, Tối Ưu Hiệu Năng & Đóng Gói (Phase 6)
- **Màn hình Cài đặt Hệ thống (Settings):** Tùy chỉnh bật/tắt TTS, SFX, Audio Ducking, chọn ngôn ngữ (Tiếng Việt/English), điều chỉnh tốc độ đọc kèm nút "Nghe thử mẫu", tùy chọn thời gian đếm chuẩn bị (5s/10s/15s) và cờ Wakelock.
- **Tối ưu hiệu năng:** Đặt đồng hồ số trong `RepaintBoundary` và lọc render bằng `buildWhen` trong BLoC, giúp CPU duy trì dưới 5% và ứng dụng mượt mà 60 FPS.
- Cấu hình Icon thể thao chuẩn Calisthenics bằng `flutter_launcher_icons` và Splash Screen nền tối sang trọng bằng `flutter_native_splash`.

---

## 4. Hướng Dẫn Cài Đặt & Chạy Ứng Dụng (Getting Started)

### Yêu Cầu Môi Trường
- Flutter SDK: `^3.13.0` trở lên (Đã kiểm thử và chạy ổn định trên Flutter 3.47.5 / Dart 3.13.4).
- Android Studio / VS Code / IntelliJ IDEA.
- Thiết bị Android (API 21+) hoặc iOS (iOS 12+), hoặc máy ảo Android Emulator / iOS Simulator.

### Các Bước Thực Hiện

1. **Clone repository về máy tính:**
   ```bash
   git clone https://github.com/your-username/hamino_app.git
   cd hamino_app
   ```

2. **Cài đặt các thư viện phụ thuộc:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng ở chế độ Debug:**
   ```bash
   flutter run
   ```

*(Tùy chọn) Cấu hình Gemini API Key để sử dụng tính năng AI Import:*
- Bạn có thể nhập trực tiếp Gemini API Key của mình ngay trong giao diện AI Import Bottom Sheet. Key sẽ được lưu an toàn vào `SharedPreferences` của thiết bị.

---

## 5. Hướng Dẫn Kiểm Thử Tự Động (Testing & Quality Assurance)

Dự án sở hữu bộ test toàn diện với **134 Unit, Bloc và Widget Tests**:

```bash
# Kiểm tra phân tích tĩnh mã nguồn (Static Code Analysis)
flutter analyze

# Chạy toàn bộ 134 Unit Tests & Widget Tests
flutter test

# Chạy riêng nhóm kiểm thử Timer & Workout Player
flutter test test/features/workout_player/

# Chạy riêng nhóm kiểm thử Cài đặt hệ thống
flutter test test/features/settings/
```

---

## 6. Hướng Dẫn Đóng Gói Ứng Dụng (Build Release)

### Tạo App Icons & Splash Screen (Nếu có thay đổi tài nguyên ảnh)
```bash
# Sinh App Icon cho Android và iOS
dart run flutter_launcher_icons

# Sinh Splash Screen nền đen chuẩn phong cách Hamino
dart run flutter_native_splash:create
```

### Build Bản Release Cho Android (APK / App Bundle)
```bash
# Build file Release APK độc lập:
flutter build apk --release

# File APK hoàn chỉnh sẽ nằm tại:
# build/app/outputs/flutter-apk/app-release.apk

# Build định dạng Android App Bundle (.aab) để phát hành lên Google Play:
flutter build appbundle --release
```

### Build Bản Release Cho iOS
```bash
flutter build ipa --release
```

---

## 7. Giấy Phép & Lời Tri Ân (License & Credits)

- Phát triển với niềm đam mê dành cho cộng đồng **Calisthenics & Street Workout**.
- Giấy phép: MIT License. Mọi đóng góp (Pull Request, Issue) đều được chào đón nồng nhiệt!
