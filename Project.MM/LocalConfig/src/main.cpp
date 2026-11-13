#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <SPI.h>
#include <SD.h>
#include <vector>
#include "html_templates.h"
#include "default_assets.h"

// Hardware SPI Chip Select pin mapped to GPIO 5
#define SD_CS_PIN 5

// Wokwi virtual Wi-Fi access point credentials
const char* ssid = "Wokwi-GUEST";
const char* password = "";

WebServer server(80);
File uploadFile;

// --- Unit Formatting Helper ---
String formatBytes(size_t bytes) {
  if (bytes < 1024) return String(bytes) + " B";
  if (bytes < (1024 * 1024)) return String(bytes / 1024.0, 1) + " KB";
  return String(bytes / (1024.0 * 1024.0), 1) + " MB";
}

// ============================================================================
// SECURITY & FILE PROTECTION SYSTEM
// ============================================================================
bool isProtectedPath(const String& rawPath) {
  String p = rawPath;
  if (!p.startsWith("/")) p = "/" + p;
  
  // Direct default root mirrors or folders
  if (p == "/lab_report.txt") return true;
  if (p.startsWith("/default/") || p == "/default") return true;
  if (p.startsWith("/www/") || p == "/www") return true;

  // Match against all registered embedded assets
  for (size_t i = 0; i < EMBEDDED_ASSET_COUNT; i++) {
    if (p == EMBEDDED_ASSETS[i].sdPath && EMBEDDED_ASSETS[i].isProtected) {
      return true;
    }
  }
  return false;
}

void ensureParentDir(const String& path) {
  int lastSlash = path.lastIndexOf('/');
  if (lastSlash > 0) {
    String dir = path.substring(0, lastSlash);
    if (!SD.exists(dir)) {
      SD.mkdir(dir);
    }
  }
}

// ============================================================================
// PHASE 1: STORAGE INITIALIZATION & DYNAMIC ASSET SEEDING
// ============================================================================
void phase1_seedInitialFiles() {
  // Ensure primary folder structure exists
  if (!SD.exists("/default")) SD.mkdir("/default");
  if (!SD.exists("/www")) SD.mkdir("/www");
  if (!SD.exists("/uploads")) SD.mkdir("/uploads");

  // Dynamically seed all embedded assets from data/ folder
  for (size_t i = 0; i < EMBEDDED_ASSET_COUNT; i++) {
    const EmbeddedAsset& asset = EMBEDDED_ASSETS[i];
    ensureParentDir(asset.sdPath);

    if (!SD.exists(asset.sdPath)) {
      File f = SD.open(asset.sdPath, FILE_WRITE);
      if (f) {
        f.write(asset.data, asset.size);
        f.close();
        Serial.printf("[STORAGE] Seeded %s (%u bytes)\n", asset.sdPath, (unsigned int)asset.size);
      }
    }
  }

  // Backwards-compatible mirror for root /lab_report.txt if missing
  if (!SD.exists("/lab_report.txt") && SD.exists("/default/lab_report.txt")) {
    File src = SD.open("/default/lab_report.txt", FILE_READ);
    File dst = SD.open("/lab_report.txt", FILE_WRITE);
    if (src && dst) {
      uint8_t buf[256];
      while (src.available()) {
        size_t len = src.read(buf, sizeof(buf));
        dst.write(buf, len);
      }
      src.close();
      dst.close();
      Serial.println("[STORAGE] Mirrored /default/lab_report.txt to /lab_report.txt for compatibility");
    }
  }
}

