// BACKEND: chương trình trả về một câu chúc ngẫu nhiên.
// Frontend gọi vào địa chỉ /api/message để lấy câu chúc.

const http = require('http');

const VERSION = 'v1'; // Đổi thành 'v2' khi làm phiên bản mới

const messages = [
  'Chúc bạn một ngày thật vui vẻ!',
  'Chúc nhóm mình được 10 điểm giữa kỳ!',
  'Chúc bạn code không bao giờ bị lỗi!',
  'Chúc bạn luôn mạnh khỏe và hạnh phúc!',
  'Chúc Kubernetes chạy mượt, không bị sập!',
];

const server = http.createServer((req, res) => {
  if (req.url === '/api/message') {
    const message = messages[Math.floor(Math.random() * messages.length)];
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ message, version: VERSION }));
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(3000, () => {
  console.log('Backend đang chạy ở cổng 3000');
});
