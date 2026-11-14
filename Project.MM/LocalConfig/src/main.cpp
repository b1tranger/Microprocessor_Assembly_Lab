#include "default_assets.h"
#include "html_templates.h"
#include <Arduino.h>
#include <HTTPClient.h>
#include <SD.h>
#include <SPI.h>
#include <WebServer.h>
#include <WiFi.h>
#include <vector>

// Hardware SPI Chip Select pin mapped to GPIO 5
#define SD_CS_PIN 5

// Wokwi virtual Wi-Fi access point credentials
const char *ssid = "Wokwi-GUEST";
const char *password = "";

WebServer server(80);
File uploadFile;

// --- Unit Formatting Helper ---
String formatBytes(size_t bytes) {
  if (bytes < 1024)
    return String(bytes) + " B";
  if (bytes < (1024 * 1024))
    return String(bytes / 1024.0, 1) + " KB";
  return String(bytes / (1024.0 * 1024.0), 1) + " MB";
}

// ============================================================================
// SECURITY & FILE PROTECTION SYSTEM
// ============================================================================
bool isProtectedPath(const String &rawPath) {
  String p = rawPath;
  if (!p.startsWith("/"))
    p = "/" + p;

  // Direct default root mirrors or folders
  if (p == "/lab_report.txt")
    return true;
  if (p.startsWith("/default/") || p == "/default")
    return true;
  if (p.startsWith("/www/") || p == "/www")
    return true;

  // Match against all registered embedded assets
  for (size_t i = 0; i < EMBEDDED_ASSET_COUNT; i++) {
    if (p == EMBEDDED_ASSETS[i].sdPath && EMBEDDED_ASSETS[i].isProtected) {
      return true;
    }
  }
  return false;
}

