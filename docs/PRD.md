# TÀI LIỆU YÊU CẦU SẢN PHẨM (PRD)
## DỰ ÁN: HAMINO WORKOUT - CHUYÊN BIỆT CHO CALISTHENICS & STREET WORKOUT

---

| Thông Tin Tài Liệu | Giá Trị |
| :--- | :--- |
| **Tên sản phẩm** | Hamino Workout |
| **Phiên bản** | 1.0.0 (Giai đoạn MVP & Mở rộng) |
| **Nền tảng** | Mobile (iOS & Android) - Xây dựng trên Flutter |
| **Mục tiêu chính** | Ứng dụng hỗ trợ tập luyện Calisthenics đa năng với bộ đếm giờ thông minh (EMOM, Endurance, Skill, Cardio) và trợ lý giọng nói sống động |
| **Ngày cập nhật** | 10/11/2026 |

---

## 1. TỔNG QUAN SẢN PHẨM (PRODUCT OVERVIEW)

### 1.1. Bối cảnh & Vấn đề (Problem Statement)
Người tập **Calisthenics (thể hình đường phố / trọng lượng cơ thể)** thường gặp các rào cản khi theo dõi buổi tập:
1. **Đặc thù bài tập đa dạng:** Calisthenics không chỉ là tập gym tính rep thông thường, mà đòi hỏi nhiều phương pháp huấn luyện đặc thù như:
   - **EMOM (Every Minute on the Minute):** Tập n rep trong 1 phút, thời gian còn lại nghỉ, lặp lại qua nhiều phút.
   - **ENDURANCE:** Tập chuỗi động tác cường độ cao, số rep lớn (high-volume sets), tính tổng hiệp và thời gian duy trì liên tục.
   - **SKILL:** Giữ tư thế (Isometric hold như Handstand, Planche, Front Lever, Muscle-up) cần bấm giờ hold và thời gian nghỉ phục hồi thần kinh chuẩn xác (2 - 5 phút).
   - **CARDIO / HIIT:** Nhịp tim cao, tỷ lệ tập/nghỉ ngắn (ví dụ: Tabata 20s tập / 10s nghỉ).
2. **Bất tiện khi thao tác bấm máy trong lúc tập:** Tay dính mồ hôi, đeo bao tay hoặc đang treo xà/chống tay không thể liên tục chạm vào màn hình điện thoại để bấm dừng, bấm nghỉ hoặc bấm hiệp tiếp theo.
3. **Các ứng dụng hiện tại trên thị trường:** Hoặc là quá phức tạp chuyên cho gym tạ, hoặc các ứng dụng đếm giờ (Interval Timer) quá đơn sơ, không hỗ trợ giọng đọc tiếng Việt rõ ràng hoặc không cho phép tùy biến cấu trúc bài tập Calisthenics chuyên sâu.

### 1.2. Tầm nhìn & Giải pháp (Vision & Solution)
**Hamino Workout** là người bạn đồng hành số 1 cho cộng đồng Calisthenics:
- Cho phép người dùng dễ dàng tạo, tùy chỉnh và lưu các giáo án bài tập theo từng thể loại chuyên biệt.
- Hệ thống đếm giờ cực kỳ chính xác và linh hoạt (Work time, Rest time, Round/Set counter, Cap time 10/20/60 phút).
- **Trợ lý âm thanh & Giọng nói thông minh (Audio Coach & TTS):** Đọc to tên bài tập, hướng dẫn bắt đầu, đếm ngược chuyển trạng thái, thông báo hết hiệp và thời gian nghỉ mà người dùng **không cần nhìn vào màn hình điện thoại**.

---

## 2. CHÂN DUNG NGƯỜI DÙNG MỤC TIÊU (TARGET AUDIENCE & PERSONAS)

### Persona 1: Tuấn - Calisthenics Intermediate (24 tuổi)
- **Mục tiêu:** Tăng thể lực và sức bền thông qua các chuỗi bài tập EMOM và Endurance (Pull-ups, Dips, Push-ups).
- **Nhu cầu:** Cần một ứng dụng cài đặt nhanh một bài EMOM 20 phút (mỗi phút 10 Pull-ups), có giọng đọc thông báo phút tiếp theo và đếm ngược 3-2-1 trước khi bước vào phút mới.

### Persona 2: Hoàng - Calisthenics Skill Seeker (28 tuổi)
- **Mục tiêu:** Chinh phục Front Lever và Handstand.
- **Nhu cầu:** Cần bấm giờ giữ (hold time) 8 giây, sau đó tự động chuyển sang nghỉ đúng 180 giây, hết 180 giây giọng nói nhắc "Bắt đầu hiệp tiếp theo", đếm đủ 5 hiệp rồi kết thúc.

