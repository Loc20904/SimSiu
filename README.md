# Sim Dep Mobile

Khung Flutter cho hệ thống bán sim số đẹp bản đơn giản.

## Screen hiện có

- Screen 1: Splash Screen
  - Hiển thị logo app.
  - Kiểm tra phiên đăng nhập giả lập.
  - Tự chuyển sang Login/Register hoặc Home.
- Screen 2: Login / Register Screen
  - Gộp đăng nhập và đăng ký trong cùng một màn hình.
  - Đăng nhập bằng email, mật khẩu.
  - Đăng ký bằng họ tên, email, số điện thoại, mật khẩu.
  - Validate dữ liệu cơ bản và chuyển vào Home sau khi thành công.

## Khung dự án

```text
lib/
  core/       route, theme, formatter
  data/       dữ liệu mẫu
  models/     user, sim, order
  screens/    8 screen của app
  services/   auth service giả lập
  widgets/    widget dùng chung
```

Các route cho Screen 3-8 đã được tạo file khung để triển khai tiếp: Home, Sim List, Sim Detail, Checkout, My Orders và Admin.

## Chạy dự án

```bash
flutter pub get
flutter run
```
# SimSiu