bool phase1_initStorage() {
  Serial.println("\n--------------------------------------------------");
  Serial.println("  [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   ");
  Serial.println("--------------------------------------------------");

  // Explicitly initialize hardware VSPI bus
  SPI.begin(18, 19, 23, SD_CS_PIN);

  // Initialize SD with high-speed 25 MHz SPI clock (with 4 MHz fallback)
  if (!SD.begin(SD_CS_PIN, SPI, 25000000)) {
    Serial.println("[PHASE 1 WARN] 25 MHz SPI mode failed, attempting standard 4 MHz...");
    if (!SD.begin(SD_CS_PIN, SPI, 4000000)) {
      Serial.println("[PHASE 1 ERROR] SD Card initialization failed! Check SPI pins.");
      return false;
    }
  }

  uint64_t totalBytes = SD.totalBytes();
  uint64_t usedBytes = SD.usedBytes();
  Serial.printf("[PHASE 1 SUCCESS] FAT32 Storage Mounted.\n");
  Serial.printf("[PHASE 1 CAPACITY] Total: %llu MB | Used: %llu MB\n",
                totalBytes / (1024 * 1024), usedBytes / (1024 * 1024));

  phase1_seedInitialFiles();

  Serial.println("[PHASE 1 DIRECTORY TREE]:");
  File root = SD.open("/");
  File file = root.openNextFile();
  while (file) {
    if (file.isDirectory()) {
      Serial.printf("  [DIR]  /%s\n", file.name());
    } else {
      Serial.printf("  [FILE] /%s (%s)\n", file.name(), formatBytes(file.size()).c_str());
    }
    file = root.openNextFile();
  }
  root.close();

  Serial.println("--------------------------------------------------\n");
  return true;
}

// ============================================================================
// PHASE 2: HTTP ROUTE HANDLERS
// ============================================================================

struct StorageItem {
  String path;
  size_t size;
  bool isProtected;
};

void collectFilesRecursively(File dir, std::vector<StorageItem>& items, int depth = 0) {
  if (!dir || !dir.isDirectory() || depth > 3) return;

  File file = dir.openNextFile();
  while (file) {
    if (file.isDirectory()) {
      collectFilesRecursively(file, items, depth + 1);
    } else {
      String fullPath = String(file.name());
      if (!fullPath.startsWith("/")) fullPath = "/" + fullPath;

      // Skip root /lab_report.txt if /default/lab_report.txt exists to avoid duplicate rows
      if (fullPath == "/lab_report.txt" && SD.exists("/default/lab_report.txt")) {
        file = dir.openNextFile();
        continue;
      }

      StorageItem item;
      item.path = fullPath;
      item.size = file.size();
      item.isProtected = isProtectedPath(fullPath);
      items.push_back(item);
    }
    file = dir.openNextFile();
  }
}

