#ifndef HTML_TEMPLATES_H
#define HTML_TEMPLATES_H

#include <Arduino.h>

// ============================================================================
// Minimalist Dark UI for ESP32 NAS Dashboard (Sharp Industrial Geometry)
// ============================================================================
const char NAS_PAGE_HEADER[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ESP32 Cloud NAS & Storage Node</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-main: #0c0d11;
      --bg-card: #13151b;
      --bg-sub: #181b22;
      --border-color: #272b35;
      --border-focus: #38bdf8;
      --text-main: #f1f5f9;
      --text-muted: #94a3b8;
      --text-dim: #64748b;
      --accent: #38bdf8;
      --accent-hover: #0284c7;
      --danger: #ef4444;
      --danger-hover: #dc2626;
      --success: #10b981;
    }
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      border-radius: 0 !important;
    }
    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: var(--bg-main);
      color: var(--text-main);
      min-height: 100vh;
      padding: 30px 20px;
      -webkit-font-smoothing: antialiased;
    }
    .container {
      max-width: 900px;
      margin: 0 auto;
    }
    .header-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      padding: 24px 28px;
      margin-bottom: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .title-group h1 {
      font-size: 1.45rem;
      font-weight: 700;
      color: var(--text-main);
      letter-spacing: -0.01em;
      margin-bottom: 4px;
    }
    .title-group p {
      color: var(--text-muted);
      font-size: 0.82rem;
      letter-spacing: 0.02em;
    }
    .btn-site {
      text-decoration: none;
      background: transparent;
      border: 1px solid var(--accent);
      color: var(--accent);
      padding: 8px 16px;
      font-size: 0.82rem;
      font-weight: 600;
      letter-spacing: 0.03em;
      transition: background-color 0.15s ease, color 0.15s ease;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    .btn-site:hover {
      background: var(--accent);
      color: var(--bg-main);
    }
    .meter-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      padding: 20px 24px;
      margin-bottom: 20px;
    }
    .meter-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
      font-size: 0.85rem;
    }
    .meter-title {
      font-weight: 600;
      color: var(--text-muted);
      text-transform: uppercase;
      font-size: 0.72rem;
      letter-spacing: 0.06em;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
    .meter-stats {
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
      color: var(--accent);
      font-weight: 600;
    }
    .progress-bar-bg {
      background: var(--bg-sub);
      border: 1px solid var(--border-color);
      height: 10px;
      overflow: hidden;
      position: relative;
    }
    .progress-bar-fill {
      height: 100%;
      background: var(--accent);
      transition: width 0.4s ease;
    }
    .upload-box {
      background: var(--bg-card);
      border: 1px dashed var(--border-color);
      padding: 24px;
      margin-bottom: 20px;
      text-align: center;
      transition: border-color 0.15s ease, background-color 0.15s ease;
    }
    .upload-box:hover {
      border-color: var(--border-focus);
      background: var(--bg-sub);
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
      font-size: 0.82rem;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
    input[type="file"]::file-selector-button {
      background: var(--bg-sub);
      border: 1px solid var(--border-color);
      color: var(--text-main);
      padding: 8px 16px;
      cursor: pointer;
      font-weight: 500;
      font-size: 0.82rem;
      transition: background-color 0.15s ease, border-color 0.15s ease;
      margin-right: 12px;
    }
    input[type="file"]::file-selector-button:hover {
      background: #242936;
      border-color: var(--accent);
    }
    .btn-upload {
      background: var(--accent);
      color: var(--bg-main);
      border: 1px solid var(--accent);
      padding: 8px 20px;
      font-weight: 600;
      cursor: pointer;
      font-size: 0.82rem;
      letter-spacing: 0.02em;
      transition: background-color 0.15s ease, opacity 0.15s ease;
    }
    .btn-upload:hover {
      background: var(--accent-hover);
      border-color: var(--accent-hover);
    }
    .btn-upload:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    .table-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      overflow-x: auto;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }
    th {
      background: var(--bg-sub);
      padding: 12px 18px;
      font-size: 0.72rem;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      color: var(--text-dim);
      border-bottom: 1px solid var(--border-color);
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
    td {
      padding: 12px 18px;
      font-size: 0.88rem;
      border-bottom: 1px solid var(--border-color);
      color: var(--text-main);
    }
    tr:last-child td {
      border-bottom: none;
    }
    tr:hover td {
      background: rgba(255, 255, 255, 0.02);
    }
    .btn-action {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      text-decoration: none;
      padding: 5px 12px;
      font-size: 0.76rem;
      font-weight: 600;
      letter-spacing: 0.03em;
      margin-right: 6px;
      transition: all 0.15s ease;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
      white-space: nowrap;
    }
    .btn-action .btn-icon,
    .badge-protected .btn-icon {
      font-size: 0.82rem;
      line-height: 1;
    }
    .header-actions {
      display: flex;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
    }
    .sync-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: var(--bg-sub);
      border: 1px solid var(--border-color);
      color: var(--text-muted);
      padding: 7px 12px;
      font-size: 0.75rem;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
      letter-spacing: 0.02em;
      cursor: pointer;
      user-select: none;
      transition: border-color 0.15s ease, color 0.15s ease;
      white-space: nowrap;
    }
    .sync-badge:hover {
      border-color: var(--accent);
      color: var(--accent);
    }
    .sync-dot {
      width: 6px;
      height: 6px;
      background: var(--accent);
      display: inline-block;
    }
    @media (max-width: 640px) {
      body {
        padding: 14px 10px;
      }
      .header-card {
        padding: 16px;
        flex-direction: column;
        align-items: flex-start;
        gap: 14px;
      }
      .header-actions {
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .title-group h1 {
        font-size: 1.18rem;
      }
      .title-group p {
        font-size: 0.75rem;
      }
      .meter-card {
        padding: 14px 16px;
      }
      .upload-box {
        padding: 16px 12px;
      }
      .upload-form {
        flex-direction: column;
        align-items: stretch;
        gap: 10px;
      }
      input[type="file"] {
        width: 100%;
        font-size: 0.76rem;
      }
      input[type="file"]::file-selector-button {
        width: 100%;
        margin-right: 0;
        margin-bottom: 8px;
        text-align: center;
        padding: 10px;
      }
      .btn-upload {
        width: 100%;
        padding: 10px;
        font-size: 0.85rem;
      }
      th, td {
        padding: 10px 8px;
        font-size: 0.8rem;
      }
      th {
        font-size: 0.68rem;
      }
      td:first-child {
        word-break: break-word;
        max-width: 160px;
      }
      .tag-folder {
        display: inline-block;
        margin-left: 0;
        margin-top: 3px;
        font-size: 0.68rem;
      }
      /* Mobile: Download & Delete buttons appear as icons only */
      .btn-action {
        padding: 6px 10px;
        margin-right: 3px;
        font-size: 0.85rem;
      }
      .btn-action .btn-text,
      .badge-protected .btn-text {
        display: none;
      }
      .btn-action .btn-icon,
      .badge-protected .btn-icon {
        margin: 0;
        font-size: 0.95rem;
      }
      .badge-protected {
        padding: 6px 8px;
      }
    }
    .btn-dl {
      background: transparent;
      color: var(--accent);
      border: 1px solid var(--accent);
    }
    .btn-dl:hover {
      background: var(--accent);
      color: var(--bg-main);
    }
    .btn-del {
      background: transparent;
      color: var(--danger);
      border: 1px solid var(--danger);
    }
    .btn-del:hover {
      background: var(--danger);
      color: #fff;
    }
    .badge-protected {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      background: var(--bg-sub);
      color: var(--text-dim);
      border: 1px solid var(--border-color);
      padding: 4px 8px;
      font-size: 0.72rem;
      font-weight: 600;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
      letter-spacing: 0.04em;
      user-select: none;
    }
    .tag-folder {
      display: inline-block;
      font-size: 0.72rem;
      color: var(--text-muted);
      background: var(--bg-sub);
      border: 1px solid var(--border-color);
      padding: 2px 6px;
      margin-left: 8px;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
    .progress-box {
      display: none;
      margin-top: 18px;
      padding: 16px;
      background: var(--bg-sub);
      border: 1px solid var(--border-color);
      text-align: left;
    }
    .progress-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
      font-size: 0.82rem;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
    .speed-badge {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      color: var(--accent);
      font-weight: 600;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
    .eta-badge {
      color: #fbbf24;
      font-weight: 500;
      font-size: 0.78rem;
      font-family: ui-monospace, SFMono-Regular, Consolas, monospace;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header-card">
      <div class="title-group">
        <h1>ESP32 Storage NAS Node</h1>
        <p>Hardware VSPI FAT32 MicroSD Storage Engine</p>
      </div>
      <div>
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
          name.innerHTML = '<strong style="color: var(--success);">✅ Upload Complete!</strong> Stored on host SSD/HDD.';
          speed.innerHTML = '⚡ Complete';
          eta.textContent = '⏱ Done';
          setTimeout(function() { window.location.reload(); }, 1000);
        } else {
          name.innerHTML = '<strong style="color: var(--danger);">❌ Upload Error (' + xhr.status + ')</strong>';
          btn.disabled = false;
          btn.style.opacity = '1';
        }
      };

      xhr.onerror = function() {
        name.innerHTML = '<strong style="color: var(--danger);">❌ Network Transmission Failed</strong>';
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