void ensureParentDir(const String &path) {
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
  if (!SD.exists("/default"))
    SD.mkdir("/default");
  if (!SD.exists("/www"))
    SD.mkdir("/www");
  if (!SD.exists("/uploads"))
    SD.mkdir("/uploads");

  // Dynamically seed all embedded assets from data/ folder
  for (size_t i = 0; i < EMBEDDED_ASSET_COUNT; i++) {
    const EmbeddedAsset &asset = EMBEDDED_ASSETS[i];
    ensureParentDir(asset.sdPath);

    bool needsSeed = !SD.exists(asset.sdPath);
    if (!needsSeed) {
      File checkF = SD.open(asset.sdPath, FILE_READ);
      if (checkF) {
        if (checkF.size() == 0)
          needsSeed = true;
        checkF.close();
      }
    }

    if (needsSeed) {
      if (SD.exists(asset.sdPath)) {
        SD.remove(asset.sdPath);
      }
      File f = SD.open(asset.sdPath, FILE_WRITE);
      if (f) {
        f.write(asset.data, asset.size);
        f.flush();
        f.close();
        Serial.printf("[STORAGE] Seeded %s (%u bytes)\n", asset.sdPath,
                      (unsigned int)asset.size);
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
      Serial.println("[STORAGE] Mirrored /default/lab_report.txt to "
                     "/lab_report.txt for compatibility");
    }
  }
}

bool phase1_initStorage() {
  Serial.println("\n--------------------------------------------------");
  Serial.println("  [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   ");
  Serial.println("--------------------------------------------------");

  // Explicitly initialize hardware VSPI bus
  SPI.begin(18, 19, 23, SD_CS_PIN);

  // Initialize SD with reliable 4 MHz SPI clock (standard for VSPI & Wokwi simulation)
  if (!SD.begin(SD_CS_PIN, SPI, 4000000)) {
    Serial.println(
        "\r\n[PHASE 1 ERROR] SD Card initialization failed! Check SPI pins.");
    return false;
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
      Serial.printf("  [FILE] /%s (%s)\n", file.name(),
                    formatBytes(file.size()).c_str());
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

void collectFilesRecursively(File dir, std::vector<StorageItem> &items,
                             int depth = 0) {
  if (!dir || !dir.isDirectory() || depth > 3)
    return;

  File file = dir.openNextFile();
  while (file) {
    if (file.isDirectory()) {
      collectFilesRecursively(file, items, depth + 1);
    } else {
      String fullPath = String(file.name());
      if (!fullPath.startsWith("/"))
        fullPath = "/" + fullPath;

      // Skip root /lab_report.txt if /default/lab_report.txt exists to avoid
      // duplicate rows
      if (fullPath == "/lab_report.txt" &&
          SD.exists("/default/lab_report.txt")) {
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

// Route: NAS Dashboard (Streams /www/fileserver.html directly from MicroSD
// storage)
void handleRoot() {
  if (SD.exists("/www/fileserver.html")) {
    File htmlFile = SD.open("/www/fileserver.html", FILE_READ);
    if (htmlFile && htmlFile.size() > 0) {
      server.streamFile(htmlFile, "text/html");
      htmlFile.close();
      return;
    }
    if (htmlFile)
      htmlFile.close();
  }

  // Self-healing fallback: re-seed from Flash ROM if missing or 0 bytes
  for (size_t i = 0; i < EMBEDDED_ASSET_COUNT; i++) {
    if (String(EMBEDDED_ASSETS[i].sdPath) == "/www/fileserver.html") {
      ensureParentDir("/www/fileserver.html");
      if (SD.exists("/www/fileserver.html")) {
        SD.remove("/www/fileserver.html");
      }
      File f = SD.open("/www/fileserver.html", FILE_WRITE);
      if (f) {
        f.write(EMBEDDED_ASSETS[i].data, EMBEDDED_ASSETS[i].size);
        f.flush();
        f.close();
        File htmlFile = SD.open("/www/fileserver.html", FILE_READ);
        if (htmlFile && htmlFile.size() > 0) {
          server.streamFile(htmlFile, "text/html");
          htmlFile.close();
          return;
        }
        if (htmlFile)
          htmlFile.close();
      }
      // Direct Flash ROM fallback if SD write failed
      server.send_P(200, "text/html", (PGM_P)EMBEDDED_ASSETS[i].data,
                    EMBEDDED_ASSETS[i].size);
      return;
    }
  }

  server.send(
      404, "text/plain",
      "File Server Interface Not Found on MicroSD (/www/fileserver.html)");
}

// Route: API Endpoint to return live storage stats and file directory in JSON
// format
void handleApiFiles() {
  uint64_t total = SD.totalBytes();
  uint64_t used = SD.usedBytes();
  float usedPercent =
      (total > 0) ? ((float)used / (float)total) * 100.0f : 0.0f;

  std::vector<StorageItem> items;
  File root = SD.open("/");
  collectFilesRecursively(root, items);
  root.close();

  String json = "{";
  json += "\"total\":" + String((unsigned long long)total) + ",";
  json += "\"used\":" + String((unsigned long long)used) + ",";
  json += "\"totalFormatted\":\"" + formatBytes(total) + "\",";
  json += "\"usedFormatted\":\"" + formatBytes(used) + "\",";
  json += "\"usedPercent\":" + String(usedPercent, 1) + ",";
  json += "\"files\":[";

  for (size_t i = 0; i < items.size(); i++) {
    const auto &item = items[i];
    int lastSlash = item.path.lastIndexOf('/');
    String dirName = (lastSlash > 0) ? item.path.substring(0, lastSlash) : "/";
    String baseName =
        (lastSlash >= 0) ? item.path.substring(lastSlash + 1) : item.path;

    if (i > 0)
      json += ",";
    json += "{";
    json += "\"path\":\"" + item.path + "\",";
    json += "\"name\":\"" + baseName + "\",";
    json += "\"dir\":\"" + dirName + "\",";
    json += "\"size\":" + String(item.size) + ",";
    json += "\"sizeFormatted\":\"" + formatBytes(item.size) + "\",";
    json += "\"isProtected\":" + String(item.isProtected ? "true" : "false");
    json += "}";
  }
  json += "]}";

  server.send(200, "application/json", json);
}

// High-Throughput 4KB Sector-Aligned SD Write Buffer
#define UPLOAD_SECTOR_BUFFER_SIZE 4096
static uint8_t uploadWriteBuffer[UPLOAD_SECTOR_BUFFER_SIZE];
static size_t uploadWriteBufferIndex = 0;
static bool uploadWriteError = false;

// Static Upload State Tracker
static String currentUploadTarget = "";

// Route: File Upload Handler (Streaming Multipart Parser with Sector-Aligned Buffering)
void handleFileUpload() {
  HTTPUpload &upload = server.upload();

  if (upload.status == UPLOAD_FILE_START) {
    uploadWriteBufferIndex = 0;
    uploadWriteError = false;

    String filename = upload.filename;
    int slashIdx = filename.lastIndexOf('/');
    if (slashIdx >= 0)
      filename = filename.substring(slashIdx + 1);
    int bslashIdx = filename.lastIndexOf('\\');
    if (bslashIdx >= 0)
      filename = filename.substring(bslashIdx + 1);

    // Sanitize punctuation and illegal FAT32 characters
    String cleanFilename = "";
    for (size_t i = 0; i < filename.length(); i++) {
      char c = filename[i];
      if (c == '\'' || c == '\"' || c == '?' || c == '*' || c == ':' ||
          c == '|' || c == '<' || c == '>') {
        cleanFilename += '_';
      } else {
        cleanFilename += c;
      }
    }
    filename = cleanFilename;

    if (!SD.exists("/uploads")) {
      SD.mkdir("/uploads");
    }
    currentUploadTarget = "/uploads/" + filename;

    // Purge any stale existing file to ensure clean cluster allocation
    if (SD.exists(currentUploadTarget)) {
      SD.remove(currentUploadTarget);
    }

    uploadFile = SD.open(currentUploadTarget, FILE_WRITE);
    if (!uploadFile) {
      uploadWriteError = true;
      Serial.printf("[UPLOAD ERROR] Failed to create destination file: %s\r\n",
                    currentUploadTarget.c_str());
    } else {
      Serial.printf("[UPLOAD START] Destination: %s\r\n", currentUploadTarget.c_str());
    }
  } else if (upload.status == UPLOAD_FILE_WRITE) {
    if (uploadFile && !uploadWriteError && upload.currentSize > 0) {
      size_t bytesLeft = upload.currentSize;
      size_t srcOffset = 0;

      while (bytesLeft > 0 && !uploadWriteError) {
        size_t spaceInBuffer = UPLOAD_SECTOR_BUFFER_SIZE - uploadWriteBufferIndex;
        size_t toCopy = (bytesLeft < spaceInBuffer) ? bytesLeft : spaceInBuffer;

        memcpy(uploadWriteBuffer + uploadWriteBufferIndex, upload.buf + srcOffset, toCopy);
        uploadWriteBufferIndex += toCopy;
        srcOffset += toCopy;
        bytesLeft -= toCopy;

        // Flush in full 4096-byte blocks to match FAT32 sector alignment
        if (uploadWriteBufferIndex == UPLOAD_SECTOR_BUFFER_SIZE) {
          size_t written = uploadFile.write(uploadWriteBuffer, UPLOAD_SECTOR_BUFFER_SIZE);
          if (written != UPLOAD_SECTOR_BUFFER_SIZE) {
            uploadWriteError = true;
            Serial.printf("[UPLOAD ERROR] Sector write failed: %u / %u bytes written. Aborting.\r\n",
                          (unsigned int)written, (unsigned int)UPLOAD_SECTOR_BUFFER_SIZE);
            break;
          }
          uploadWriteBufferIndex = 0;
        }
      }
    }
  } else if (upload.status == UPLOAD_FILE_END) {
    if (uploadFile) {
      if (!uploadWriteError && uploadWriteBufferIndex > 0) {
        size_t written = uploadFile.write(uploadWriteBuffer, uploadWriteBufferIndex);
        if (written != uploadWriteBufferIndex) {
          uploadWriteError = true;
          Serial.printf("[UPLOAD ERROR] Final sector flush failed: %u / %u bytes written.\r\n",
                        (unsigned int)written, (unsigned int)uploadWriteBufferIndex);
        }
        uploadWriteBufferIndex = 0;
      }
      uploadFile.flush();
      uploadFile.close();

      if (!uploadWriteError) {
        Serial.printf("[UPLOAD SUCCESS] Path: %s | Wrote: %u bytes\r\n",
                      currentUploadTarget.c_str(), (unsigned int)upload.totalSize);
      } else {
        Serial.printf("[UPLOAD FAILED] Write error encountered during transmission.\r\n");
        if (currentUploadTarget.length() > 0 && SD.exists(currentUploadTarget)) {
          SD.remove(currentUploadTarget);
          Serial.printf("[UPLOAD PURGED] Removed incomplete file: %s\r\n", currentUploadTarget.c_str());
        }
      }
    }
    uploadWriteBufferIndex = 0;
    currentUploadTarget = "";
  } else if (upload.status == UPLOAD_FILE_ABORTED) {
    uploadWriteBufferIndex = 0;
    if (uploadFile) {
      uploadFile.close();
      Serial.println("[UPLOAD ABORTED]\r\n");
    }
    if (currentUploadTarget.length() > 0 && SD.exists(currentUploadTarget)) {
      SD.remove(currentUploadTarget);
      Serial.printf("[UPLOAD ABORTED] Purged incomplete corrupted file: %s\r\n",
                    currentUploadTarget.c_str());
    }
    currentUploadTarget = "";
  }
}

// Route: File Deletion Handler (Rejects protected default files)
void handleDelete() {
  if (!server.hasArg("file")) {
    server.send(400, "text/plain", "Missing file parameter");
    return;
  }

  String target = server.arg("file");
  if (!target.startsWith("/"))
    target = "/" + target;

  // Block attempts to delete protected system files
  if (isProtectedPath(target)) {
    Serial.printf(
        "[SECURITY BLOCKED] Deletion rejected for protected file: %s\n",
        target.c_str());
    server.send(403, "text/plain",
                "Forbidden: Default system files are write-protected and "
                "cannot be deleted.");
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
    Serial.printf("[STORAGE WARN] File not found for deletion: %s\n",
                  target.c_str());
  }

  // Redirect back to dashboard
  server.sendHeader("Location", "/");
  server.send(303);
}

// Route: Static Web Host (Streams /www/index.html from SD card)
void handleSite() {
  if (SD.exists("/www/index.html")) {
    File htmlFile = SD.open("/www/index.html", FILE_READ);
    if (htmlFile && htmlFile.size() > 0) {
      server.streamFile(htmlFile, "text/html");
      htmlFile.close();
      return;
    }
    if (htmlFile)
      htmlFile.close();
  }

  // Self-healing fallback: re-seed from Flash ROM if missing or 0 bytes
  for (size_t i = 0; i < EMBEDDED_ASSET_COUNT; i++) {
    if (String(EMBEDDED_ASSETS[i].sdPath) == "/www/index.html") {
      ensureParentDir("/www/index.html");
      if (SD.exists("/www/index.html")) {
        SD.remove("/www/index.html");
      }
      File f = SD.open("/www/index.html", FILE_WRITE);
      if (f) {
        f.write(EMBEDDED_ASSETS[i].data, EMBEDDED_ASSETS[i].size);
        f.flush();
        f.close();
        File htmlFile = SD.open("/www/index.html", FILE_READ);
        if (htmlFile && htmlFile.size() > 0) {
          server.streamFile(htmlFile, "text/html");
          htmlFile.close();
          return;
        }
        if (htmlFile)
          htmlFile.close();
      }
      // Direct Flash ROM fallback if SD write failed
      server.send_P(200, "text/html", (PGM_P)EMBEDDED_ASSETS[i].data,
                    EMBEDDED_ASSETS[i].size);
      return;
    }
  }

  server.send(404, "text/plain",
              "Static Site Not Found on MicroSD (/www/index.html)");
}

// Route: File Download Stream
void handleDownload() {
  if (!server.hasArg("file")) {
    server.send(400, "text/plain", "Missing file parameter");
    return;
  }

  String req = server.arg("file");
  if (!req.startsWith("/"))
    req = "/" + req;

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
  String dlName =
      (lastSlash >= 0) ? resolvedPath.substring(lastSlash + 1) : resolvedPath;
  server.sendHeader("Content-Disposition",
                    "attachment; filename=\"" + dlName + "\"");
  server.streamFile(downloadFile, "application/octet-stream");
  downloadFile.close();
}

// Helper function for reliable diagnostic requests in virtual simulation
static int performTestRequest(const String &url) {
  HTTPClient http;
  http.setReuse(false);
  http.setTimeout(8000);
  if (!http.begin(url)) {
    return -99;
  }
  int code = http.GET();
  // Fully drain the response stream to ensure graceful socket teardown
  WiFiClient *stream = http.getStreamPtr();
  if (stream) {
    uint8_t dummy[256];
    while (http.connected() && stream->available() > 0) {
      stream->read(dummy, sizeof(dummy));
    }
  }
  http.end();
  // Yield to loopTask on Core 1 to allow WebServer to complete TCP close & rearm
  vTaskDelay(800 / portTICK_PERIOD_MS);
  return code;
}

// Background Self-Diagnostics on Core 1
void runClientTests(void *parameter) {
  vTaskDelay(4000 / portTICK_PERIOD_MS);

  Serial.println("\r\n==================================================");
  Serial.println("  [PHASE 2 AUTO-TEST] Running Network Diagnostics ");
  Serial.println("==================================================");

  // Test 1: Dashboard explorer
  int code = performTestRequest("http://127.0.0.1/");
  Serial.printf("[TEST 1: Root Explorer] Response: %d\r\n", code);

  // Test 2: Static site stream
  code = performTestRequest("http://127.0.0.1/site");
  Serial.printf("[TEST 2: Static Host /site] Response: %d\r\n", code);

  // Test 3: Download default asset
  code = performTestRequest("http://127.0.0.1/get?file=lab_report.txt");
  Serial.printf("[TEST 3: Download /get] Response: %d\r\n", code);

  // Test 4: Verify default files are protected against deletion
  code = performTestRequest("http://127.0.0.1/delete?file=/default/lab_report.txt");
  Serial.printf(
      "[TEST 4: Delete Protection] Response: %d (Expected: 403 Forbidden)\r\n",
      code);

  // Test 5: Verify JSON files API
  code = performTestRequest("http://127.0.0.1/api/files");
  Serial.printf("[TEST 5: API /api/files] Response: %d\r\n", code);

  Serial.println("==================================================\r\n");
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

  // Connect to virtual Wi-Fi (explicit STA mode + channel 6 skips slow
  // multi-channel scan in Wokwi)
  WiFi.mode(WIFI_STA);
  Serial.printf("[NET] Connecting to Wi-Fi SSID: %s (ch 6)...", ssid);
  WiFi.begin(ssid, password, 6);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
    attempts++;
    if (attempts % 50 == 0) {
      Serial.printf("\n[NET WARN] Still waiting for Wi-Fi (status=%d). Ensure "
                    "wokwigw.exe is running on ws://localhost:9011 before "
                    "starting Wokwi.\n",
                    (int)WiFi.status());
      WiFi.disconnect(false);
      WiFi.begin(ssid, password, 6);
    }
  }
  Serial.println("\n[NET] Wi-Fi Connected!");
  Serial.printf("[NET] Node IP Address: %s\n",
                WiFi.localIP().toString().c_str());

  // Bind WebServer Routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/fileserver.html", HTTP_GET, handleRoot);
  server.on("/www/fileserver.html", HTTP_GET, handleRoot);
  server.on("/api/files", HTTP_GET, handleApiFiles);
  server.on("/site", HTTP_GET, handleSite);
  server.on("/index.html", HTTP_GET, handleSite);
  server.on("/www/index.html", HTTP_GET, handleSite);
  server.on("/get", HTTP_GET, handleDownload);
  server.on("/delete", HTTP_GET, handleDelete);

  // Bind Upload handler: completion callback + streaming upload callback
  server.on(
      "/upload", HTTP_POST,
      []() {
        HTTPUpload &upload = server.upload();
        server.sendHeader("Connection", "close");
        if (upload.status == UPLOAD_FILE_END && upload.totalSize > 0 && !uploadWriteError) {
          server.send(200, "application/json",
                      "{\"status\":\"ok\",\"bytes\":" + String((unsigned long)upload.totalSize) + "}");
        } else {
          server.send(500, "application/json",
                      "{\"status\":\"error\",\"message\":\"Upload aborted or incomplete payload received\"}");
        }
      },
      handleFileUpload);

  server.begin();
  Serial.println(
      "[HTTP] Server listening on port 80 with File Upload enabled.");

  // Launch background diagnostics on Core 1
  xTaskCreatePinnedToCore(runClientTests, "ClientTest", 6144, NULL, 1, NULL, 1);
}

void loop() { server.handleClient(); }
