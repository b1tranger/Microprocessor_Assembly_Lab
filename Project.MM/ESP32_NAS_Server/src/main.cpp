#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <SPI.h>
#include <SD.h>

// ============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>>> PHASE 1: HARDWARE & STORAGE CONFIG <<<<<<<<<<<<<<
// ============================================================================
// Hardware SPI Chip Select pin mapped to GPIO 5
#define SD_CS_PIN 5

// --- PHASE 1 STORAGE HELPER: Byte Unit Formatting ---
String formatBytes(size_t bytes) {
  if (bytes < 1024) return String(bytes) + " B";
  if (bytes < (1024 * 1024)) return String(bytes / 1024.0, 1) + " KB";
  return String(bytes / (1024.0 * 1024.0), 1) + " MB";
}

// --- PHASE 1 STORAGE INITIALIZER: Dynamic Block Device File Seeding ---
// Creates directory structures and files directly on the virtual FAT32 SD card
void phase1_seedInitialFiles() {
  if (!SD.exists("/www")) {
    SD.mkdir("/www");
  }
  
  if (!SD.exists("/www/index.html")) {
    File html = SD.open("/www/index.html", FILE_WRITE);
    if (html) {
      html.println("<!DOCTYPE html><html><head><meta charset='UTF-8'>");
      html.println("<title>ESP32 Web Server</title></head>");
      html.println("<body style='font-family:sans-serif; text-align:center; padding:30px; background:#f4f4f4;'>");
      html.println("<h1>Hosted on ESP32 MicroSD Storage</h1>");
      html.println("<p>Status: <strong>Online</strong></p>");
      html.println("<p>Dual-Purpose Node: Static Web Host Active</p>");
      html.println("<p><a href='/'>Go to NAS File Browser</a></p>");
      html.println("</body></html>");
      html.close();
      Serial.println("[PHASE 1 STORAGE] Seeded /www/index.html to block storage");
    }
  }

  if (!SD.exists("/lab_report.txt")) {
    File report = SD.open("/lab_report.txt", FILE_WRITE);
    if (report) {
      report.println("Course: CSE0611324 Microprocessor Lab");
      report.println("Status: Phase 1 Storage & Phase 2 Server Active.");
      report.println("Storage: FAT32 block device over SPI bus.");
      report.close();
      Serial.println("[PHASE 1 STORAGE] Seeded /lab_report.txt to block storage");
    }
  }
}

