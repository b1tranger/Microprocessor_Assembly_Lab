#ifndef HTML_TEMPLATES_H
#define HTML_TEMPLATES_H

#include <Arduino.h>

// ============================================================================
// Modern Glassmorphic Dark UI for ESP32 NAS Dashboard
// ============================================================================
const char NAS_PAGE_HEADER[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ESP32 Cloud NAS & Web Node</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-gradient: radial-gradient(circle at top left, #1a1c29, #0e1017 80%);
      --card-bg: rgba(26, 29, 45, 0.7);
      --card-border: rgba(255, 255, 255, 0.08);
      --accent-cyan: #00d2ff;
      --accent-blue: #3a7bd5;
      --accent-gradient: linear-gradient(135deg, #00d2ff 0%, #3a7bd5 100%);
      --danger-gradient: linear-gradient(135deg, #ff416c 0%, #ff4b2b 100%);
      --success-color: #00e676;
      --text-main: #f0f4f8;
      --text-muted: #94a3b8;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', -apple-system, sans-serif;
      background: var(--bg-gradient);
      color: var(--text-main);
      min-height: 100vh;
      padding: 30px 20px;
    }
    .container {
      max-width: 900px;
      margin: 0 auto;
    }
    .header-card {
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 24px;
      margin-bottom: 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
    }
    .title-group h1 {
      font-size: 1.5rem;
      font-weight: 700;
      background: var(--accent-gradient);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      margin-bottom: 4px;
    }
    .title-group p {
      color: var(--text-muted);
      font-size: 0.85rem;
    }
    .badge-online {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(0, 230, 118, 0.12);
      color: var(--success-color);
      border: 1px solid rgba(0, 230, 118, 0.3);
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 0.8rem;
      font-weight: 600;
    }
    .badge-dot {
      width: 8px;
      height: 8px;
      background: var(--success-color);
      border-radius: 50%;
      box-shadow: 0 0 8px var(--success-color);
    }
    .btn-site {
      text-decoration: none;
      background: var(--card-bg);
      border: 1px solid var(--card-border);
      color: var(--accent-cyan);
      padding: 8px 16px;
      border-radius: 8px;
      font-size: 0.85rem;
      font-weight: 500;
      transition: all 0.2s;
    }
    .btn-site:hover {
      background: rgba(0, 210, 255, 0.1);
      border-color: var(--accent-cyan);
    }
    .meter-card {
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      padding: 20px 24px;
      margin-bottom: 24px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
    }
    .meter-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 10px;
      font-size: 0.9rem;
    }
    .progress-bar-bg {
      background: rgba(255, 255, 255, 0.08);
      height: 12px;
      border-radius: 6px;
      overflow: hidden;
      position: relative;
    }
    .progress-bar-fill {
      height: 100%;
      background: var(--accent-gradient);
      border-radius: 6px;
      transition: width 0.4s ease;
    }
    .upload-box {
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      border: 2px dashed rgba(0, 210, 255, 0.3);
      border-radius: 16px;
      padding: 24px;
      margin-bottom: 24px;
      text-align: center;
      transition: all 0.2s ease;
    }
    .upload-box:hover {
      border-color: var(--accent-cyan);
      background: rgba(0, 210, 255, 0.03);
    }
    .upload-form {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 12px;
      align-items: center;
    }
    input[type="file"] {
      color: var(--text-muted);
      font-size: 0.85rem;
    }
    input[type="file"]::file-selector-button {
      background: rgba(255, 255, 255, 0.06);
      border: 1px solid var(--card-border);
      color: var(--text-main);
      padding: 8px 16px;
      border-radius: 8px;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.2s;
    }
    input[type="file"]::file-selector-button:hover {
      background: rgba(255, 255, 255, 0.12);
    }
    .btn-upload {
      background: var(--accent-gradient);
      color: #fff;
      border: none;
      padding: 9px 20px;
      border-radius: 8px;
      font-weight: 600;
      cursor: pointer;
      font-size: 0.85rem;
      transition: transform 0.1s, opacity 0.2s;
    }
    .btn-upload:hover { opacity: 0.9; }
    .btn-upload:active { transform: scale(0.98); }
    .table-card {
      background: var(--card-bg);
      backdrop-filter: blur(12px);
      border: 1px solid var(--card-border);
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    }
    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }
    th {
      background: rgba(255, 255, 255, 0.03);
      padding: 14px 18px;
      font-size: 0.8rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--text-muted);
      border-bottom: 1px solid var(--card-border);
    }
    td {
      padding: 14px 18px;
      font-size: 0.9rem;
      border-bottom: 1px solid rgba(255, 255, 255, 0.04);
    }
    tr:last-child td { border-bottom: none; }
    tr:hover td { background: rgba(255, 255, 255, 0.02); }
    .btn-action {
      display: inline-block;
      text-decoration: none;
      padding: 6px 14px;
      border-radius: 6px;
      font-size: 0.8rem;
      font-weight: 500;
      margin-right: 6px;
      transition: all 0.2s;
    }
    .btn-dl {
      background: rgba(0, 210, 255, 0.1);
      color: var(--accent-cyan);
      border: 1px solid rgba(0, 210, 255, 0.2);
    }
    .btn-dl:hover {
      background: var(--accent-gradient);
      color: #fff;
    }
    .btn-del {
      background: rgba(255, 75, 43, 0.1);
      color: #ff5252;
      border: 1px solid rgba(255, 75, 43, 0.2);
    }
    .btn-del:hover {
      background: var(--danger-gradient);
      color: #fff;
    }
    .badge-protected {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      background: rgba(148, 163, 184, 0.12);
      color: #94a3b8;
      border: 1px solid rgba(148, 163, 184, 0.25);
      padding: 5px 10px;
      border-radius: 6px;
      font-size: 0.78rem;
      font-weight: 500;
      user-select: none;
    }
    .tag-folder {
      display: inline-block;
      font-size: 0.72rem;
      color: var(--accent-cyan);
      background: rgba(0, 210, 255, 0.08);
      border: 1px solid rgba(0, 210, 255, 0.2);
      padding: 2px 6px;
      border-radius: 4px;
      margin-left: 6px;
      font-family: monospace;
    }
    .progress-box {
      display: none;
      margin-top: 20px;
      padding: 16px;
      background: rgba(14, 16, 23, 0.6);
      border: 1px solid rgba(0, 210, 255, 0.25);
      border-radius: 12px;
      text-align: left;
    }
    .progress-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
      font-size: 0.88rem;
    }
    .speed-badge {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      color: var(--accent-cyan);
      font-weight: 600;
      font-family: monospace;
    }
    .eta-badge {
      color: #fbbf24;
      font-weight: 500;
      font-size: 0.82rem;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header-card">
      <div class="title-group">
        <h1>ESP32 Storage NAS Node</h1>
        <p>Hardware SPI FAT32 MicroSD Storage Engine</p>
      </div>
      <div style="display: flex; gap: 12px; align-items: center;">
        <span class="badge-online"><span class="badge-dot"></span> Online</span>
        <a href="/site" class="btn-site">🌐 Static Site</a>
      </div>
    </div>
)rawliteral";