### Persona 3: Lan - Fitness & Cardio Enthusiast (22 tuổi)
- **Mục tiêu:** Giảm mỡ và đốt năng lượng với các bài tập Bodyweight HIIT/Cardio.
- **Nhu cầu:** Chọn các bài tập cardio 15-30 phút với nhịp độ nhanh, đếm số vòng (rounds), âm thanh thúc đẩy năng lượng.

---

## 3. CÁC THỂ LOẠI BÀI TẬP CỐT LÕI (CORE WORKOUT MODES)

| Thể Loại | Định Nghĩa & Cơ Chế | Thuộc Tính Cài Đặt Chính |
| :--- | :--- | :--- |
| **EMOM**<br>*(Every Minute on the Minute)* | Mỗi phút người tập hoàn thành số rep quy định. Thời gian còn lại của phút đó là thời gian nghỉ. Khi đồng hồ điểm sang phút tiếp theo, hiệp mới lập tức bắt đầu. | - Tổng thời gian (ví dụ: 10, 20, 30 phút)<br>- Chu kỳ phút (1 phút, 2 phút/hiệp)<br>- Danh sách bài tập xoay vòng theo phút |
| **ENDURANCE**<br>*(Sức bền Calisthenics)* | Chuỗi bài tập tính theo vòng (Rounds) hoặc thời gian cố định. Đếm số hiệp đã hoàn thành trong khoảng thời gian xác định (ví dụ: hoàn thành nhiều hiệp nhất trong 20 phút hoặc 5 vòng cho thời gian tối ưu). | - Mục tiêu: Target Rounds hoặc Target Duration (15p, 30p, 60p)<br>- Thời gian tập cho phép (Work Cap)<br>- Thời gian nghỉ giữa các hiệp (Set Rest)<br>- Đếm số hiệp đã hoàn thành |
| **SKILL**<br>*(Kỹ năng & Tĩnh học - Isometric)* | Chuyên cho các động tác kỹ thuật và giữ tĩnh (Handstand, L-sit, Front Lever, Muscle-up). Đòi hỏi thời gian giữ chính xác và thời gian nghỉ dài để phục hồi hệ thần kinh trung ương. | - Thời gian Hold (ví dụ: 5s - 20s)<br>- Số sets (ví dụ: 5 sets)<br>- Thời gian nghỉ dài (ví dụ: 90s - 300s)<br>- Ghi chú form/cảm nhận hiệp |
| **CARDIO / HIIT** | Chuỗi bài tập cường độ cao ngắt quãng (Burpees, High Knees, Mountain Climbers) thúc đẩy nhịp tim và đốt calo. | - Thời gian Work (ví dụ: 20s, 30s, 45s)<br>- Thời gian Rest ngắn (10s, 15s)<br>- Số bài tập trong 1 vòng (Cycle)<br>- Số vòng lặp (Rounds) |
| **CUSTOM / FREE ROUTINE** | Người dùng tự do kết hợp bất kỳ thể thức nào thành một buổi tập hoàn chỉnh (Warm-up -> Skill -> Strength/Endurance -> Cool-down). | - Tùy biến từng khối (Block-based)<br>- Đặt tên block, thời gian tập, thời gian nghỉ riêng biệt |

---

## 4. TÍNH NĂNG CHI TIẾT (FUNCTIONAL REQUIREMENTS)

### 4.1. Quản lý & Tạo bài tập (Workout Builder & Management)
- **Tạo bài tập mới:**
  - Nhập tên bài tập, mô tả, chọn thể loại (EMOM, Endurance, Skill, Cardio, Custom).
  - Chọn độ khó (Beginner, Intermediate, Advanced).
  - Thiết lập danh sách động tác (kèm số rep, tạ bổ sung nếu có - weighted calisthenics, hoặc thời gian giữ - hold time).
- **Cấu hình thời gian & Hiệp đấu (Timing & Set Settings):**
  - Cài đặt thời gian chuẩn bị (Countdown before start): 5s, 10s, 15s.
  - Cài đặt thời gian tập (Work time / Hold time).
  - Cài đặt thời gian nghỉ giữa các hiệp (Rest time between sets): 10s đến 300s.
  - Cài đặt thời gian nghỉ giữa các bài tập (Rest time between exercises).
  - Cài đặt giới hạn thời gian tổng (Time Cap): 10 phút, 20 phút, 45 phút, 60 phút hoặc Không giới hạn.
  - Cài đặt số hiệp mục tiêu (Target Sets/Rounds): ví dụ 5 hiệp, 10 hiệp.
