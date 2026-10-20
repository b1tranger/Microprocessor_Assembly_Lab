# ESP32 Embedded NAS & Static Web Node (Wokwi VS Code Simulation)

## Table of Contents
- [Overview](#overview)
- [Project Directory Structure](#project-directory-structure)
- [Prerequisites & Extension Setup](#prerequisites--extension-setup)
- [Configuration Files Breakdown](#configuration-files-breakdown)
  - [1. platformio.ini](#1-platformioini)
  - [2. wokwi.toml](#2-wokwitoml)
  - [3. diagram.json](#3-diagramjson)
  - [4. src/main.cpp](#4-srcmaincpp)
- [Step-by-Step Simulation Execution](#step-by-step-simulation-execution)
- [Step 7: Bridging Network Traffic Locally (wokwigw)](#step-7-bridging-network-traffic-locally-wokwigw)
- [Access Endpoints](#access-endpoints)
- [Troubleshooting & Tips](#troubleshooting--tips)

---

## Overview
This project sets up, compiles, simulates, and serves an ESP32-based Network Attached Storage (NAS) and Static Web Server entirely on your local workstation using the **Wokwi for VS Code** extension and **PlatformIO IDE**.

By running simulation locally, the ESP32 code executes via your local compiler toolchain without cloud rate limits, and network requests can be bridged directly to your host PC loopback adapter (`localhost:9080`).

---

## Project Directory Structure

```text
Project.MM/LocalConfig/
│
├── .gitignore             # Ignores .pio/ build artifacts and local IDE files
├── platformio.ini         # Toolchain & dependency configuration
├── wokwi.toml             # Wokwi simulation descriptor
├── diagram.json           # Circuit schematics and SPI pin mappings
├── wokwigw.exe            # Local network gateway binary
├── README.md              # Project documentation and execution instructions
├── include/
│   └── html_templates.h   # Modular glassmorphic HTML/CSS templates & PROGMEM strings
└── src/
    └── main.cpp           # ESP32 C++ firmware code
```

---

## Prerequisites & Extension Setup

1. **Install Visual Studio Code**: Ensure VS Code is installed.
2. **Install Extensions**:
   - Open VS Code Extensions view (`Ctrl + Shift + X`).
   - Search for and install **Wokwi Simulator** (`wokwi.wokwi-vscode`).
   - Search for and install **PlatformIO IDE** (`platformio.platformio-ide`).
3. *(Optional for first-time Wokwi setup)*: Press `F1`, type `Wokwi: Request License`, and claim your free trial/license token if prompted by the extension.

---

## Configuration Files Breakdown

### 1. `platformio.ini`
Instructs PlatformIO to compile firmware targeting the standard ESP32 DevKit using the Arduino framework:
```ini
[env:esp32dev]
platform = espressif32
board = esp32dev
framework = arduino
monitor_speed = 115200

; Built-in libraries used directly: WiFi, WebServer, SPI, SD, FS
lib_deps =
```

### 2. `wokwi.toml`
Tells Wokwi where PlatformIO places the compiled binary and ELF debug symbols, and routes simulation network traffic through the local `wokwigw` gateway:
```toml
[wokwi]
version = 1
firmware = ".pio/build/esp32dev/firmware.bin"
elf = ".pio/build/esp32dev/firmware.elf"

[net]
gateway = "ws://localhost:9011"
```
*(The `[net]` block is required for `wokwigw` so that virtual Wi-Fi packets are forwarded through the local gateway at `localhost:9011`).*


### 3. `diagram.json`
Specifies virtual hardware and hardware SPI wiring (using Wokwi `D`-prefixed silkscreen pin names):
- **`wokwi-esp32-devkit-v1`**: Core MCU board.
- **`wokwi-microsd-card`**: SPI MicroSD card module.
- **Pin Connections**:
  - `esp:3V3` $\rightarrow$ `sd1:VCC`
  - `esp:GND.1` $\rightarrow$ `sd1:GND`
  - `esp:D5` $\rightarrow$ `sd1:CS` (Chip Select)
  - `esp:D23` $\rightarrow$ `sd1:DI` (MOSI)
  - `esp:D19` $\rightarrow$ `sd1:DO` (MISO)
  - `esp:D18` $\rightarrow$ `sd1:SCK` (Serial Clock)

### 4. `include/html_templates.h`
Modular UI templates:
- Contains glassmorphic dark UI CSS styles, responsive layouts, storage bar templates, and the static website template (`SEED_INDEX_HTML`).
- Stored directly in Flash ROM using `PROGMEM` and C++ raw string literals `R"rawliteral(...)rawliteral"`, keeping internal SRAM free.

### 5. `src/main.cpp`
Firmware architecture:
- **Phase 1 Storage**: Explicitly initializes `SPI.begin(18, 19, 23, 5)` and mounts FAT32 SD filesystem via `SD.begin(5, SPI)`. Automatically seeds `/www/index.html` and `/lab_report.txt` and enumerates files.
- **Phase 2 Networking**: Connects to `Wokwi-GUEST` Wi-Fi, hosts web endpoints on port 80 (`/`, `/site`, `/get`, `/upload`, `/delete`), and executes automated internal self-diagnostics on FreeRTOS Core 1.

> [!TIP]
> - For a complete project show walkthrough, oral defense script, and architectural Q&A, refer to the **[Presentation Guide](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/PRESENTATION_GUIDE.md)**.
> - For automated one-click dependency installation, automated build scripts, and offline tools, check out [`Project.MM/setup/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/setup) and [`Project.MM/setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/setup/SETUP_GUIDE.md).

---

## Step-by-Step Simulation Execution

### Step 1: Open the Project in VS Code
Open the directory `Project.MM/LocalConfig` directly in VS Code (`File` > `Open Folder...`). This ensures PlatformIO immediately detects `platformio.ini`.

### Step 2: Compile the Firmware
- Click the **PlatformIO Build checkmark (✓)** on the bottom blue status bar, or press `Ctrl + Alt + B`.
- PlatformIO will download toolchains and libraries on first run, compiling to `.pio/build/esp32dev/firmware.bin`.

### Step 3: Launch Wokwi Simulation
- Open `diagram.json` in the VS Code editor.
- Press `F1` (or `Ctrl + Shift + P`) to open the Command Palette.
- Run: `Wokwi: Start Simulator`.
- The interactive simulation canvas appears side-by-side with an active Serial Monitor.

### Step 4: Verify Serial Output
Watch the integrated terminal for:
```text
--- Starting ESP32 NAS & Web Node (VS Code Local) ---
[STORAGE] Online. Total Space: ...
[STORAGE] Seeded /www/index.html
[STORAGE] Seeded /lab_report.txt
[WIFI] Connecting to Wokwi-GUEST...
[WIFI] Connected!
[NET] Node IP Address: 10.0.x.x
[HTTP] Server listening on port 80.
```

---

## Step 7: Bridging Network Traffic Locally (wokwigw)

To forward browser requests from your workstation directly into the simulated ESP32 Wi-Fi environment without cloud restrictions:

1. Download the standalone **Wokwi IoT Gateway (`wokwigw`)** binary:
   - Official releases: [https://github.com/wokwi/wokwigw/releases](https://github.com/wokwi/wokwigw/releases)
2. Place `wokwigw.exe` in your project folder or system PATH.
3. Open a terminal in `Project.MM/LocalConfig` and run:
   - **Windows**:
     ```powershell
     .\wokwigw.exe --forward 9080:10.13.37.2:80
     ```
   - **Linux / macOS**:
     ```bash
     ./wokwigw --forward 9080:10.13.37.2:80
     ```

---

## Access Endpoints

Once `wokwigw` is running, open any browser on your machine:
- **NAS File Manager Dashboard**: [http://localhost:9080/](http://localhost:9080/)
- **Hosted Static Webpage**: [http://localhost:9080/site](http://localhost:9080/site)
- **Direct File Download**: Click `lab_report.txt` in the file table or access `http://localhost:9080/get?file=lab_report.txt`.

---

## Troubleshooting & Tips

- **`connect tcp 10.13.37.2:80: no route to host` Error**:
  - **Cause**: The Wokwi simulator did not connect to `wokwigw`'s internal WebSocket server (`ws://localhost:9011`), meaning the virtual ESP32 is not registered in the gateway's network table.
  - **Fix**:
    1. Ensure `wokwi.toml` includes:
       ```toml
       [net]
       gateway = "ws://localhost:9011"
       ```
    2. **Start `wokwigw.exe` FIRST** in a separate terminal:
       ```powershell
       .\wokwigw.exe --forward 9080:10.13.37.2:80
       ```
    3. **Then Restart the Wokwi Simulation**: In VS Code, open `diagram.json`, press `F1`, and run `Wokwi: Restart Simulator` (or `Start Simulator`).
    4. In the `wokwigw` terminal, you should see confirmation of a connected client / DHCP lease.
    5. Wait until the Serial Monitor displays:
       ```text
       [WIFI] Connected!
       [NET] Node IP Address: 10.13.37.2
       ```
    6. Only now open `http://localhost:9080/` in your browser.

- **PlatformIO CLI**: If you prefer CLI builds, run `pio run` inside `Project.MM/LocalConfig`.
- **Wokwi License**: If the simulation prompts for a license, select `Request License` in the Command Palette (free for open source / personal testing).
- **IP Mismatch**: The standard Wokwi gateway subnet is `10.13.37.2`. If your Serial Monitor displays a different node IP address, adjust the forwarding argument: `--forward 9080:<node-ip>:80`.

