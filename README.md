# Pixel Sword RPG — Alpha 0.1

Game **2D pixel-art Action RPG top-down** được xây bằng **Godot 4.7 (Compatibility renderer)**, ưu tiên thử trên Android qua trình duyệt.

## Tính năng đã có trong mã nguồn
- Player di chuyển **4 hướng** (không đi chéo).
- Nhìn theo hướng di chuyển; dùng kiếm đánh 1 nhát theo hướng nhìn.
- Mục tiêu luyện tập có 30 HP, mỗi nhát gây 10 sát thương.
- Nút cảm ứng 4 hướng và Attack dành cho điện thoại.
- Dùng bàn phím WASD / mũi tên, J / Space khi thử trên máy tính.

## Mở bằng Godot 4.7
1. Clone hoặc Download ZIP repo này.
2. Trong Godot 4.7, chọn **Import** và mở `project.godot`.
3. Chạy scene chính để thử nhân vật.
4. Đi tới mục tiêu màu xanh rồi chém 3 lần.

## Trạng thái triển khai web
Repo hiện có **mã nguồn Godot**, chưa có các file Web export (`index.html`, `.js`, `.wasm`, `.pck`).
Vì vậy **GitHub Pages chưa thể chạy game trực tiếp**. Chưa triển khai APK.

Để triển khai bằng GitHub Pages không dùng workflow: trong Godot 4.7, cài Web export template tương ứng, chọn **Export > Web**, xuất thành `index.html`, bảo đảm xuất **single-threaded**, rồi đưa toàn bộ file export vào một thư mục phục vụ GitHub Pages. Godot 4.7 phải có web export templates tương thích.

## Cấu trúc
- `project.godot`: cấu hình Godot 4.7, Compatibility renderer.
- `scenes/main.tscn`: map thử, mục tiêu, nút cảm ứng.
- `scenes/player.tscn`: CharacterBody2D, hitbox kiếm, camera.
- `scripts/player.gd`: logic di chuyển và chém.
- `scripts/dummy.gd`: logic HP mục tiêu.
- `assets/`: sprite PNG pixel-art.

> Alpha thử nghiệm: chưa có AI quái, né đòn, animation nhiều frame, túi đồ hay save.