- **Thư viện bài tập mẫu (Preset Templates):**
  - Cung cấp sẵn các bài tập kinh điển của Calisthenics:
    - *EMOM Beast:* 10 Pull-ups, 20 Push-ups xen kẽ trong 20 phút.
    - *Full Body Endurance:* 5 Dips + 5 Pull-ups + 10 Squats (AMRAP 30 phút).
    - *Handstand Foundation:* 15s Wall Handstand + 90s Rest x 5 sets.
    - *Cardio Burner:* Tabata Burpees 8 rounds (4 phút).
- **CRUD & Tổ chức:** Nhân bản bài tập (Duplicate), Chỉnh sửa (Edit), Xóa (Delete), Đánh dấu yêu thích (Favorites).

### 4.2. Trình phát tập luyện & Bộ đếm giờ thông minh (Workout Player & Timer Engine)
- **Màn hình tập luyện Fullscreen trực quan:**
  - Hiển thị đồng hồ đếm ngược/đếm tiến cỡ lớn (High-contrast typography, dễ nhìn từ khoảng cách 2 - 3 mét).
  - Hiển thị trạng thái rõ rệt qua màu sắc đặc trưng:
    - **Xanh lá / Đỏ cam:** Đang trong hiệp tập (WORK).
    - **Xanh dương / Tím:** Đang trong thời gian nghỉ (REST).
    - **Vàng:** Chuẩn bị đếm ngược (PREPARE).
  - Hiển thị số hiệp hiện tại trên tổng số hiệp (ví dụ: `SET 3 / 8` hoặc `ROUND 4`).
  - Hiển thị tổng thời gian đã trôi qua (Elapsed time) và thời gian còn lại của buổi tập.
  - Tên động tác hiện tại và động tác kế tiếp (Next Up preview).
- **Điều khiển trong buổi tập:**
  - Tạm dừng (Pause), Tiếp tục (Resume).
  - Bỏ qua hiệp / Động tác tiếp theo (Skip to Next).
  - Quay lại hiệp trước (Back to Previous).
  - Nút "+10s" hoặc "-10s" nhanh cho thời gian nghỉ khi cần nghỉ thêm hoặc muốn tập sớm.
  - Khóa màn hình cảm ứng tạm thời (Screen Lock toggle) để tránh chạm nhầm khi nhét điện thoại vào túi hoặc để sàn.

### 4.3. Hệ thống Giọng nói & Âm thanh thông báo (Voice Cues & Audio System)
- **Trợ lý giọng nói ảo (Text-To-Speech - TTS):**
  - **Khởi đầu:** Đọc tên bài tập khi bắt đầu (ví dụ: *"Bắt đầu bài tập: Hít đất 15 cái, chuẩn bị!"*).
  - **Đếm ngược nhịp:** Đọc đếm ngược *"Ba, Hai, Một, Bắt đầu!"*.
  - **Kết thúc hiệp:** Đọc thông báo hoàn thành (ví dụ: *"Hoàn thành hiệp một. Nghỉ sáu mươi giây!"*).
  - **Nhắc nhở giữa giờ nghỉ:** Thông báo khi còn 10 giây hoặc 5 giây nghỉ (ví dụ: *"Còn mười giây, chuẩn bị hiệp hai: Kéo xà mười cái!"*).
  - **Đạt mốc thời gian:** Thông báo mốc thời gian quan trọng (ví dụ: *"Đã hoàn thành 10 phút"*, *"Còn một phút cuối cùng"*).
  - **Kết thúc buổi tập:** Lời chúc mừng hoàn thành (ví dụ: *"Chúc mừng bạn đã hoàn thành xuất sắc buổi tập hôm nay!"*).
- **Hỗ trợ đa ngôn ngữ giọng đọc:**
  - Tiếng Việt (chuẩn tự nhiên).
  - Tiếng Anh (English voice cues: *"Round 1, Go!", "Rest 60 seconds", "Next up: Pull ups"*).
- **Âm thanh hiệu ứng (Sound SFX & Beeper):**
  - Tiếng Beep đếm ngược ngắn (Short Beep) tại 3, 2, 1s.
  - Tiếng Còi hiệu dài (Long Beep / Whistle / Gong) khi bắt đầu hiệp hoặc kết thúc bài.
- **Tùy biến âm thanh trong Settings:**
  - Bật/tắt giọng nói TTS.
  - Bật/tắt âm thanh Beep.
  - Tùy chỉnh âm lượng (Voice volume boost).
  - Hỗ trợ Audio Ducking (hạ nhỏ nhạc nền Spotify/Apple Music khi có giọng đọc).