const char NAS_PAGE_FOOTER[] PROGMEM = R"rawliteral(
  </div>
  <script>
    function fmtBytes(b) {
      if (b < 1024) return b + ' B';
      if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
      return (b / 1048576).toFixed(1) + ' MB';
    }
    function submitUpload() {
      var inp = document.getElementById('fileSelect');
      if (!inp.files.length) return;
      var f = inp.files[0];

      var box = document.getElementById('progressBox');
      var bar = document.getElementById('progressBarFill');
      var pct = document.getElementById('percentDisplay');
      var name = document.getElementById('fileNameDisplay');
      var bytes = document.getElementById('bytesDisplay');
      var speed = document.getElementById('speedDisplay');
      var eta = document.getElementById('etaDisplay');
      var btn = document.getElementById('uploadBtn');

      box.style.display = 'block';
      name.innerHTML = '<strong>Uploading:</strong> ' + f.name;
      btn.disabled = true;
      btn.style.opacity = '0.5';

      var fd = new FormData();
      fd.append('upload_file', f);

      var xhr = new XMLHttpRequest();
      var t0 = Date.now();
      var lastT = t0;
      var lastL = 0;
      var smoothedSpeed = 0;

      xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
          var now = Date.now();
          var p = Math.round((e.loaded / e.total) * 100);
          bar.style.width = p + '%';
          pct.textContent = p + '%';
          bytes.textContent = fmtBytes(e.loaded) + ' / ' + fmtBytes(e.total);

          var dt = (now - lastT) / 1000;
          if (dt >= 0.2 || e.loaded === e.total) {
            var inst = (e.loaded - lastL) / (dt || 0.001);
            smoothedSpeed = (smoothedSpeed === 0) ? inst : (0.65 * smoothedSpeed + 0.35 * inst);
            speed.innerHTML = '⚡ ' + fmtBytes(smoothedSpeed) + '/s';

            var rem = e.total - e.loaded;
            if (smoothedSpeed > 0) {
              var s = Math.round(rem / smoothedSpeed);
              eta.textContent = '⏱ ' + (s >= 60 ? Math.floor(s / 60) + 'm ' + (s % 60) + 's' : s + 's left');
            }
            lastT = now;
            lastL = e.loaded;
          }
        }
      };

      xhr.onload = function() {
        if (xhr.status >= 200 && xhr.status < 400) {
          bar.style.width = '100%';
          pct.textContent = '100%';
          name.innerHTML = '<strong style="color: #00e676;">✅ Upload Complete!</strong> Stored on host SSD/HDD.';
          speed.innerHTML = '⚡ Complete';
          eta.textContent = '⏱ Done';
          setTimeout(function() { window.location.reload(); }, 1000);
        } else {
          name.innerHTML = '<strong style="color: #ff5252;">❌ Upload Error (' + xhr.status + ')</strong>';
          btn.disabled = false;
          btn.style.opacity = '1';
        }
      };

      xhr.onerror = function() {
        name.innerHTML = '<strong style="color: #ff5252;">❌ Network Transmission Failed</strong>';
        btn.disabled = false;
        btn.style.opacity = '1';
      };

      xhr.open('POST', '/upload', true);
      xhr.send(fd);
    }
  </script>
</body>
</html>
)rawliteral";

#endif // HTML_TEMPLATES_H
