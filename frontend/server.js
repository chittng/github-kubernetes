// FRONTEND: chương trình hiển thị trang web cho người dùng.
// - Vào trang chủ "/"   -> trả về file index.html
// - Gọi "/api/message"  -> frontend hỏi backend rồi trả kết quả lại cho trình duyệt

const http = require('http');
const fs = require('fs');
const path = require('path');

// Địa chỉ của backend. Chạy trên máy: localhost. Trên Kubernetes sẽ đổi thành tên Service.
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:3000';

const server = http.createServer(async (req, res) => {
  if (req.url === '/') {
    const html = fs.readFileSync(path.join(__dirname, 'index.html'));
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(html);
  } else if (req.url === '/api/message') {
    try {
      const response = await fetch(BACKEND_URL + '/api/message');
      const data = await response.json();
      res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify(data));
    } catch (err) {
      res.writeHead(502, { 'Content-Type': 'application/json; charset=utf-8' });
      res.end(JSON.stringify({ message: 'Không kết nối được backend', version: '?' }));
    }
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(8080, () => {
  console.log('Frontend đang chạy ở cổng 8080, backend: ' + BACKEND_URL);
});
