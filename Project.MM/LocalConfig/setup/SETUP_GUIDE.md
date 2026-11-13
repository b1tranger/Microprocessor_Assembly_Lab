# ESP32 NAS & Web Server: Complete Setup & Dependency Guide

## Table of Contents
- [1. Overview](#1-overview)
- [2. Prerequisites & Software](#2-prerequisites--software)
- [3. Automated One-Click Setup](#3-automated-one-click-setup)
  - [Step 0: Python Installation (For Fresh Devices)](#step-0-python-installation-for-new--fresh-devices)
  - [Step 1: Verify & Install Dependencies](#step-1-verify--install-dependencies)
  - [Step 2: Compile the Project](#step-2-compile-the-project)
  - [Step 3: Configure Windows Firewall (One-Click)](#step-3-configure-windows-firewall-one-click)
  - [Step 4: Launch Network Gateway](#step-4-launch-network-gateway)
  - [Step 5: Clean Revert & Environment Uninstallation](#step-5-clean-revert--environment-uninstallation)
- [4. Manual Dependency Installation](#4-manual-dependency-installation)
  - [A. Python 3 & PlatformIO CLI](#a-python-3--platformio-cli)
  - [B. VS Code Extensions](#b-vs-code-extensions)
  - [C. Free Wokwi License Activation](#c-free-wokwi-license-activation)
  - [D. Wokwi IoT Gateway (wokwigw)](#d-wokwi-iot-gateway-wokwigw)
- [5. Hardware Wiring & Pin Mapping Reference](#5-hardware-wiring--pin-mapping-reference)
- [6. How to Run the Project Outside `setup/`](#6-how-to-run-the-project-outside-setup)
- [7. Verifying Endpoints & Multi-Interface Access](#7-verifying-endpoints--multi-interface-access)
  - [Why Multi-Interface Works (0.0.0.0:9080 Binding)](#why-multi-interface-works-00009080-binding)
  - [Method A: Wireless Mobile Hotspot Access](#method-a-wireless-mobile-hotspot-access)
  - [Method B: Wired Ethernet LAN Access](#method-b-wired-ethernet-lan-access)
  - [Complete Host IP & Endpoint Mapping Table](#complete-host-ip--endpoint-mapping-table)
- [8. Troubleshooting & Common Traps](#8-troubleshooting--common-traps)

---

## 1. Overview
This setup guide provides all instructions, dependencies, and automated helper scripts needed to compile, simulate, and interact with the **ESP32 Embedded NAS & Static Web Node** locally on your workstation.

All simulation runs locally using:
- **PlatformIO**: C++ Espressif toolchain and Arduino framework compilation.
- **Wokwi Simulator for VS Code**: QEMU/Wasm virtual ESP32 DevKit and MicroSD module emulation.
- **Wokwi IoT Gateway (`wokwigw`)**: Local TCP bridge mapping `0.0.0.0:9080` (all host network interfaces) to virtual Wi-Fi `10.13.37.2:80`.

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
.\Project.MM\LocalConfig\setup\setup_python.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\setup_python.ps1
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
.\Project.MM\LocalConfig\setup\install_dependencies.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\install_dependencies.ps1
```
*What this does:*
1. Verifies Python availability (and triggers automated setup if missing).
2. Installs/updates PlatformIO CLI via pip.
3. Automatically registers the Python `Scripts` directory to the User PATH if missing so the `pio` command is available everywhere.
4. Checks for `wokwigw.exe` and ensures it is present in both `setup/` and `LocalConfig/`.
5. Pre-installs Espressif 32 toolchains and framework packages with live download progress bars so subsequent builds execute in seconds.

### Step 2: Compile the Project
```cmd
.\Project.MM\LocalConfig\setup\build_firmware.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\build_firmware.ps1
```
*What this does:*
1. Automatically synchronizes initial files from [`data/default/`](../data/default/) and static website assets from [`data/www/`](../data/www/) into [`include/default_assets.h`](../include/default_assets.h).
2. Builds `Project.MM/LocalConfig/src/main.cpp` into `.pio/build/esp32dev/firmware.bin` (with live progress bars if toolchain packages are not yet cached).
3. Ensures all default system files are write-protected and cannot be deleted via the web server interface.

### Step 3: Configure Windows Firewall (One-Click)
To ensure external clients (e.g. mobile phones, evaluator tablets, lab desktop PCs) can reach port 9080 across wired and wireless adapters:
```cmd
.\Project.MM\LocalConfig\setup\setup_firewall.bat
```
*What this does:*
1. Automatically verifies administrative privileges and requests UAC elevation if needed.
2. Executes PowerShell `New-NetFirewallRule` for Inbound TCP Port 9080 across **all network profiles** (Domain, Private, Public).
3. Confirms that both wired Ethernet and wireless Mobile Hotspot devices can connect without firewall timeouts.

### Step 4: Launch Network Gateway
```cmd
.\Project.MM\LocalConfig\setup\start_gateway.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\start_gateway.ps1
```
*What this does:*
Starts the gateway forwarding `9080` $\rightarrow$ `10.13.37.2:80` and listening for simulation traffic on `ws://localhost:9011`.

### Step 5: Clean Revert & Environment Uninstallation
If you wish to revert all changes made by the setup scripts:
```cmd
.\Project.MM\LocalConfig\setup\uninstall_dependencies.bat
```
*Or via PowerShell:*
```powershell
powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\uninstall_dependencies.ps1
```
*What this does:*
1. Terminates any running `wokwigw.exe` gateway processes.
2. Removes the Windows Firewall inbound rule `"Wokwi Gateway NAS"` (Port 9080).
3. Cleans up environment variables (`PLATFORMIO_CORE_DIR`).
4. Cleans generated compilation artifacts (`.pio/`) and duplicate gateway binaries in `LocalConfig/`.
5. *(Optional full cleanup)*: Pass `-FullCleanup` to also uninstall the PlatformIO CLI pip package and delete extracted toolchains.

> [!TIP]
> **GitHub Releases Offline Toolchain Bundle**:
> To compile and simulate offline without downloading heavy toolchains during setup:
> 1. Download `platformio_cache.zip` from **[GitHub Releases: wokwi_env_setup_script](https://github.com/b1tranger/wokwi_env_setup_script/releases/tag/platformio_cache.zip)** ([Direct Download Link](https://github.com/b1tranger/wokwi_env_setup_script/releases/download/platformio_cache.zip/platformio_cache.zip)).
> 2. Place `platformio_cache.zip` into `Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/platformio_cache.zip`.
> 3. Run `install_dependencies.bat` (or `PlatformIO_Espressif_Offline_Installer/install_offline.bat`) — the script automatically detects the archive, unpacks the Espressif 32 toolchains, and completes setup with zero internet required.
> 4. The local `.gitignore` automatically keeps the zip archive untracked so your git working tree stays clean.

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
- Path: [`wokwigw.exe`](wokwigw.exe)
- Copy: [`../wokwigw.exe`](../wokwigw.exe)
*(Latest releases are also available at [https://github.com/wokwi/wokwigw/releases](https://github.com/wokwi/wokwigw/releases)).*

---

## 5. Hardware Wiring & Pin Mapping Reference

In [`../diagram.json`](../diagram.json), ensure the correct silkscreen identifiers are used:

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

Once the one-time setup above is finished, you do **NOT** need the `setup/` folder during day-to-day work. You run the project entirely inside [`LocalConfig`](..):

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
1. Open [`../diagram.json`](../diagram.json).
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

## 7. Verifying Endpoints & Multi-Interface Access

### Why Multi-Interface Works (0.0.0.0:9080 Binding)
When you run `wokwigw.exe --forward 9080:10.13.37.2:80`, the gateway binds to socket address `0.0.0.0:9080` (`INADDR_ANY`). This means it listens simultaneously on **all active network interfaces** of your host PC.

This allows simultaneous access from:
1. **Host PC**: Loopback browser (`localhost:9080`).
2. **Mobile Hotspot Devices**: Smartphones and tablets (`192.168.137.1:9080`).
3. **Wired Ethernet Devices**: Lab desktop PCs on the same switch (`<YOUR_LAN_IP>:9080`).

### Method A: Wireless Mobile Hotspot Access
1. In Windows, go to **Settings > Network & internet > Mobile hotspot**.
2. Turn **Mobile hotspot** to **ON** (Share from Ethernet or Wi-Fi over Wi-Fi).
3. Connect evaluator smartphones or tablets to this hotspot network.
4. Windows automatically assigns the host PC the virtual gateway IP **`192.168.137.1`**.
5. On the phone's browser, open `http://192.168.137.1:9080/`.

### Method B: Wired Ethernet LAN Access
1. Connect your host PC to the lab Ethernet wall switch.
2. Open PowerShell and run `ipconfig` to view your Ethernet `IPv4 Address` (e.g. `192.168.1.105`).
3. On any other lab PC connected to the same switch/network, open the browser and navigate to `http://<YOUR_LAN_IP>:9080/`.

### Complete Host IP & Endpoint Mapping Table

| Network Interface | Target Client Device | Host IP Reference | NAS Explorer URL | Static Website URL |
| :--- | :--- | :--- | :--- | :--- |
| **Localhost (Loopback)** | Host workstation running VS Code | `localhost` or `127.0.0.1` | [http://localhost:9080/](http://localhost:9080/) | [http://localhost:9080/site](http://localhost:9080/site) |
| **Windows Mobile Hotspot** | Evaluator smartphones, tablets, laptops | `192.168.137.1` | `http://192.168.137.1:9080/` | `http://192.168.137.1:9080/site` |
| **Wired Ethernet LAN** | Lab workstation PCs on campus network | `<YOUR_LAN_IP>` *(from `ipconfig`)* | `http://<YOUR_LAN_IP>:9080/` | `http://<YOUR_LAN_IP>:9080/site` |

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
4. **External Clients Cannot Connect (Connection Timed Out)**:
   - Cause: Windows Firewall is blocking inbound connections on TCP port 9080.
   - Fix: Run [`setup_firewall.bat`](setup_firewall.bat) (or [`../setup_firewall.bat`](../setup_firewall.bat)) as Administrator to add the firewall rule across all profiles.
5. **`File ... cannot be loaded because running scripts is disabled on this system (PSSecurityException)`**:
   - Cause: Windows PowerShell default `ExecutionPolicy` is set to `Restricted`.
   - Fix: Either run the `.bat` launcher (e.g. `install_dependencies.bat`), use `powershell -ExecutionPolicy Bypass -File <script.ps1>`, or configure your user account policy once:
     ```powershell
     Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
     ```
