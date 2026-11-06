const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PORT = 8080;
const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.ico': 'image/x-icon'
};

function getLocalIp() {
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        return net.address;
      }
    }
  }
  return 'localhost';
}

const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];
  if (reqPath === '/' || reqPath === '') reqPath = '/index.html';

  const filePath = path.join(__dirname, reqPath);
  const ext = path.extname(filePath).toLowerCase();

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Dosya bulunamadi');
      return;
    }
    res.writeHead(200, { 'Content-Type': MIME_TYPES[ext] || 'application/octet-stream' });
    res.end(data);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  const ip = getLocalIp();
  const url = `http://${ip}:${PORT}`;
  console.log('====================================================');
  console.log('  HIDRAT MOBIL UYGULAMA SUNUCUSU HAZIR!');
  console.log('====================================================');
  console.log(`  Bilgisayardan acmak icin : http://localhost:${PORT}`);
  console.log(`  Telefondan acmak icin    : ${url}`);
  console.log('----------------------------------------------------');
  console.log('  1. Telefonunuzun bilgisayar ile ayni Wi-Fi aginda oldugundan emin olun.');
  console.log(`  2. Telefon tarayicisinda ${url} adresine gidin.`);
  console.log('  3. "Ana Ekrana Ekle" / "Uygulamayi Yukle" secenegine dokunun.');
  console.log('====================================================');
});
