# ESP32 Embedded NAS & Static Web Node (Wokwi VS Code Simulation)

## Table of Contents
- [Overview](#overview)
- [Project Directory Structure](#project-directory-structure)
- [Prerequisites & Extension Setup](#prerequisites--extension-setup)
- [Configuration Files Breakdown](#configuration-files-breakdown)
  - [1. platformio.ini](#1-platformioini)
  - [2. wokwi.toml](#2-wokwitoml)
  - [3. diagram.json](#3-diagramjson)
  - [4. include/html_templates.h](#4-includehtml_templatesh)
  - [5. src/main.cpp](#5-srcmaincpp)
  - [6. setup_firewall.bat](#6-setup_firewallbat)
- [Step-by-Step Simulation Execution](#step-by-step-simulation-execution)
  - [Step 1: Open the Project in VS Code](#step-1-open-the-project-in-vs-code)
  - [Step 2: Compile the Firmware](#step-2-compile-the-firmware)
  - [Step 3: Configure Windows Firewall (One-Click)](#step-3-configure-windows-firewall-one-click)
  - [Step 4: Launch Network Gateway (wokwigw)](#step-4-launch-network-gateway-wokwigw)
  - [Step 5: Launch Wokwi Simulation](#step-5-launch-wokwi-simulation)
- [Simultaneous Multi-Interface Access (Ethernet LAN + Wi-Fi Hotspot)](#simultaneous-multi-interface-access-ethernet-lan--wi-fi-hotspot)
  - [Why Multi-Interface Works (0.0.0.0:9080 Binding)](#why-multi-interface-works-00009080-binding)
  - [Method A: Wireless Access via Windows Mobile Hotspot](#method-a-wireless-access-via-windows-mobile-hotspot)
  - [Method B: Wired Access via Physical Ethernet LAN Switch](#method-b-wired-access-via-physical-ethernet-lan-switch)
  - [Endpoint & Host IP Mapping Table](#endpoint--host-ip-mapping-table)
- [Access Endpoints](#access-endpoints)
- [Troubleshooting & Tips](#troubleshooting--tips)

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
├── platformio.ini         # Toolchain & dependency configuration
├── wokwi.toml             # Wokwi simulation descriptor
├── diagram.json           # Circuit schematics and SPI pin mappings
├── wokwigw.exe            # Local network gateway binary
├── setup_firewall.bat     # One-click UAC auto-elevated Windows Firewall rule installer
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

### 6. `setup_firewall.bat`
Automated administrative script:
- Automatically requests UAC elevation if not launched as Administrator.
- Executes `New-NetFirewallRule -DisplayName "Wokwi Gateway NAS" -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow` to permit inbound traffic on port 9080 across all network profiles (Domain, Private, Public).
- Guarantees wired Ethernet LAN peers and wireless Mobile Hotspot devices can access the server without connection timeouts.

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

### Step 3: Configure Windows Firewall (One-Click)
To ensure client devices (such as smartphones and lab desktop PCs) can reach port 9080:
- Double-click [`setup_firewall.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup_firewall.bat) (or run from terminal).
- Accept the Windows UAC elevation prompt. The script configures inbound TCP port 9080 across all network profiles automatically.

### Step 4: Launch Network Gateway (wokwigw)
In a terminal window (PowerShell) inside `Project.MM/LocalConfig`:
```powershell
.\wokwigw.exe --forward 9080:10.13.37.2:80
```
*(Leave this running in the background. It forwards host port 9080 into the simulated ESP32 port 80).*

### Step 5: Launch Wokwi Simulation
1. Open `diagram.json` in the VS Code editor.
2. Press `F1` (or `Ctrl + Shift + P`) to open the Command Palette.
3. Run: **`Wokwi: Start Simulator`** (or click the green Play button).
4. Watch the integrated Serial Monitor output:
   ```text
   --------------------------------------------------
     [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   
   --------------------------------------------------
   [PHASE 1 SUCCESS] FAT32 Storage Mounted.
   [PHASE 1 CAPACITY] Total: 8 MB | Used: ...
   [PHASE 1 STORAGE] Seeded /www/index.html
   [PHASE 1 STORAGE] Seeded /lab_report.txt
   [PHASE 2 NET] Wi-Fi Connected!
   [PHASE 2 NET] Node IP Address: 10.13.37.2
   [PHASE 2 HTTP] Server active and listening on port 80.
   ```

---

## Simultaneous Multi-Interface Access (Ethernet LAN + Wi-Fi Hotspot)

### Why Multi-Interface Works (0.0.0.0:9080 Binding)
When you start the gateway using:
```powershell
.\wokwigw.exe --forward 9080:10.13.37.2:80
```
The gateway binary does **not** bind strictly to `127.0.0.1`. Instead, it binds to socket `0.0.0.0:9080` (INADDR_ANY), meaning it actively listens on **every network interface enabled on your Windows host PC**.

This allows you to serve the simulated ESP32 NAS simultaneously across both wired and wireless networks!

```
                       +---------------------------------------+
                       |   Host Workstation (0.0.0.0:9080)    |
                       |       wokwigw.exe TCP Forwarder       |
                       +-------------------+-------------------+
                                           |
                    +----------------------+----------------------+
                    |                                             |
                    ▼                                             ▼
       [Wired Ethernet Interface]                    [Windows Mobile Hotspot]
        IP: e.g. 192.168.1.105                         Virtual IP: 192.168.137.1
                    |                                             |
                    ▼                                             ▼
          Lab Desktop PCs on LAN                       Smartphones & Tablets
    http://192.168.1.105:9080/                      http://192.168.137.1:9080/
```

### Method A: Wireless Access via Windows Mobile Hotspot
To allow smartphones, tablets, and external laptops to connect wirelessly without lab router credentials:
1. Open Windows **Settings > Network & internet > Mobile hotspot**.
2. Select **Share my internet connection from**: `Ethernet` (or `Wi-Fi`).
3. Set **Share over**: `Wi-Fi`.
4. Turn **Mobile hotspot** to **ON**.
5. Note your hotspot Network Name (SSID) and Password.
6. Connect external smartphones or tablets to this hotspot.
7. Windows automatically assigns the host PC an IP of **`192.168.137.1`** on the virtual hotspot adapter.
8. On the connected phone/tablet, open any mobile browser and navigate to:
   - **`http://192.168.137.1:9080/`** (NAS Dashboard)
   - **`http://192.168.137.1:9080/site`** (Static Webpage)

### Method B: Wired Access via Physical Ethernet LAN Switch
To allow lab PCs on the local campus network switch to access the node:
1. Ensure your host machine is connected to the lab Ethernet switch/wall port.
2. Open PowerShell and find your local Ethernet IPv4 address:
   ```powershell
   ipconfig
   ```
   *(Look for `IPv4 Address` under Ethernet adapter, e.g., `192.168.1.105` or `10.100.x.x`).*
3. From any other lab desktop PC connected to the same switch/subnet, open the browser and navigate to:
   - **`http://<YOUR_ETHERNET_IP>:9080/`** (e.g. `http://192.168.1.105:9080/`)
   - **`http://<YOUR_ETHERNET_IP>:9080/site`**

---

### Endpoint & Host IP Mapping Table

Use this reference table to access the appropriate endpoints during your live lab evaluation:

| Interface Type | Connected Client Device | Host IP Reference | NAS Explorer URL | Hosted Static Site URL |
| :--- | :--- | :--- | :--- | :--- |
| **Localhost (Loopback)** | Host PC (Where VS Code is running) | `localhost` or `127.0.0.1` | [http://localhost:9080/](http://localhost:9080/) | [http://localhost:9080/site](http://localhost:9080/site) |
| **Windows Mobile Hotspot** | Evaluator smartphones, tablets, laptops | `192.168.137.1` *(Default Windows Hotspot Gateway)* | `http://192.168.137.1:9080/` | `http://192.168.137.1:9080/site` |
| **Wired Ethernet LAN** | Lab workstation PCs on campus switch | `<YOUR_LAN_IP>` *(From `ipconfig`)* | `http://<YOUR_LAN_IP>:9080/` | `http://<YOUR_LAN_IP>:9080/site` |

---

## Access Endpoints

Once `wokwigw` and the simulation are active, the web endpoints provide:
- **NAS File Manager Dashboard (`/`)**: Displays real-time FAT32 storage capacity meter, file list, file upload form, and file delete buttons.
- **Hosted Static Webpage (`/site`)**: Streams `/www/index.html` stored on the virtual MicroSD card.
- **Direct File Download (`/get?file=<name>`)**: Streams requested files in binary octet-stream mode directly to the client device.
- **Multipart Upload (`/upload`)**: Streams client files chunk-by-chunk into MicroSD FAT32 storage with ~2 KB RAM overhead.

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

- **External Clients Cannot Connect (Connection Timed Out)**:
  - Run [`setup_firewall.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup_firewall.bat) as Administrator to verify Windows Firewall permits TCP port 9080 on Private and Public network profiles.
- **IP Mismatch**: The standard Wokwi gateway subnet is `10.13.37.2`. If your Serial Monitor displays a different node IP address, adjust the forwarding argument: `--forward 9080:<node-ip>:80`.
