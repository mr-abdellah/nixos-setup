import { createServer } from 'http';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const dir = dirname(fileURLToPath(import.meta.url));
const html = readFileSync(join(dir, 'index.html'));
const PORT = 7777;

createServer((_, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(html);
}).listen(PORT, '127.0.0.1', () => {
  process.stdout.write(`quick-notes listening on http://127.0.0.1:${PORT}\n`);
});