// Route: NAS Dashboard (Renders storage meter, upload form, and protected file table)
void handleRoot() {
  uint64_t total = SD.totalBytes();
  uint64_t used = SD.usedBytes();
  float usedPercent = (total > 0) ? ((float)used / (float)total) * 100.0f : 0.0f;

  // Stream header from flash PROGMEM
  server.setContentLength(CONTENT_LENGTH_UNKNOWN);
  server.send(200, "text/html", "");
  server.sendContent(FPSTR(NAS_PAGE_HEADER));

  // Storage meter section
  String meter = "<div class='meter-card'>";
  meter += "<div class='meter-header'>";
  meter += "<span><strong>Storage:</strong> " + formatBytes(used) + " / " + formatBytes(total) + "</span>";
  meter += "<span><strong>" + String(usedPercent, 1) + "%</strong> Used</span>";
  meter += "</div>";
  meter += "<div class='progress-bar-bg'><div class='progress-bar-fill' style='width: " + String(usedPercent, 1) + "%;'></div></div>";
  meter += "</div>";
  server.sendContent(meter);

  // Upload Form section with real-time transfer speed & progress indicators
  String uploadBox = "<div class='upload-box'>";
  uploadBox += "<form id='uploadForm' class='upload-form' onsubmit='event.preventDefault(); submitUpload();'>";
  uploadBox += "<input type='file' id='fileSelect' name='upload_file' required>";
  uploadBox += "<button type='submit' id='uploadBtn' class='btn-upload'>⬆ Upload to Storage</button>";
  uploadBox += "</form>";
  uploadBox += "<div id='progressBox' class='progress-box'>";
  uploadBox += "<div class='progress-info'>";
  uploadBox += "<span id='fileNameDisplay'><strong>Uploading:</strong> </span>";
  uploadBox += "<span id='percentDisplay' style='color: var(--accent-cyan); font-weight: 700;'>0%</span>";
  uploadBox += "</div>";
  uploadBox += "<div class='progress-bar-bg'><div id='progressBarFill' class='progress-bar-fill' style='width: 0%;'></div></div>";
  uploadBox += "<div class='progress-info' style='margin-top: 10px; margin-bottom: 0;'>";
  uploadBox += "<span id='bytesDisplay' style='color: var(--text-muted);'>0 B / 0 B</span>";
  uploadBox += "<span id='speedDisplay' class='speed-badge'>⚡ 0 KB/s</span>";
  uploadBox += "<span id='etaDisplay' class='eta-badge'>⏱ Calculating...</span>";
  uploadBox += "</div>";
  uploadBox += "</div>";
  uploadBox += "</div>";
  server.sendContent(uploadBox);

  // File Table section
  String tableStart = "<div class='table-card'><table>";
  tableStart += "<tr><th>File Name & Location</th><th>Size</th><th style='text-align: right;'>Actions</th></tr>";
  server.sendContent(tableStart);

  std::vector<StorageItem> items;
  File root = SD.open("/");
  collectFilesRecursively(root, items);
  root.close();

  for (const auto& item : items) {
    int lastSlash = item.path.lastIndexOf('/');
    String dirName = (lastSlash > 0) ? item.path.substring(0, lastSlash) : "/";
    String baseName = (lastSlash >= 0) ? item.path.substring(lastSlash + 1) : item.path;

    String row = "<tr>";
    row += "<td><strong>📄 " + baseName + "</strong> <span class='tag-folder'>" + dirName + "</span></td>";
    row += "<td>" + formatBytes(item.size) + "</td>";
    row += "<td style='text-align: right;'>";
    row += "<a href='/get?file=" + item.path + "' class='btn-action btn-dl'>Download</a>";

    if (item.isProtected) {
      row += "<span class='badge-protected'>🔒 Protected</span>";
    } else {
      row += "<a href='/delete?file=" + item.path + "' class='btn-action btn-del' onclick=\"return confirm('Delete " + baseName + "?');\">Delete</a>";
    }

    row += "</td></tr>";
    server.sendContent(row);
  }

  if (items.empty()) {
    server.sendContent("<tr><td colspan='3' style='text-align: center; color: #64748b; padding: 24px;'>No files found on storage. Upload one above!</td></tr>");
  }

  server.sendContent("</table></div>");
  server.sendContent(FPSTR(NAS_PAGE_FOOTER));
}

// High-Throughput 4KB Sector-Aligned SD Write Buffer
#define UPLOAD_SECTOR_BUFFER_SIZE 4096
static uint8_t uploadWriteBuffer[UPLOAD_SECTOR_BUFFER_SIZE];
static size_t uploadWriteBufferIndex = 0;

