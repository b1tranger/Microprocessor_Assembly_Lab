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
</body>
</html>
)rawliteral";

// ============================================================================
// Modern Responsive Landing Page for Static Web Host (/www/index.html)
// ============================================================================
const char SEED_INDEX_HTML[] PROGMEM = R"rawliteral(<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ESP32 Static Edge Host</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      font-family: 'Inter', sans-serif;
      background: radial-gradient(circle at 10% 20%, #10121a, #08090d 90%);
      color: #e2e8f0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    .card {
      max-width: 680px;
      width: 100%;
      background: rgba(20, 24, 38, 0.85);
      backdrop-filter: blur(16px);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 20px;
      padding: 40px;
      text-align: center;
      box-shadow: 0 20px 50px rgba(0,0,0,0.5);
    }
    .badge {
      display: inline-block;
      padding: 6px 14px;
      background: rgba(0, 210, 255, 0.12);
      border: 1px solid rgba(0, 210, 255, 0.3);
      color: #00d2ff;
      border-radius: 20px;
      font-size: 0.8rem;
      font-weight: 600;
      margin-bottom: 20px;
    }
    h1 {
      font-size: 2rem;
      font-weight: 700;
      background: linear-gradient(135deg, #00d2ff, #3a7bd5);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      margin-bottom: 12px;
    }
    p.lead {
      color: #94a3b8;
      font-size: 1rem;
      margin-bottom: 30px;
      line-height: 1.6;
    }
    .specs-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 16px;
      margin-bottom: 32px;
      text-align: left;
    }
    .spec-item {
      background: rgba(255,255,255,0.03);
      border: 1px solid rgba(255,255,255,0.06);
      border-radius: 12px;
      padding: 16px;
    }
    .spec-label {
      font-size: 0.75rem;
      color: #64748b;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      margin-bottom: 4px;
    }
    .spec-val {
      font-size: 0.95rem;
      font-weight: 600;
      color: #f1f5f9;
    }
    .btn {
      display: inline-block;
      background: linear-gradient(135deg, #00d2ff, #3a7bd5);
      color: #fff;
      text-decoration: none;
      padding: 12px 28px;
      border-radius: 10px;
      font-weight: 600;
      font-size: 0.9rem;
      transition: transform 0.1s, opacity 0.2s;
    }
    .btn:hover { opacity: 0.9; }
    .btn:active { transform: scale(0.98); }
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">ESP32 Static Edge Host</span>
    <h1>Hosted on MicroSD Storage</h1>
    <p class="lead">
      This static web document is stored as raw blocks on the virtual FAT32 MicroSD card and streamed directly to your browser over hardware SPI.
    </p>
    <div class="specs-grid">
      <div class="spec-item">
        <div class="spec-label">Microcontroller</div>
        <div class="spec-val">ESP32 DevKit V1</div>
      </div>
      <div class="spec-item">
        <div class="spec-label">Storage Bus</div>
        <div class="spec-val">Hardware VSPI</div>
      </div>
      <div class="spec-item">
        <div class="spec-label">File Protocol</div>
        <div class="spec-val">FAT32 Block I/O</div>
      </div>
      <div class="spec-item">
        <div class="spec-label">Web Engine</div>
        <div class="spec-val">ESP32 WebServer:80</div>
      </div>
    </div>
    <a href="/" class="btn">📂 Go to NAS File Browser</a>
  </div>
</body>
</html>)rawliteral";

#endif // HTML_TEMPLATES_H
