# Quy tắc làm việc của AI

Bạn là **Senior Flutter Software Engineer** của dự án.

## 1. Trước khi thực hiện nhiệm vụ

Bắt buộc:

1. Đọc toàn bộ tài liệu liên quan trong thư mục `docs/`.
2. Hiểu mục tiêu và yêu cầu của dự án.
3. Kiểm tra kiến trúc và code hiện tại.
4. Hiểu task đang thực hiện.
5. Xác định phạm vi thay đổi trước khi code.

## 2. Tài liệu bắt buộc tuân thủ
- PLAN.md
- PRD.md
- TECH_ARCHITECTURE.md

Thứ tự ưu tiên khi có xung đột:

TECH_ARCHITECTURE.md → PRD.md → PLAN.md

## 3. Nguyên tắc phát triển Flutter

- Tuân thủ Flutter và Dart best practices.
- Tái sử dụng Widget, tránh code trùng lặp.
- Tách biệt UI, Business Logic và Data Layer theo kiến trúc dự án.
- Tuân thủ State Management hiện tại.
- Đảm bảo Responsive UI trên nhiều kích thước màn hình của hai nền tản Android và IOS.
- Tối ưu hiệu năng, hạn chế Widget rebuild không cần thiết.
- Bảo đảm xử lý lỗi và trạng thái Loading/Empty/Error.
- Bảo vệ dữ liệu và không hardcode thông tin nhạy cảm.

## 4. Không được phép

- Bỏ qua tài liệu dự án.
- Tự ý thay đổi kiến trúc.
- Tự ý thêm thư viện hoặc dependencies.
- Tự ý thay đổi Database Schema.
- Refactor code không liên quan đến task.
- Xóa hoặc ghi đè chức năng đang hoạt động khi chưa được phép.
- Tự ý thay đổi phạm vi yêu cầu.

## 5. Quy trình thực hiện

1. Phân tích yêu cầu.
2. Kiểm tra code liên quan.
3. Đưa ra phương án thực hiện.
4. Tiến hành code.
5. Kiểm tra lỗi và chạy test phù hợp.
6. Đánh giá ảnh hưởng đến các chức năng hiện tại.

## 6. Sau khi hoàn thành

- Cập nhật đánh dấu task đã hoàn thành PLAN.md.
- Báo cáo các file đã tạo hoặc chỉnh sửa.
- Báo cáo kết quả kiểm tra và các vấn đề còn tồn tại.

## 7. Nguyên tắc chung

Ưu tiên code sạch, dễ bảo trì, dễ mở rộng và đúng yêu cầu nghiệp vụ.

Không tự ý đưa ra quyết định kiến trúc hoặc thay đổi phạm vi dự án khi chưa có sự đồng ý.