// Route: File Upload Handler (Streaming Multipart Parser with Sector-Aligned Buffering)
void handleFileUpload() {
  HTTPUpload& upload = server.upload();

  if (upload.status == UPLOAD_FILE_START) {
    uploadWriteBufferIndex = 0;
    String filename = upload.filename;
    int slashIdx = filename.lastIndexOf('/');
    if (slashIdx >= 0) filename = filename.substring(slashIdx + 1);
    int bslashIdx = filename.lastIndexOf('\\');
    if (bslashIdx >= 0) filename = filename.substring(bslashIdx + 1);

    if (!SD.exists("/uploads")) {
      SD.mkdir("/uploads");
    }
    String targetPath = "/uploads/" + filename;
    Serial.printf("[UPLOAD START] Destination: %s\n", targetPath.c_str());
    uploadFile = SD.open(targetPath, FILE_WRITE);
  } else if (upload.status == UPLOAD_FILE_WRITE) {
    if (uploadFile) {
      size_t bytesLeft = upload.currentSize;
      size_t srcOffset = 0;

      while (bytesLeft > 0) {
        size_t spaceInBuffer = UPLOAD_SECTOR_BUFFER_SIZE - uploadWriteBufferIndex;
        size_t toCopy = (bytesLeft < spaceInBuffer) ? bytesLeft : spaceInBuffer;

        memcpy(uploadWriteBuffer + uploadWriteBufferIndex, upload.buf + srcOffset, toCopy);
        uploadWriteBufferIndex += toCopy;
        srcOffset += toCopy;
        bytesLeft -= toCopy;

        // Flush in full 4096-byte blocks to minimize FAT sector allocation overhead
        if (uploadWriteBufferIndex == UPLOAD_SECTOR_BUFFER_SIZE) {
          uploadFile.write(uploadWriteBuffer, UPLOAD_SECTOR_BUFFER_SIZE);
          uploadWriteBufferIndex = 0;
        }
      }
    }
  } else if (upload.status == UPLOAD_FILE_END) {
    if (uploadFile) {
      if (uploadWriteBufferIndex > 0) {
        uploadFile.write(uploadWriteBuffer, uploadWriteBufferIndex);
        uploadWriteBufferIndex = 0;
      }
      uploadFile.flush();
      uploadFile.close();
      Serial.printf("[UPLOAD SUCCESS] Wrote %u bytes.\n", upload.totalSize);
    }
  } else if (upload.status == UPLOAD_FILE_ABORTED) {
    if (uploadFile) {
      uploadWriteBufferIndex = 0;
      uploadFile.close();
      Serial.println("[UPLOAD ABORTED]");
    }
  }
}

// Route: File Deletion Handler (Rejects protected default files)
void handleDelete() {
  if (!server.hasArg("file")) {
    server.send(400, "text/plain", "Missing file parameter");
    return;
  }

  String target = server.arg("file");
  if (!target.startsWith("/")) target = "/" + target;

  // Block attempts to delete protected system files
  if (isProtectedPath(target)) {
    Serial.printf("[SECURITY BLOCKED] Deletion rejected for protected file: %s\n", target.c_str());
    server.send(403, "text/plain", "Forbidden: Default system files are write-protected and cannot be deleted.");
    return;
  }

  bool removed = false;
  if (SD.exists(target)) {
    SD.remove(target);
    removed = true;
    Serial.printf("[STORAGE] Deleted: %s\n", target.c_str());
  } else {
    String uploadPath = "/uploads" + target;
    if (SD.exists(uploadPath)) {
      SD.remove(uploadPath);
      removed = true;
      Serial.printf("[STORAGE] Deleted: %s\n", uploadPath.c_str());
    }
  }

  if (!removed) {
    Serial.printf("[STORAGE WARN] File not found for deletion: %s\n", target.c_str());
  }

  // Redirect back to dashboard
  server.sendHeader("Location", "/");
  server.send(303);
}

// Route: Static Web Host (Streams /www/index.html from SD card)
void handleSite() {
  if (SD.exists("/www/index.html")) {
    File htmlFile = SD.open("/www/index.html", FILE_READ);
    server.streamFile(htmlFile, "text/html");
    htmlFile.close();
  } else {
    server.send(404, "text/plain", "Static Site Not Found on MicroSD (/www/index.html)");
  }
}

