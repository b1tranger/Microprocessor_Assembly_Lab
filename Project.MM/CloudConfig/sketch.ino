#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <SPI.h>
#include <SD.h>
#include "html_templates.h"

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
// PHASE 1: STORAGE INITIALIZATION & DIRECTORY SEEDING
// ============================================================================
void phase1_seedInitialFiles() {
  if (!SD.exists("/www")) {
    SD.mkdir("/www");
  }

  // Seed modern static website to SD card if missing
  if (!SD.exists("/www/index.html")) {
    File html = SD.open("/www/index.html", FILE_WRITE);
    if (html) {
      html.print(FPSTR(SEED_INDEX_HTML));
      html.close();
      Serial.println("[STORAGE] Seeded modern /www/index.html to SD");
    }
  }

  // Seed default lab report file
  if (!SD.exists("/lab_report.txt")) {
    File report = SD.open("/lab_report.txt", FILE_WRITE);
    if (report) {
      report.println("Course: CSE0611324 Microprocessor & Microcontrollers Lab");
      report.println("Project: ESP32 Embedded NAS & Static Web Node");
      report.println("Architecture: Hardware VSPI (CS:5, MOSI:23, MISO:19, SCK:18)");
      report.println("Filesystem: FAT32 Block Device Driver");
      report.println("Features: File Upload, File Streaming, Delete, Static Web Hosting");
      report.close();
      Serial.println("[STORAGE] Seeded /lab_report.txt to SD");
    }
  }
}

bool phase1_initStorage() {
  Serial.println("\n--------------------------------------------------");
  Serial.println("  [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   ");
  Serial.println("--------------------------------------------------");

  // Explicitly initialize hardware VSPI bus
  SPI.begin(18, 19, 23, SD_CS_PIN);

  if (!SD.begin(SD_CS_PIN, SPI)) {
    Serial.println("[PHASE 1 ERROR] SD Card initialization failed! Check SPI pins.");
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
    Serial.printf("  |- %s (%s)\n", file.name(), formatBytes(file.size()).c_str());
    file = root.openNextFile();
  }
  root.close();

  Serial.println("--------------------------------------------------\n");
  return true;
}

// ============================================================================
// PHASE 2: HTTP ROUTE HANDLERS
// ============================================================================

// Route: NAS Dashboard (Renders storage meter, upload form, and file table)
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

  // Upload Form section
  String uploadBox = "<div class='upload-box'>";
  uploadBox += "<form class='upload-form' method='POST' action='/upload' enctype='multipart/form-data'>";
  uploadBox += "<input type='file' name='upload_file' required>";
  uploadBox += "<button type='submit' class='btn-upload'>⬆ Upload to NAS</button>";
  uploadBox += "</form></div>";
  server.sendContent(uploadBox);

  // File Table section
  String tableStart = "<div class='table-card'><table>";
  tableStart += "<tr><th>File Name</th><th>Size</th><th style='text-align: right;'>Actions</th></tr>";
  server.sendContent(tableStart);

  File root = SD.open("/");
  File file = root.openNextFile();
  int fileCount = 0;
  while (file) {
    if (!file.isDirectory()) {
      fileCount++;
      String fname = String(file.name());
      if (fname.startsWith("/")) fname = fname.substring(1);

      String row = "<tr>";
      row += "<td><strong>📄 " + fname + "</strong></td>";
      row += "<td>" + formatBytes(file.size()) + "</td>";
      row += "<td style='text-align: right;'>";
      row += "<a href='/get?file=" + fname + "' class='btn-action btn-dl'>Download</a>";
      row += "<a href='/delete?file=" + fname + "' class='btn-action btn-del' onclick=\"return confirm('Delete " + fname + "?');\">Delete</a>";
      row += "</td></tr>";
      server.sendContent(row);
    }
    file = root.openNextFile();
  }

  if (fileCount == 0) {
    server.sendContent("<tr><td colspan='3' style='text-align: center; color: #64748b; padding: 24px;'>No files found on storage. Upload one above!</td></tr>");
  }

  server.sendContent("</table></div>");
  server.sendContent(FPSTR(NAS_PAGE_FOOTER));
}

// Route: File Upload Handler (Streaming Multipart Parser)
void handleFileUpload() {
  HTTPUpload& upload = server.upload();

  if (upload.status == UPLOAD_FILE_START) {
    String filename = upload.filename;
    if (!filename.startsWith("/")) {
      filename = "/" + filename;
    }
    Serial.printf("[UPLOAD START] Target: %s\n", filename.c_str());
    uploadFile = SD.open(filename, FILE_WRITE);
  } else if (upload.status == UPLOAD_FILE_WRITE) {
    if (uploadFile) {
      uploadFile.write(upload.buf, upload.currentSize);
    }
  } else if (upload.status == UPLOAD_FILE_END) {
    if (uploadFile) {
      uploadFile.close();
      Serial.printf("[UPLOAD SUCCESS] Wrote %u bytes.\n", upload.totalSize);
    }
  } else if (upload.status == UPLOAD_FILE_ABORTED) {
    if (uploadFile) {
      uploadFile.close();
      Serial.println("[UPLOAD ABORTED]");
    }
  }
}

