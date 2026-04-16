# HƯỚNG DẪN DEPLOY — DATA DETECTIVE PLATFORM
## Supabase + Vercel (100% miễn phí)

---

## BƯỚC 1: TẠO DATABASE TRÊN SUPABASE

### 1.1. Vào Supabase Dashboard
- Truy cập: https://supabase.com/dashboard
- Đăng nhập tài khoản Supabase

### 1.2. Tạo Project mới (nếu chưa có)
- Click "New Project"
- Đặt tên: `data-detective` (hoặc tên bất kỳ)
- Chọn region: **Southeast Asia (Singapore)** — gần Việt Nam nhất
- Đặt Database Password (ghi nhớ lại)
- Click "Create new project" → đợi 1-2 phút

### 1.3. Chạy SQL tạo bảng
- Trong project → vào **SQL Editor** (menu bên trái)
- Click "New query"
- Copy toàn bộ nội dung file `supabase-schema.sql` → paste vào editor
- Click **"Run"** (hoặc Ctrl+Enter)
- Phải thấy thông báo "Success" — tất cả bảng và policy đã được tạo

### 1.4. Lấy API Keys
- Vào **Settings** → **API** (menu bên trái)
- Copy 2 giá trị:
  - **Project URL**: `https://xxxxx.supabase.co`
  - **anon public key**: `eyJhbGciOiJIUz...` (dài)

### 1.5. Bật Realtime
- Vào **Database** → **Replication**
- Tìm bảng `game_results` → bật toggle **Realtime** (nếu chưa bật)
- Hoặc SQL đã tự bật qua `ALTER PUBLICATION` ở bước 1.3

---

## BƯỚC 2: CẤU HÌNH CODE

### 2.1. Cập nhật file game (public/index.html)
Mở file `public/index.html`, tìm dòng:
```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```
Thay bằng giá trị thật từ Bước 1.4:
```javascript
const SUPABASE_URL = 'https://abcdefghij.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUz...chuỗi-dài-thật...';
```

### 2.2. Cập nhật file admin (public/admin.html)
Mở file `public/admin.html`, tìm dòng tương tự và thay bằng **cùng giá trị**:
```javascript
const SUPABASE_URL = 'https://abcdefghij.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUz...chuỗi-dài-thật...';
```

### 2.3. Đổi mật khẩu admin (tùy chọn)
Trong `public/admin.html`, tìm dòng:
```javascript
const ADMIN_PASSWORD = 'dataviz2024';
```
Đổi thành mật khẩu mong muốn.

---

## BƯỚC 3: DEPLOY LÊN VERCEL

### Cách A: Deploy qua Vercel CLI (nhanh nhất)

```bash
# 1. Cài Vercel CLI (nếu chưa có)
npm install -g vercel

# 2. Vào thư mục project
cd data-detective-platform

# 3. Deploy
vercel

# 4. Trả lời các câu hỏi:
#    - Set up and deploy? → Y
#    - Which scope? → chọn tài khoản
#    - Link to existing project? → N
#    - Project name? → data-detective (hoặc tên bất kỳ)
#    - Directory? → ./
#    - Override settings? → N

# 5. Deploy production
vercel --prod
```

Sau khi xong, Vercel sẽ cho link dạng: `https://data-detective-xxx.vercel.app`

### Cách B: Deploy qua GitHub (tự động deploy khi push)

1. Tạo repository mới trên GitHub
2. Push thư mục `data-detective-platform` lên:
   ```bash
   cd data-detective-platform
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/data-detective.git
   git push -u origin main
   ```
3. Vào https://vercel.com/dashboard → **Add New Project**
4. Import GitHub repo vừa tạo
5. Settings:
   - Framework Preset: **Other**
   - Output Directory: **public**
6. Click **Deploy**

### Cách C: Deploy bằng drag & drop (đơn giản nhất)

1. Vào https://vercel.com/new
2. Kéo thả thư mục `data-detective-platform` vào trang web
3. Vercel sẽ tự động detect và deploy

---

## BƯỚC 4: SỬ DỤNG

### Cho sinh viên:
- Gửi link game: `https://your-project.vercel.app`
- Sinh viên mở trên trình duyệt (laptop hoặc điện thoại)
- Nhập tên + MSSV → chọn nhân vật → chơi
- Kết quả tự động lưu vào Supabase → hiện trên bảng xếp hạng real-time

### Cho giảng viên:
- Truy cập: `https://your-project.vercel.app/admin`
- Đăng nhập bằng mật khẩu admin
- Xem bảng xếp hạng real-time, thống kê theo nhân vật/phase
- Xuất kết quả ra CSV hoặc Excel
- Xem bài Phase 4 của từng sinh viên

---

## CẤU TRÚC THƯ MỤC

```
data-detective-platform/
├── public/
│   ├── index.html        ← Game chính (sinh viên chơi)
│   └── admin.html        ← Dashboard admin (giảng viên)
├── supabase-schema.sql   ← SQL tạo database
├── vercel.json           ← Cấu hình Vercel routing
├── package.json          ← Package info
└── HUONG-DAN-DEPLOY.md   ← File hướng dẫn này
```

---

## XỬ LÝ SỰ CỐ

| Vấn đề | Giải pháp |
|--------|-----------|
| Leaderboard không hiện | Kiểm tra SUPABASE_URL và ANON_KEY đã đúng chưa |
| Lỗi RLS policy | Chạy lại phần RLS trong SQL Editor |
| Realtime không cập nhật | Vào Supabase → Database → Replication → bật Realtime cho `game_results` |
| Admin không đăng nhập được | Kiểm tra mật khẩu trong `admin.html` |
| Vercel deploy lỗi | Đảm bảo `vercel.json` nằm ở root thư mục, `outputDirectory` = `public` |

---

## GHI CHÚ

- **Supabase Free Tier**: 500MB database, 2GB bandwidth, 50,000 requests/tháng — đủ cho lớp học
- **Vercel Free Tier**: 100GB bandwidth, unlimited static sites — đủ cho lớp học
- **anon key** là public key, an toàn để đặt trong frontend (RLS policy bảo vệ dữ liệu)
- Nếu cần reset dữ liệu: vào Supabase SQL Editor → chạy `DELETE FROM game_results;`