// --- PHASE 1 STORAGE FUNCTION: Mount and Inspect MicroSD Card ---
bool phase1_initStorage() {
  Serial.println("\n--------------------------------------------------");
  Serial.println("  [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   ");
  Serial.println("--------------------------------------------------");

  // Explicitly initialize hardware SPI bus (SCK=18, MISO=19, MOSI=23, SS=5)
  SPI.begin(18, 19, 23, SD_CS_PIN);

  // Initialize hardware SPI block storage driver on GPIO 5, 18, 19, 23
  if (!SD.begin(SD_CS_PIN, SPI)) {

    Serial.println("[PHASE 1 ERROR] SD Card initialization failed! Check SPI pins.");
    return false;
  }

  uint64_t totalBytes = SD.totalBytes();
  uint64_t usedBytes = SD.usedBytes();
  Serial.printf("[PHASE 1 SUCCESS] FAT32 Storage Mounted.\n");
  Serial.printf("[PHASE 1 CAPACITY] Total: %llu MB | Used: %llu MB\n", 
                totalBytes / (1024 * 1024), usedBytes / (1024 * 1024));

  // Populate files on storage block device
  phase1_seedInitialFiles();

  // Enumerate and print storage directory tree
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
// <<<<<<<<<<<<<<<<<<<<<<<< END OF PHASE 1 STORAGE LOGIC >>>>>>>>>>>>>>>>>>>>>>
// ============================================================================


// ============================================================================
// >>>>>>>>>>>>>>>>>>>>>> PHASE 2: NETWORKING & HTTP SERVER <<<<<<<<<<<<<<<<<<<
// ============================================================================
const char* ssid = "Wokwi-GUEST";
const char* password = "";

WebServer server(80);

// Phase 2 Route: NAS Web Dashboard (Uses Phase 1 SD read operations)
void handleRoot() {
  uint64_t total = SD.totalBytes();
  uint64_t used = SD.usedBytes();

  String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1.0'>";
  html += "<title>ESP32 NAS Node</title><style>";
  html += "body { font-family: monospace; background: #121212; color: #e0e0e0; padding: 20px; }";
  html += ".card { max-width: 650px; margin: auto; background: #1e1e1e; padding: 20px; border-radius: 8px; }";
  html += "table { width: 100%; border-collapse: collapse; margin-top: 15px; }";
  html += "th, td { border: 1px solid #333; padding: 8px; text-align: left; }";
  html += "th { background: #2a2a2a; }";
  html += "a { color: #64B5F6; text-decoration: none; }";
  html += "a:hover { text-decoration: underline; }";
  html += "</style></head><body><div class='card'>";
  html += "<h2>ESP32 Local Storage NAS</h2>";
  html += "<p><b>Capacity:</b> " + formatBytes(total) + " | <b>Used:</b> " + formatBytes(used) + "</p>";
  html += "<p><a href='/site'>View Hosted Static Website (/site)</a></p>";
  html += "<table><tr><th>File Name</th><th>Size</th><th>Action</th></tr>";

  // Phase 1 interaction: enumerate files for the web table
  File root = SD.open("/");
  File file = root.openNextFile();
  while (file) {
    if (!file.isDirectory()) {
      String fname = String(file.name());
      if (fname.startsWith("/")) fname = fname.substring(1);
      html += "<tr><td>" + fname + "</td>";
      html += "<td>" + formatBytes(file.size()) + "</td>";
      html += "<td><a href='/get?file=" + fname + "'>Download</a></td></tr>";
    }
    file = root.openNextFile();
  }
  html += "</table></div></body></html>";

  server.send(200, "text/html", html);
}

// Phase 2 Route: Static Web Host (Streams Phase 1 /www/index.html file)
void handleSite() {
  if (SD.exists("/www/index.html")) {
    File htmlFile = SD.open("/www/index.html", FILE_READ);
    server.streamFile(htmlFile, "text/html");
    htmlFile.close();
  } else {
    server.send(404, "text/plain", "Static Site Not Found");
  }
}

// Phase 2 Route: Chunked File Download (Streams Phase 1 SD blocks)
void handleDownload() {
  if (!server.hasArg("file")) {
    server.send(400, "text/plain", "Missing file parameter");
    return;
  }

  String filename = "/" + server.arg("file");
  if (!SD.exists(filename)) {
    server.send(404, "text/plain", "File Not Found");
    return;
  }

  File downloadFile = SD.open(filename, FILE_READ);
  server.sendHeader("Content-Disposition", "attachment; filename=\"" + server.arg("file") + "\"");
  server.streamFile(downloadFile, "application/octet-stream");
  downloadFile.close();
}

// Phase 2 Diagnostics: FreeRTOS task running on Core 1
void runClientTests(void * parameter) {
  vTaskDelay(4000 / portTICK_PERIOD_MS);

  HTTPClient http;
  Serial.println("\n==================================================");
  Serial.println("  [PHASE 2 AUTO-TEST] Running Network Diagnostics ");
  Serial.println("==================================================");

  // Test 1: NAS explorer route
  http.begin("http://127.0.0.1/");
  int code = http.GET();
  Serial.printf("[TEST 1: Root Explorer] Response: %d\n", code);
  http.end();

  // Test 2: Static site stream
  http.begin("http://127.0.0.1/site");
  code = http.GET();
  Serial.printf("[TEST 2: Static Host /site] Response: %d\n", code);
  if (code == 200) {
    Serial.println("[TEST 2 Streamed HTML]:\n" + http.getString());
  }
  http.end();

  // Test 3: Download seeded file
  http.begin("http://127.0.0.1/get?file=lab_report.txt");
  code = http.GET();
  Serial.printf("[TEST 3: Download /get] Response: %d\n", code);
  if (code == 200) {
    Serial.println("[TEST 3 Streamed Content]:\n" + http.getString());
  }
  http.end();

  Serial.println("==================================================\n");
  vTaskDelete(NULL);
}


// ============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>>>> SYSTEM INITIALIZATION <<<<<<<<<<<<<<<<<<<<<<<<<<
// ============================================================================
void setup() {
  Serial.begin(115200);
  delay(1000);

  // --------------------------------------------------------------------------
  // EXECUTE PHASE 1: Storage Hardware Mounting & File Seeding
  // --------------------------------------------------------------------------
  if (!phase1_initStorage()) {
    Serial.println("[ABORT] Cannot proceed to Phase 2 without functional storage.");
    return;
  }

  // --------------------------------------------------------------------------
  // EXECUTE PHASE 2: Wi-Fi Stack, WebServer Endpoints & Background Diagnostics
  // --------------------------------------------------------------------------
  Serial.printf("[PHASE 2 NET] Connecting to Wi-Fi SSID: %s...", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
  }
  Serial.println("\n[PHASE 2 NET] Wi-Fi Connected!");
  Serial.printf("[PHASE 2 NET] IP Address: %s\n", WiFi.localIP().toString().c_str());

  // Bind HTTP endpoints
  server.on("/", HTTP_GET, handleRoot);
  server.on("/site", HTTP_GET, handleSite);
  server.on("/get", HTTP_GET, handleDownload);

  // Start HTTP daemon
  server.begin();
  Serial.println("[PHASE 2 HTTP] Server active and listening on port 80.");

  // Launch internal test client task on Core 1
  xTaskCreatePinnedToCore(runClientTests, "ClientTest", 6144, NULL, 1, NULL, 1);
}

void loop() {
  // Process incoming HTTP client requests
  server.handleClient();
}
