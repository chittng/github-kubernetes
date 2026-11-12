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

## Đóng gói bằng Docker

Image được lưu trên **GitHub Container Registry (GHCR)**:

- `ghcr.io/chittng/loichuc-backend`
- `ghcr.io/chittng/loichuc-frontend`

```bash
# Đăng nhập GHCR (cần GitHub token có quyền write:packages)
gh auth token | docker login ghcr.io -u chittng --password-stdin

# Build image (tag v1, không dùng latest)
docker build -t ghcr.io/chittng/loichuc-backend:v1 ./backend
docker build -t ghcr.io/chittng/loichuc-frontend:v1 ./frontend

# Đẩy image lên GHCR
docker push ghcr.io/chittng/loichuc-backend:v1
docker push ghcr.io/chittng/loichuc-frontend:v1
```

Chạy thử bằng Docker trên máy (2 container nói chuyện với nhau qua 1 network chung):

```bash
docker network create loichuc
docker run -d --name backend  --network loichuc ghcr.io/chittng/loichuc-backend:v1
docker run -d --name frontend --network loichuc -p 8080:8080 \
  -e BACKEND_URL=http://backend:3000 ghcr.io/chittng/loichuc-frontend:v1
```

Mở http://localhost:8080. Dọn dẹp:

```bash
docker rm -f frontend backend && docker network rm loichuc
```

## Làm phiên bản mới (v2)

Mở `backend/server.js`, đổi dòng `const VERSION = 'v1';` thành `'v2'`
(có thể thêm vài câu chúc mới), rồi build và push với tag `v2`:

```bash
docker build -t ghcr.io/chittng/loichuc-backend:v2 ./backend
docker push ghcr.io/chittng/loichuc-backend:v2
```

Trang web sẽ hiện "Phiên bản: v2".
