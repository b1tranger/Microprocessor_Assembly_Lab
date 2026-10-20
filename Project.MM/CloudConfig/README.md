# ESP32 NAS Server: Wokwi Cloud Web Configuration (`CloudConfig`)

> **Environment**: Wokwi Web Simulator ([wokwi.com](https://wokwi.com))  
> **Target Microcontroller**: ESP32 DevKit V1  
> **Storage Peripheral**: Virtual FAT32 MicroSD Module (VSPI Bus)  
> **Reference Document**: [`Project.MM/doc/research/[Cloud]implementationStepsMM.PDF.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/doc/research/%5BCloud%5DimplementationStepsMM.PDF.pdf)

---

## Table of Contents
- [1. Overview & Cloud Purpose](#1-overview--cloud-purpose)
- [2. File Structure & Component Roles](#2-file-structure--component-roles)
- [3. Step-by-Step Wokwi Web Setup Guide](#3-step-by-step-wokwi-web-setup-guide)
  - [Step 1: Create a New ESP32 Project on Wokwi.com](#step-1-create-a-new-esp32-project-on-wokwicom)
  - [Step 2: Configure Circuit Schematics (`diagram.json`)](#step-2-configure-circuit-schematics-diagramjson)
  - [Step 3: Add UI Templates Header (`html_templates.h`)](#step-3-add-ui-templates-header-html_templatesh)
  - [Step 4: Paste Firmware Code (`sketch.ino`)](#step-4-paste-firmware-code-sketchino)
  - [Step 5: Verify `libraries.txt`](#step-5-verify-librariestxt)
- [4. The Cloud Gateway Paywall & In-Simulation Loopback Solution](#4-the-cloud-gateway-paywall--in-simulation-loopback-solution)
- [5. Expected Serial Monitor Output](#5-expected-serial-monitor-output)
- [6. Comparison with Local VS Code Configuration](#6-comparison-with-local-vs-code-configuration)

---

## 1. Overview & Cloud Purpose

The [`Project.MM/CloudConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/CloudConfig) directory contains the standalone Arduino sketch and Wokwi web schematics required to run the **ESP32 Embedded NAS & Web Node** directly inside any web browser on **[wokwi.com](https://wokwi.com)** without installing VS Code, Python, PlatformIO, or local gateway binaries.

Because Wokwi's cloud servers block direct inbound traffic from your desktop browser on their free tier, this cloud configuration incorporates an **In-Simulation Self-Test Client (`runClientTests`)** running on **FreeRTOS Core 1**. The client autonomously queries the active `WebServer` over internal loopback (`http://127.0.0.1/`), verifying the entire REST API, static web hosting, and file download mechanisms directly in the cloud console.

---

## 2. File Structure & Component Roles

```text
Project.MM/CloudConfig/
│
├── README.md              # (THIS FILE) Comprehensive cloud setup & execution guide
├── sketch.ino             # Main Arduino C++ sketch (Storage mounting, WebServer, FreeRTOS client)
├── html_templates.h       # Glassmorphic dark UI CSS styles & PROGMEM static site template
├── diagram.json           # Wokwi circuit schematics & hardware SPI wiring
└── libraries.txt          # Library manifest (Empty: All drivers are built into the ESP32 core)
```

| File Name | Role in Wokwi Web |
| :--- | :--- |
| **`sketch.ino`** | Replaces the default `sketch.ino` editor tab. Implements Phase 1 FAT32 SD initialization, file seeding, WebServer route dispatching, and the FreeRTOS loopback test suite. |
| **`html_templates.h`** | Added as an auxiliary tab in Wokwi Web. Holds raw string literals in Flash ROM (`PROGMEM`) for the glassmorphic dashboard and the `/www/index.html` static site. |
| **`diagram.json`** | Replaces the `diagram.json` tab. Instantiates `wokwi-esp32-devkit-v1` and `wokwi-microsd-card` with verified hardware SPI pins (`D5`, `D18`, `D19`, `D23`). |
| **`libraries.txt`** | Left empty because the ESP32 Arduino Core natively includes `WiFi`, `WebServer`, `HTTPClient`, `SPI`, `SD`, and `FS`. |

---

## 3. Step-by-Step Wokwi Web Setup Guide

Follow these steps to replicate the project on [wokwi.com](https://wokwi.com):

### Step 1: Create a New ESP32 Project on Wokwi.com
1. Navigate to **[https://wokwi.com/](https://wokwi.com/)** in any browser.
2. Select **`ESP32`** $\rightarrow$ **`ESP32 DevKit V1`** (Arduino framework).

### Step 2: Configure Circuit Schematics (`diagram.json`)
1. Click on the **`diagram.json`** tab in the Wokwi editor.
2. Replace the entire contents with the code from [`Project.MM/CloudConfig/diagram.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/CloudConfig/diagram.json):
   ```json
   {
     "version": 1,
     "author": "Gaus Saraf Murady",
     "editor": "wokwi",
     "parts": [
       { "type": "wokwi-esp32-devkit-v1", "id": "esp", "top": 0, "left": 0, "attrs": {} },
       { "type": "wokwi-microsd-card", "id": "sd1", "top": 0, "left": 220, "attrs": {} }
     ],
     "connections": [
       [ "esp:TX0", "$serialMonitor:RX", "", [] ],
       [ "esp:RX0", "$serialMonitor:TX", "", [] ],
       [ "esp:3V3", "sd1:VCC", "red", [ "v0" ] ],
       [ "esp:GND.1", "sd1:GND", "black", [ "v0" ] ],
       [ "esp:D5", "sd1:CS", "yellow", [ "v0" ] ],
       [ "esp:D23", "sd1:DI", "blue", [ "v0" ] ],
       [ "esp:D19", "sd1:DO", "green", [ "v0" ] ],
       [ "esp:D18", "sd1:SCK", "orange", [ "v0" ] ]
     ]
   }
   ```

### Step 3: Add UI Templates Header (`html_templates.h`)
1. In the file tab bar above the code editor, click the **`+`** (or downward arrow `▼` $\rightarrow$ `New File`).
2. Name the file **`html_templates.h`**.
3. Copy and paste the entire content of [`Project.MM/CloudConfig/html_templates.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/CloudConfig/html_templates.h) into this new tab.

### Step 4: Paste Firmware Code (`sketch.ino`)
1. Switch to the default **`sketch.ino`** tab.
2. Replace all existing template code with the code from [`Project.MM/CloudConfig/sketch.ino`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/CloudConfig/sketch.ino).

### Step 5: Verify `libraries.txt`
1. Check the **`libraries.txt`** tab.
2. Ensure it is completely empty.

### Step 6: Click "Start Simulation"
Click the green **`Play`** button. Open the Serial Monitor at the bottom.

---

## 4. The Cloud Gateway Paywall & In-Simulation Loopback Solution

### The Cloud Problem:
On Wokwi's free cloud tier, clicking *"Enable Private Wokwi IoT Gateway"* triggers the paywall:
```text
This feature is only available for paying users: https://wokwi.com/pricing
```
Because Wokwi cloud containers block external browsers from routing into their virtual network, you cannot hit `http://localhost:9080/` when simulating in the cloud.

### The Solution:
`CloudConfig/sketch.ino` resolves this by executing **Workaround 1: In-Simulation Self-Test Client**:
```cpp
void runClientTests(void * parameter) {
  vTaskDelay(4000 / portTICK_PERIOD_MS);
  HTTPClient http;

  // Test 1: Query Root Explorer (/)
  http.begin("http://127.0.0.1/");
  int code = http.GET();
  // Validates HTTP 200 OK & captures HTML bytes

  // Test 2: Query Static Web Site (/site)
  http.begin("http://127.0.0.1/site");
  code = http.GET();
  // Validates streaming /www/index.html from SD blocks

  // Test 3: Download Stored Document (/get?file=lab_report.txt)
  http.begin("http://127.0.0.1/get?file=lab_report.txt");
  code = http.GET();
  // Validates FAT32 cluster stream
}
```
This task runs on **FreeRTOS Core 1** using the internal loopback socket (`127.0.0.1`), exercising the entire socket layer, HTTP router, and SPI FAT32 driver without crossing the internet.

---

## 5. Expected Serial Monitor Output

When running `CloudConfig` on Wokwi Web, the Serial Monitor produces:

```text
--------------------------------------------------
  [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   
--------------------------------------------------
[PHASE 1 SUCCESS] FAT32 Storage Mounted.
[PHASE 1 CAPACITY] Total: 31 MB | Used: 1 MB
[STORAGE] Seeded modern /www/index.html to SD
[STORAGE] Seeded /lab_report.txt to SD
[PHASE 1 DIRECTORY TREE]:
  |- www (0 B)
  |- lab_report.txt (234 B)
--------------------------------------------------

[NET] Connecting to Wi-Fi SSID: Wokwi-GUEST.....
[NET] Wi-Fi Connected!
[NET] Node IP Address: 10.0.1.15
[HTTP] Server listening on port 80 with File Upload enabled.

==================================================
  [AUTO-TEST] Running Automated HTTP Diagnostics  
==================================================

[TEST 1] Querying Root NAS Explorer ('/')...
[TEST 1] Response Code: 200 (Expected: 200)
[TEST 1] Successfully received 3824 bytes of HTML.
[TEST 1] Header Snippet: <!DOCTYPE html><html lang="en"><head>...

[TEST 2] Querying Static Web Hosting ('/site')...
[TEST 2] Response Code: 200 (Expected: 200)
[TEST 2] Successfully retrieved index.html (2850 bytes) from SD!
[TEST 2] Page Title Found: YES

[TEST 3] Downloading File ('/get?file=lab_report.txt')...
[TEST 3] Response Code: 200 (Expected: 200)
[TEST 3] Streamed File Content Directly from MicroSD Blocks:
--------------------------------------------------
Course: CSE0611324 Microprocessor & Microcontrollers Lab
Project: ESP32 Embedded NAS & Static Web Node
Architecture: Hardware VSPI (CS:5, MOSI:23, MISO:19, SCK:18)
Filesystem: FAT32 Block Device Driver
Features: File Upload, File Streaming, Delete, Static Web Hosting
--------------------------------------------------

==================================================
  [AUTO-TEST] All Cloud Diagnostics Passed!       
==================================================
```

---

## 6. Comparison with Local VS Code Configuration

If you want **real interactive browser access** (visiting `http://localhost:9080/`, drag-and-drop file uploads, visual storage meters, and live file deletion), use the local setup in [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig).

For an exhaustive technical breakdown of differences between Cloud, Local VS Code, and Physical Hardware, read:  
[`Project.MM/doc/CLOUD_VS_VSCODE_VS_HARDWARE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/doc/CLOUD_VS_VSCODE_VS_HARDWARE.md).
