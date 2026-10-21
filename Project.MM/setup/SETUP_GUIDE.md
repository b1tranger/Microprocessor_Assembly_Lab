# ESP32 NAS & Web Server: Complete Setup & Dependency Guide

## Table of Contents
- [1. Overview](#1-overview)
- [2. Prerequisites & Software](#2-prerequisites--software)
- [3. Automated One-Click Setup](#3-automated-one-click-setup)
- [4. Manual Dependency Installation](#4-manual-dependency-installation)
  - [A. Python 3 & PlatformIO CLI](#a-python-3--platformio-cli)
  - [B. VS Code Extensions](#b-vs-code-extensions)
  - [C. Free Wokwi License Activation](#c-free-wokwi-license-activation)
  - [D. Wokwi IoT Gateway (wokwigw)](#d-wokwi-iot-gateway-wokwigw)
- [5. Hardware Wiring & Pin Mapping Reference](#5-hardware-wiring--pin-mapping-reference)
- [6. How to Run the Project Outside `setup/`](#6-how-to-run-the-project-outside-setup)
- [7. Verifying Project Endpoints](#7-verifying-project-endpoints)
- [8. Troubleshooting & Common Traps](#8-troubleshooting--common-traps)

---

## 1. Overview
This setup guide provides all instructions, dependencies, and automated helper scripts needed to compile, simulate, and interact with the **ESP32 Embedded NAS & Static Web Node** locally on your workstation.

All simulation runs locally using:
- **PlatformIO**: C++ Espressif toolchain and Arduino framework compilation.
- **Wokwi Simulator for VS Code**: QEMU/Wasm virtual ESP32 DevKit and MicroSD module emulation.
- **Wokwi IoT Gateway (`wokwigw`)**: Local TCP bridge mapping `localhost:9080` to virtual Wi-Fi `10.13.37.2:80`.

---

## 2. Prerequisites & Software

| Tool | Minimum Version | Purpose |
| :--- | :--- | :--- |
| **Visual Studio Code** | 1.80+ | Development IDE and simulation host |
| **Python** | 3.10+ (tested on 3.14) | Executes PlatformIO build system |
| **Wokwi VS Code Extension** | Latest (`wokwi.wokwi-vscode`) | Hardware circuit simulation |
| **Wokwi IoT Gateway** | Standalone binary (`wokwigw.exe`) | Bridges browser to virtual Wi-Fi |

---

## 3. Automated One-Click Setup

Inside the `setup/` directory, automated script pairs (`.bat` and `.ps1`) manage the entire environment:

> [!TIP]
> **Windows PowerShell Execution Policy Note**: If Windows displays `running scripts is disabled on this system`, either double-click the companion `.bat` launcher or run with `-ExecutionPolicy Bypass`.

### Step 0: Python Installation (For New / Fresh Devices)
If a device has not installed Python yet, run the automated Python installer:
```cmd
.\Project.MM\setup\setup_python.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\setup\setup_python.ps1
```
*What this does:*
1. Checks if Python 3 is already installed and in PATH.
2. If missing, attempts silent installation via `winget` (Windows Package Manager).
3. If `winget` is unavailable, automatically downloads and silently runs the official Python 64-bit installer with `Add Python to PATH` enabled.
4. Refreshes the environment variables so Python is immediately ready.
*(Note: `install_dependencies.bat` will also detect missing Python and invoke this automatically if needed!)*

### Step 1: Verify & Install Dependencies
Run via **Batch Launcher** (Bypasses execution policy restrictions automatically):
```cmd
.\Project.MM\setup\install_dependencies.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\setup\install_dependencies.ps1
```
*What this does:*
1. Verifies Python availability (and triggers automated setup if missing).
2. Installs/updates PlatformIO CLI via pip.
3. Automatically registers the Python `Scripts` directory to the User PATH if missing so the `pio` command is available everywhere.
4. Checks for `wokwigw.exe` and ensures it is present in both `setup/` and `LocalConfig/`.

### Step 2: Compile the Project
```cmd
.\Project.MM\setup\build_firmware.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\setup\build_firmware.ps1
```
*What this does:*
Builds `Project.MM/LocalConfig/src/main.cpp` into `.pio/build/esp32dev/firmware.bin`.

### Step 3: Launch Network Gateway
```cmd
.\Project.MM\setup\start_gateway.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\setup\start_gateway.ps1
```
*What this does:*
Starts the gateway forwarding `9080` $\rightarrow$ `10.13.37.2:80` and listening for simulation traffic on `ws://localhost:9011`.

---

## 4. Manual Dependency Installation

If you prefer installing dependencies manually:

### A. Python 3 & PlatformIO CLI
1. Open PowerShell and run:
   ```powershell
   python -m pip install -U platformio
   ```
2. Verify:
   ```powershell
   python -m platformio --version
   ```

### B. VS Code Extensions
1. In VS Code, open Extensions (`Ctrl + Shift + X`).
2. Install **Wokwi Simulator** (`wokwi.wokwi-vscode`).
3. *(Optional)* Install **PlatformIO IDE** (`platformio.platformio-ide`).

### C. Free Wokwi License Activation
1. Press `F1` (or `Ctrl + Shift + P`) in VS Code.
2. Type **`Wokwi: Request a New License`** and press Enter.
3. Click **Open** to sign in via GitHub/Google on wokwi.com.
4. Click **GET YOUR LICENSE** and confirm returning to VS Code.
5. VS Code will confirm: *"License activated for [Your Name]"*.

### D. Wokwi IoT Gateway (`wokwigw`)
The gateway binary `wokwigw.exe` is already pre-packaged in this folder:
- Path: [`Project.MM/setup/wokwigw.exe`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/setup/wokwigw.exe)
- Copy: [`Project.MM/LocalConfig/wokwigw.exe`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/wokwigw.exe)
*(Latest releases are also available at [https://github.com/wokwi/wokwigw/releases](https://github.com/wokwi/wokwigw/releases)).*

---

## 5. Hardware Wiring & Pin Mapping Reference

In [`Project.MM/LocalConfig/diagram.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/diagram.json), ensure the correct silkscreen identifiers are used:

| ESP32 Pin Identifier | MicroSD (`sd1`) Pin | Function / SPI Bus |
| :--- | :--- | :--- |
| **`esp:3V3`** | `sd1:VCC` | 3.3V Power Line |
| **`esp:GND.1`** | `sd1:GND` | Ground Reference |
| **`esp:D5`** | `sd1:CS` | Hardware Chip Select (VSPI SS) |
| **`esp:D23`** | `sd1:DI` | MOSI (Data Into Card) |
| **`esp:D19`** | `sd1:DO` | MISO (Data Out of Card) |
| **`esp:D18`** | `sd1:SCK` | Serial Clock |

> [!WARNING]
> Do NOT omit the **`D`** prefix on the ESP32 (e.g. do not write `esp:5` or `esp:18`), and do not label the clock pin as `CLK`. Using bare numbers or `CLK` causes Wokwi to silently disconnect the nets, resulting in `[ERROR] MicroSD card initialization failed!`.

---

## 6. How to Run the Project Outside `setup/`

Once the one-time setup above is finished, you do **NOT** need the `setup/` folder during day-to-day work. You run the project entirely inside [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig):

### Step 1: Open `LocalConfig` in VS Code
In VS Code, select **File > Open Folder...** and choose:
```text
Project.MM/LocalConfig
```

### Step 2: Start the Local Network Bridge
In a terminal window (PowerShell) inside `Project.MM/LocalConfig`:
```powershell
.\wokwigw.exe --forward 9080:10.13.37.2:80
```
*(Leave this running in the background).*

### Step 3: Run the Simulation
1. Open [`Project.MM/LocalConfig/diagram.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/diagram.json).

2. Press **`F1`** and run **`Wokwi: Start Simulator`** (or click the green Play button on the canvas).
3. The Serial Monitor will output:
   ```text
   --------------------------------------------------
     [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   
   --------------------------------------------------
   [PHASE 1 SUCCESS] FAT32 Storage Mounted.
   [PHASE 1 CAPACITY] Total: 8 MB | Used: ...
   [PHASE 1 STORAGE] Seeded /www/index.html to block storage
   [PHASE 1 STORAGE] Seeded /lab_report.txt to block storage
   ...
   [PHASE 2 NET] Wi-Fi Connected!
   [PHASE 2 NET] IP Address: 10.13.37.2
   [PHASE 2 HTTP] Server active and listening on port 80.
   ```

---

## 7. Verifying Project Endpoints

With the simulation and `wokwigw` running, open any desktop browser:

1. **NAS File Explorer**: [http://localhost:9080/](http://localhost:9080/)
   - Displays real-time FAT32 capacity and used storage.
   - Lists files with live download buttons.
2. **Hosted Static Webpage**: [http://localhost:9080/site](http://localhost:9080/site)
   - Streams `/www/index.html` stored on the virtual SD card.
3. **Direct File Download**: [http://localhost:9080/get?file=lab_report.txt](http://localhost:9080/get?file=lab_report.txt)
   - Downloads the pre-seeded academic report directly to your host PC.

---

## 8. Troubleshooting & Common Traps

1. **`error dialing 10.13.37.2:80: no route to host`**:
   - Cause: The simulator was started before `wokwigw.exe`, or `wokwi.toml` lacks `[net] gateway = "ws://localhost:9011"`.
   - Fix: Start `wokwigw.exe` first, then press `F1` and run `Wokwi: Restart Simulator`.
2. **`firmware binary ... not found in workspace`**:
   - Cause: The C++ firmware hasn't been built yet.
   - Fix: Run `python -m platformio run` or click the PlatformIO build checkmark (✓).
3. **`MicroSD card initialization failed!`**:
   - Cause: Incorrect pin names in `diagram.json`.
   - Fix: Ensure `esp:D5`, `esp:D18`, `esp:D19`, `esp:D23`, and `sd1:SCK` are used.
4. **`File ... cannot be loaded because running scripts is disabled on this system (PSSecurityException)`**:
   - Cause: Windows PowerShell default `ExecutionPolicy` is set to `Restricted`.
   - Fix: Either run the `.bat` launcher (e.g. `install_dependencies.bat`), use `powershell -ExecutionPolicy Bypass -File <script.ps1>`, or configure your user account policy once:
     ```powershell
     Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
     ```