// Route: File Download Stream
void handleDownload() {
  if (!server.hasArg("file")) {
    server.send(400, "text/plain", "Missing file parameter");
    return;
  }

  String req = server.arg("file");
  if (!req.startsWith("/")) req = "/" + req;

  String resolvedPath = "";
  if (SD.exists(req)) {
    resolvedPath = req;
  } else if (SD.exists("/default" + req)) {
    resolvedPath = "/default" + req;
  } else if (SD.exists("/www" + req)) {
    resolvedPath = "/www" + req;
  } else if (SD.exists("/uploads" + req)) {
    resolvedPath = "/uploads" + req;
  }

  if (resolvedPath.length() == 0) {
    server.send(404, "text/plain", "File Not Found on Storage");
    return;
  }

  File downloadFile = SD.open(resolvedPath, FILE_READ);
  int lastSlash = resolvedPath.lastIndexOf('/');
  String dlName = (lastSlash >= 0) ? resolvedPath.substring(lastSlash + 1) : resolvedPath;
  server.sendHeader("Content-Disposition", "attachment; filename=\"" + dlName + "\"");
  server.streamFile(downloadFile, "application/octet-stream");
  downloadFile.close();
}

// Background Self-Diagnostics on Core 1
void runClientTests(void * parameter) {
  vTaskDelay(4000 / portTICK_PERIOD_MS);

  HTTPClient http;
  Serial.println("\n==================================================");
  Serial.println("  [PHASE 2 AUTO-TEST] Running Network Diagnostics ");
  Serial.println("==================================================");

  // Test 1: Dashboard explorer
  http.begin("http://127.0.0.1/");
  int code = http.GET();
  Serial.printf("[TEST 1: Root Explorer] Response: %d\n", code);
  http.end();

  // Test 2: Static site stream
  http.begin("http://127.0.0.1/site");
  code = http.GET();
  Serial.printf("[TEST 2: Static Host /site] Response: %d\n", code);
  http.end();

  // Test 3: Download default asset
  http.begin("http://127.0.0.1/get?file=lab_report.txt");
  code = http.GET();
  Serial.printf("[TEST 3: Download /get] Response: %d\n", code);
  http.end();

  // Test 4: Verify default files are protected against deletion
  http.begin("http://127.0.0.1/delete?file=/default/lab_report.txt");
  code = http.GET();
  Serial.printf("[TEST 4: Delete Protection] Response: %d (Expected: 403 Forbidden)\n", code);
  http.end();

  Serial.println("==================================================\n");
  vTaskDelete(NULL);
}

// ============================================================================
// SYSTEM INITIALIZATION & MAIN LOOP
// ============================================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  // Mount SD card & seed initial files
  if (!phase1_initStorage()) {
    Serial.println("[ABORT] Cannot proceed without storage.");
    return;
  }

  // Connect to virtual Wi-Fi (explicit STA mode + channel 6 skips slow multi-channel scan in Wokwi)
  WiFi.mode(WIFI_STA);
  Serial.printf("[NET] Connecting to Wi-Fi SSID: %s (ch 6)...", ssid);
  WiFi.begin(ssid, password, 6);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
    attempts++;
    if (attempts % 50 == 0) {
      Serial.printf("\n[NET WARN] Still waiting for Wi-Fi (status=%d). Ensure wokwigw.exe is running on ws://localhost:9011 before starting Wokwi.\n",
                    (int)WiFi.status());
      WiFi.disconnect(false);
      WiFi.begin(ssid, password, 6);
    }
  }
  Serial.println("\n[NET] Wi-Fi Connected!");
  Serial.printf("[NET] Node IP Address: %s\n", WiFi.localIP().toString().c_str());

  // Bind WebServer Routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/site", HTTP_GET, handleSite);
  server.on("/get", HTTP_GET, handleDownload);
  server.on("/delete", HTTP_GET, handleDelete);

  // Bind Upload handler: completion callback + streaming upload callback
  server.on("/upload", HTTP_POST, []() {
    server.sendHeader("Connection", "close");
    server.send(200, "text/html", "<script>window.location.href='/';</script>OK");
  }, handleFileUpload);

  server.begin();
  Serial.println("[HTTP] Server listening on port 80 with File Upload enabled.");

  // Launch background diagnostics on Core 1
  xTaskCreatePinnedToCore(runClientTests, "ClientTest", 6144, NULL, 1, NULL, 1);
}

void loop() {
  server.handleClient();
}
