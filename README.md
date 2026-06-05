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
- Screen 3: Home Screen
  - Hiển thị banner đơn giản.
  - Có ô tìm kiếm sim và chuyển sang danh sách khi tìm.
  - Hiển thị các loại sim phổ biến: tam hoa, tứ quý, lộc phát, thần tài, năm sinh.
  - Hiển thị danh sách sim nổi bật.
- Screen 4: Sim List Screen
  - Hiển thị danh sách sim.
  - Tìm kiếm sim theo số.
  - Lọc theo nhà mạng, loại sim và khoảng giá.
  - Hiển thị số sim, nhà mạng, loại sim, giá và trạng thái.

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

Các route cho Screen 5-8 đã được tạo file khung để triển khai tiếp: Sim Detail, Checkout, My Orders và Admin.

## Chạy dự án

```bash
flutter pub get
flutter run
```
# SimSiu
