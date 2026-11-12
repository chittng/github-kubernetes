# Bài tập giữa kỳ CKA 2026 – Ứng dụng "Lời chúc"

Trang web đơn giản: bấm nút → hiện một câu chúc ngẫu nhiên.

```
Trình duyệt  ──►  Frontend (cổng 8080)  ──►  Backend (cổng 3000)
                  hiển thị trang web         trả về câu chúc
```

- **backend/** – trả về câu chúc ngẫu nhiên ở địa chỉ `/api/message`
- **frontend/** – hiển thị trang web, khi bấm nút thì hỏi backend để lấy câu chúc

## Chạy trên máy (cần cài Node.js)

Mở 2 cửa sổ terminal:

```bash
# Cửa sổ 1
cd backend
npm start

# Cửa sổ 2
cd frontend
npm start
```

Mở trình duyệt: http://localhost:8080

## Làm phiên bản mới (v2)

Mở `backend/server.js`, đổi dòng `const VERSION = 'v1';` thành `'v2'`
(có thể thêm vài câu chúc mới). Trang web sẽ hiện "Phiên bản: v2".
