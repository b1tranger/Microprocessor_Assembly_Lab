# ESP32 Embedded NAS & Static Web Node (Wokwi VS Code Simulation)

## Table of Contents
- [Overview](#overview)
- [Project Directory Structure](#project-directory-structure)
- [Prerequisites & Extension Setup](#prerequisites--extension-setup)
- [Configuration Files Breakdown](#configuration-files-breakdown)
  - [1. platformio.ini](#1-platformioini)
  - [2. wokwi.toml](#2-wokwitoml)
  - [3. diagram.json](#3-diagramjson)
  - [4. Dedicated Data & Assets (data/ and include/default_assets.h)](#4-dedicated-data--assets-data-and-includedefault_assetsh)
  - [5. include/html_templates.h](#5-includehtml_templatesh)
  - [6. src/main.cpp](#6-srcmaincpp)
  - [7. setup_firewall.bat](#7-setup_firewallbat)
  - [8. setup/ Directory](#8-setup-directory)
- [Simulation Execution & Multi-Device Access Guide](#simulation-execution--multi-device-access-guide)

---

## Overview
This project sets up, compiles, simulates, and serves an ESP32-based Network Attached Storage (NAS) and Static Web Server entirely on your local workstation using the **Wokwi for VS Code** extension and **PlatformIO IDE**.

By running simulation locally, the ESP32 code executes via your local compiler toolchain without cloud rate limits, and network requests can be bridged directly to your host PC loopback adapter (`localhost:9080`) as well as external network interfaces (wired Ethernet and wireless Mobile Hotspot).

---

## Project Directory Structure

```text
Project.MM/LocalConfig/
│
├── .gitignore             # Ignores .pio/ build artifacts and local IDE files
├── platformio.ini         # Toolchain & dependency configuration (with pre-build asset script)
├── wokwi.toml             # Wokwi simulation descriptor
├── diagram.json           # Circuit schematics and SPI pin mappings
├── wokwigw.exe            # Local network gateway binary
├── setup_firewall.bat     # One-click UAC auto-elevated Windows Firewall rule installer
├── runGuide.md            # Comprehensive execution, networking, and setup guide
├── README.md              # Project technical overview and architecture
├── data/                  # Dedicated host folders for initial assets
│   ├── network/           # Host SSD storage folder synced to simulated SD (1 GB)
│   ├── default/           # Default protected files (lab_report.txt, etc.)
│   └── www/               # Static website files (index.html, etc.)
├── scripts/               # Asset embedding scripts
│   ├── generate_assets.bat  # One-click asset generator for Windows CMD
│   ├── generate_assets.ps1  # PowerShell asset generator
│   └── generate_assets.py   # PlatformIO pre-build asset generator
├── include/
│   ├── default_assets.h   # Auto-generated PROGMEM byte arrays from data/
│   └── html_templates.h   # Modular glassmorphic HTML/CSS templates & UI components
├── src/
│   └── main.cpp           # ESP32 C++ firmware code & protected storage engine
└── setup/                 # One-click automated setup & offline toolchain scripts
    ├── install_dependencies.bat / .ps1
    ├── build_firmware.bat / .ps1
    ├── setup_firewall.bat
    ├── start_gateway.bat / .ps1
    ├── uninstall_dependencies.bat / .ps1
    └── SETUP_GUIDE.md
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
Tells Wokwi where PlatformIO places the compiled binary, routes simulation network traffic through `wokwigw`, and maps the MicroSD storage to host SSD/HDD storage:
```toml
[wokwi]
version = 1
firmware = ".pio/build/esp32dev/firmware.bin"
elf = ".pio/build/esp32dev/firmware.elf"

[net]
gateway = "ws://localhost:9011"

[[sdcard]]
part = "sd1"
folder = "data/network"
size = "256M"
writeback = true
```
*(The `[[sdcard]]` block expands card capacity to **256 MB** (Wokwi's maximum simulated SD card limit) and synchronizes all file operations directly with [`data/network/`](data/network/) on your host PC's SSD/HDD).*

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

### 4. Dedicated Data & Assets (`data/` and `include/default_assets.h`)
- **`data/network/`**: Host SSD/HDD storage folder synchronized directly with the simulated MicroSD card (1 GB volume).
- **`data/default/`**: Host folder for default documentation and files (e.g. [`data/default/lab_report.txt`](data/default/lab_report.txt)). Automatically seeded to `/default/` on the SD card.
- **`data/www/`**: Host folder for static website files (e.g. [`data/www/index.html`](data/www/index.html)). Automatically seeded to `/www/` on the SD card.
- **`scripts/generate_assets.bat` / `.ps1` / `.py`**: Scans `data/` and compiles files into Flash ROM as `PROGMEM` byte arrays inside `include/default_assets.h`.
- **Write Protection**: Any file in `default/` or `www/` is write-protected (`isProtected = true`) and cannot be deleted from the web interface.

### 5. `include/html_templates.h`
Modular UI templates:
- Contains glassmorphic dark UI CSS styles, responsive layouts, storage bar templates, and badge styles for write-protected files (`.badge-protected`).
- Stored directly in Flash ROM using `PROGMEM` and C++ raw string literals `R"rawliteral(...)rawliteral"`, keeping internal SRAM free.

### 6. `src/main.cpp`
Firmware architecture:
- **Phase 1 Storage**: Initializes hardware VSPI (`SPI.begin(18, 19, 23, 5)`), mounts FAT32 SD card (`SD.begin(5, SPI)`), creates dedicated directories (`/default`, `/www`, `/uploads`), and dynamically seeds embedded assets from `default_assets.h`.
- **Protected File Security**: Intercepts delete requests targeting `/default/*`, `/www/*`, or `/lab_report.txt` and returns `HTTP 403 Forbidden`.
- **Phase 2 Networking**: Connects to `Wokwi-GUEST` Wi-Fi, hosts web endpoints on port 80 (`/`, `/site`, `/get`, `/upload`, `/delete`), routes incoming uploads into `/uploads/`, and executes automated self-diagnostics on FreeRTOS Core 1.

### 7. `setup_firewall.bat`
Automated administrative script:
- Automatically requests UAC elevation if not launched as Administrator.
- Executes `New-NetFirewallRule -DisplayName "Wokwi Gateway NAS" -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow` to permit inbound traffic on port 9080 across all network profiles (Domain, Private, Public).
- Guarantees wired Ethernet LAN peers and wireless Mobile Hotspot devices can access the server without connection timeouts.

### 8. `setup/` Directory
Automated setup and offline installation scripts:
- **[`setup/install_dependencies.bat`](setup/install_dependencies.bat) / [`.ps1`](setup/install_dependencies.ps1)**: Automatically installs Python, PlatformIO CLI, packages, and extracts toolchains.
- **[`setup/build_firmware.bat`](setup/build_firmware.bat) / [`.ps1`](setup/build_firmware.ps1)**: One-click CLI firmware compilation to `.pio/build/esp32dev/firmware.bin`.
- **[`setup/setup_firewall.bat`](setup/setup_firewall.bat)**: Automated Windows Firewall rule installer for port 9080.
- **[`setup/start_gateway.bat`](setup/start_gateway.bat) / [`.ps1`](setup/start_gateway.ps1)**: One-click launcher for `wokwigw.exe` forwarding `0.0.0.0:9080` $\rightarrow$ `10.13.37.2:80`.
- **[`setup/uninstall_dependencies.bat`](setup/uninstall_dependencies.bat) / [`.ps1`](setup/uninstall_dependencies.ps1)**: Reverts all environment changes, uninstalls packages, and cleans registry/PATH entries.
- **[`setup/SETUP_GUIDE.md`](setup/SETUP_GUIDE.md)**: In-depth offline installation and troubleshooting documentation.

> [!TIP]
> For a complete project show walkthrough, oral defense script, and architectural Q&A, refer to the **[Presentation Guide](../PRESENTATION_GUIDE.md)**.

---

## Simulation Execution & Multi-Device Access Guide

> [!IMPORTANT]
> The full, step-by-step operational run guide for compiling, running, and accessing the server from external client devices (smartphones, tablets, and peer lab PCs) is documented in:
>
> 📖 **[Comprehensive Run Guide (`runGuide.md`)](runGuide.md)**
>
> Please refer directly to [`runGuide.md`](runGuide.md) for:
> 1. **Complete Setup & Automated Toolchain Scripts**: Running dependency installers and offline tools inside [`setup/`](setup/).
> 2. **Step-by-Step Simulation Launch**: Compiling firmware, running Windows Firewall configuration via [`setup_firewall.bat`](setup_firewall.bat), launching `wokwigw.exe`, and starting the Wokwi simulation in VS Code.
> 3. **Three Real-World Deployment Scenarios**:
>    - **Scenario 1: Home Hybrid Testing** (Host PC on router Ethernet $\leftrightarrow$ Phone/Laptop on router Wi-Fi accessing `http://<HOST_ETHERNET_IP>:9080/`).
>    - **Scenario 2: Lab Workstation Testing** (Both host and peer PCs plugged into campus Ethernet switch accessing `http://<PC1_ETHERNET_IP>:9080/`).
>    - **Scenario 3: Portable Showcase Hotspot** (Host laptop running Windows Mobile Hotspot accessing `http://192.168.137.1:9080/`).
> 4. **Zero-Install Local Network File Transfer (LocalSend Web Model)**: Peer-to-peer file sharing between two lab computers.
> 5. **Comprehensive Troubleshooting & Diagnostic Traps**: Resolving `no route to host`, firewall timeouts, missing binaries, and SD mount failures.
