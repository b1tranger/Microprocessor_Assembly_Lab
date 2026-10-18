#include <Arduino.h>
#include <WiFi.h>
#include <WebServer.h>
#include <SPI.h>
#include <SD.h>

#define SD_CS_PIN 5

// Wokwi virtual Wi-Fi access point credentials
const char* ssid = "Wokwi-GUEST";
const char* password = "";

WebServer server(80);

String formatBytes(size_t bytes) {
  if (bytes < 1024) return String(bytes) + " B";
  if (bytes < (1024 * 1024)) return String(bytes / 1024.0, 1) + " KB";
  return String(bytes / (1024.0 * 1024.0), 1) + " MB";
}

void ensureInitialFiles() {
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
      html.println("<p>Dual-Purpose Node: <strong>Static Web Host Active</strong></p>");
      html.println("<p><a href='/'>Go to NAS File Browser</a></p>");
      html.println("</body></html>");
      html.close();
      Serial.println("[STORAGE] Seeded /www/index.html");
    }
  }

  if (!SD.exists("/lab_report.txt")) {
    File report = SD.open("/lab_report.txt", FILE_WRITE);
    if (report) {
      report.println("Course: CSE0611324 Microprocessor Lab");
      report.println("Project: ESP32 Embedded NAS & Web Node");
      report.println("Storage: FAT32 block device over hardware SPI");
      report.close();
      Serial.println("[STORAGE] Seeded /lab_report.txt");
    }
  }
}

// NAS File Browser Route Handler
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

// Static Web Host Endpoint
void handleSite() {
  if (SD.exists("/www/index.html")) {
    File htmlFile = SD.open("/www/index.html", FILE_READ);
    server.streamFile(htmlFile, "text/html");
    htmlFile.close();
  } else {
    server.send(404, "text/plain", "Static Site Not Found");
  }
}

// NAS File Stream Endpoint
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

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n--- Starting ESP32 NAS & Web Node (VS Code Local) ---");

  // Mount SD Storage
  if (!SD.begin(SD_CS_PIN)) {
    Serial.println("[ERROR] MicroSD card initialization failed!");
    return;
  }
  Serial.printf("[STORAGE] Online. Total Space: %llu MB\n", SD.totalBytes() / (1024 * 1024));
  ensureInitialFiles();

  // Connect to Virtual Wi-Fi
  Serial.printf("[WIFI] Connecting to %s...", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
    Serial.print(".");
  }
  Serial.println("\n[WIFI] Connected!");
  Serial.printf("[NET] Node IP Address: %s\n", WiFi.localIP().toString().c_str());

  // Bind Routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/site", HTTP_GET, handleSite);
  server.on("/get", HTTP_GET, handleDownload);

  server.begin();
  Serial.println("[HTTP] Server listening on port 80.");
}

void loop() {
  server.handleClient();
}