### 4.4. Lịch sử tập luyện & Thống kê (History & Analytics)
- **Lưu nhật ký buổi tập:** Tự động ghi nhận ngày giờ, tổng thời gian tập thực tế, số hiệp hoàn thành, thể loại bài tập.
- **Đánh giá sau buổi tập (Post-workout Summary):**
  - Tóm tắt kết quả: Số hiệp hoàn thành, calo ước tính, thời gian tập thực tế vs thời gian dự kiến.
  - Cho phép người dùng ghi chú cảm nhận (ví dụ: "Hôm nay đu xà tốt, hiệp 4 hơi mỏi cẳng tay").
- **Thống kê chuỗi ngày tập (Streak & Activity Calendar):**
  - Lịch hiển thị các ngày đã tập luyện.
  - Biểu đồ thời gian tập trong tuần/tháng.

### 4.5. Trải nghiệm người dùng & Cài đặt hệ thống (UX & System Settings)
- **Keep Screen Awake (Wakelock):** Màn hình luôn sáng trong suốt buổi tập, không bị tắt màn hình (tự động bật khi vào màn hình tập).
- **Chạy nền & Thông báo hệ thống (Background Execution):** Vẫn đếm giờ và phát âm thanh/giọng nói thông báo khi người dùng tắt màn hình hoặc chuyển sang ứng dụng khác.
- **Giao diện tối ưu (Dark Mode by default):** Thiết kế Dark Mode thể thao, tương phản cao, tiết kiệm pin cho màn hình OLED/AMOLED.
- **Offline-first:** 100% tính năng cốt lõi (tạo bài, đếm giờ, giọng đọc offline) hoạt động hoàn hảo không cần kết nối Internet.

---

## 5. YÊU CẦU PHI CHỨC NĂNG (NON-FUNCTIONAL REQUIREMENTS)

| Tiêu Chí | Yêu Cầu Cụ Thể |
| :--- | :--- |
| **Độ chính xác thời gian (Timer Precision)** | Timer sai số không vượt quá ±50ms. Cơ chế đếm giờ dựa trên `DateTime.now()` timestamp chứ không phụ thuộc vào `Timer.periodic` đơn thuần (tránh bị lệch thời gian khi hệ điều hành throttle CPU). |
| **Độ trễ âm thanh (Audio Latency)** | Giọng đọc TTS và tiếng Beep kích hoạt trễ không quá 100ms so với mốc thời gian thực tế. |
| **Tiết kiệm pin & Nhiệt độ** | Tối ưu hóa UI repaint (chỉ repaint widget hiển thị số giây, không rebuild toàn màn hình). Mức tiêu thụ pin dưới 5-8% cho 1 giờ tập luyện liên tục. |
| **Tính khả dụng ngoại tuyến (Offline Availability)** | Toàn bộ dữ liệu bài tập và âm thanh được lưu cục bộ trên máy người dùng (Local Database). |
| **Khả năng tương thích nền tảng** | Hỗ trợ Android 8.0 (API level 26) trở lên và iOS 13.0 trở lên. |
| **Trải nghiệm tương tác (Usability)** | Nút bấm to bản (minimum touch target 48x48dp, khuyến nghị 64x64dp) để bấm dễ dàng khi tay ướt mồ hôi. |

---

## 6. LƯỢNG GIÁ THÀNH CÔNG (SUCCESS METRICS & KPIS)
1. **Crash-free sessions:** Đạt trên 99.5% phiên tập không gặp lỗi crash.
2. **Audio cue reliability:** 100% các mốc chuyển đổi hiệp/nghỉ phát âm thanh đúng thời điểm.
3. **User completion rate:** Tỷ lệ người dùng hoàn thành buổi tập sau khi đã bấm bắt đầu > 80%.
4. **Offline readiness:** Ứng dụng hoạt động trơn tru không phát sinh lỗi khi bật chế độ máy bay (Airplane mode).

---

## 7. ĐỊNH HƯỚNG MỞ RỘNG TRONG TƯƠNG LAI (FUTURE ROADMAP)
- **Phase tiếp theo:**
  - Đồng bộ đám mây (Cloud Sync & Backup với Firebase / Supabase).
  - Tích hợp thiết bị đeo (Wear OS / Apple Watch) để xem nhịp tim và rung báo trên cổ tay.
  - Chia sẻ Routine qua mã QR hoặc cộng đồng Hamino Community.
  - AI Workout Generator: Tự động đề xuất lịch tập Calisthenics dựa trên cấp độ và mục tiêu của người dùng.