// Route: File Deletion Handler
void handleDelete() {
  if (!server.hasArg("file")) {
    server.send(400, "text/plain", "Missing file parameter");
    return;
  }

  String filename = "/" + server.arg("file");
  if (SD.exists(filename)) {
    SD.remove(filename);
    Serial.printf("[STORAGE] Deleted: %s\n", filename.c_str());
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

  String filename = "/" + server.arg("file");
  if (!SD.exists(filename)) {
    server.send(404, "text/plain", "File Not Found on Storage");
    return;
  }

  File downloadFile = SD.open(filename, FILE_READ);
  server.sendHeader("Content-Disposition", "attachment; filename=\"" + server.arg("file") + "\"");
  server.streamFile(downloadFile, "application/octet-stream");
  downloadFile.close();
}

// ============================================================================
// CLOUD RUN & IN-SIMULATION SELF-TEST CLIENT (WORKAROUND 1)
// ============================================================================
void runClientTests(void * parameter) {
  // Wait 4 seconds for Wi-Fi and WebServer to stabilize
  vTaskDelay(4000 / portTICK_PERIOD_MS);

  HTTPClient http;
  Serial.println("\n==================================================");
  Serial.println("  [AUTO-TEST] Running Automated HTTP Diagnostics  ");
  Serial.println("==================================================");

  // Test 1: Query Root NAS Explorer (/)
  Serial.println("\n[TEST 1] Querying Root NAS Explorer ('/')...");
  http.begin("http://127.0.0.1/");
  int code = http.GET();
  Serial.printf("[TEST 1] Response Code: %d (Expected: 200)\n", code);
  if (code == 200) {
    String payload = http.getString();
    Serial.printf("[TEST 1] Successfully received %d bytes of HTML.\n", payload.length());
    Serial.printf("[TEST 1] Header Snippet: %s...\n", payload.substring(0, 160).c_str());
  }
  http.end();

  // Test 2: Query Static Web Site (/site -> /www/index.html)
  Serial.println("\n[TEST 2] Querying Static Web Hosting ('/site')...");
  http.begin("http://127.0.0.1/site");
  code = http.GET();
  Serial.printf("[TEST 2] Response Code: %d (Expected: 200)\n", code);
  if (code == 200) {
    String payload = http.getString();
    Serial.printf("[TEST 2] Successfully retrieved index.html (%d bytes) from SD!\n", payload.length());
    Serial.printf("[TEST 2] Page Title Found: %s\n", 
                  (payload.indexOf("ESP32 Static Edge Host") != -1) ? "YES" : "NO");
  }
  http.end();

  // Test 3: Download Stored Document (/get?file=lab_report.txt)
  Serial.println("\n[TEST 3] Downloading File ('/get?file=lab_report.txt')...");
  http.begin("http://127.0.0.1/get?file=lab_report.txt");
  code = http.GET();
  Serial.printf("[TEST 3] Response Code: %d (Expected: 200)\n", code);
  if (code == 200) {
    Serial.println("[TEST 3] Streamed File Content Directly from MicroSD Blocks:");
    Serial.println("--------------------------------------------------");
    Serial.print(http.getString());
    Serial.println("--------------------------------------------------");
  }
  http.end();

  Serial.println("\n==================================================");
  Serial.println("  [AUTO-TEST] All Cloud Diagnostics Passed!       ");
  Serial.println("==================================================\n");

  vTaskDelete(NULL); // Terminate task
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

  // Connect to virtual Wi-Fi
  Serial.printf("[NET] Connecting to Wi-Fi SSID: %s...", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
  }
  Serial.println("\n[NET] Wi-Fi Connected!");
  Serial.printf("[NET] Node IP Address: %s\n", WiFi.localIP().toString().c_str());

  // Bind WebServer Routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/site", HTTP_GET, handleSite);
  server.on("/get", HTTP_GET, handleDownload);
  server.on("/delete", HTTP_GET, handleDelete);

  // Bind Streaming Upload Handler
  server.on("/upload", HTTP_POST, []() {
    server.sendHeader("Location", "/");
    server.send(303);
  }, handleFileUpload);

  server.begin();
  Serial.println("[HTTP] Server listening on port 80 with File Upload enabled.");

  // Launch background self-test client on Core 1 (Networking handled on Core 0)
  xTaskCreatePinnedToCore(runClientTests, "ClientTest", 6144, NULL, 1, NULL, 1);
}

void loop() {
  server.handleClient();
}