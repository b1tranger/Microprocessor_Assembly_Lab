# Project.MM LocalConfig: Simulation & Network Execution Guide

An operational guide for compiling, running, and simulating the ESP32 Embedded Network Attached Storage (NAS) and Static Web Server within Visual Studio Code, and accessing the server from external client devices (smartphones, tablets, and peer lab computers) across local Wi-Fi and Ethernet networks.

---

## Table of Contents
- [1. System & Architecture Overview](#1-system--architecture-overview)
  - [1.1 Embedded Hardware Architecture](#11-embedded-hardware-architecture)
  - [1.2 Hardware VSPI & Storage Pinout](#12-hardware-vspi--storage-pinout)
  - [1.3 Zero-Overhead Streaming Architecture](#13-zero-overhead-streaming-architecture)
  - [1.4 Dual-Core FreeRTOS Task Separation](#14-dual-core-freertos-task-separation)
  - [1.5 Dual-Network Gateway Routing Model](#15-dual-network-gateway-routing-model)
- [2. Prerequisites & Extension Setup](#2-prerequisites--extension-setup)
  - [2.1 Required Software & Extensions](#21-required-software--extensions)
  - [2.2 Wokwi License Activation](#22-wokwi-license-activation)
  - [2.3 Opening the Workspace Correctly](#23-opening-the-workspace-correctly)
- [3. Step-by-Step Simulation Execution](#3-step-by-step-simulation-execution)
  - [Step 0: Automated Environment & Dependency Setup (setup/)](#step-0-automated-environment--dependency-setup-setup)
  - [Step 1: Compile Firmware via PlatformIO](#step-1-compile-firmware-via-platformio)
  - [Step 2: Configure Windows Firewall (One-Click)](#step-2-configure-windows-firewall-one-click)
  - [Step 3: Launch Local Network Gateway (wokwigw)](#step-3-launch-local-network-gateway-wokwigw)
  - [Step 4: Start Wokwi Simulation](#step-4-start-wokwi-simulation)
  - [Step 5: Verify Boot Telemetry in Serial Monitor](#step-5-verify-boot-telemetry-in-serial-monitor)
- [4. Accessing the Server from External Devices](#4-accessing-the-server-from-external-devices)
  - [4.1 Why Multi-Interface Access Works (0.0.0.0:9080 Binding)](#41-why-multi-interface-access-works-00009080-binding)
  - [4.2 Scenario 1: Home Hybrid Testing (Host on Wired Ethernet, Client Phone/Laptop on Router Wi-Fi)](#42-scenario-1-home-hybrid-testing-host-on-wired-ethernet-client-phonelaptop-on-router-wi-fi)
  - [4.3 Scenario 2: Lab Workstation Testing (Both Devices on Wired Ethernet LAN Switch)](#43-scenario-2-lab-workstation-testing-both-devices-on-wired-ethernet-lan-switch)
  - [4.4 Scenario 3: Portable Showcase Hotspot (Host Laptop Hotspot with Mobile Clients)](#44-scenario-3-portable-showcase-hotspot-host-laptop-hotspot-with-mobile-clients)
  - [4.5 Master Endpoint & Host IP Mapping Table](#45-master-endpoint--host-ip-mapping-table)
- [5. Zero-Install Local Network File Sharing (LocalSend Web Model)](#5-zero-install-local-network-file-sharing-localsend-web-model)
  - [5.1 Bi-Directional File Transfer Workflow](#51-bi-directional-file-transfer-workflow)
  - [5.2 Web Endpoints & Service Breakdown](#52-web-endpoints--service-breakdown)
  - [5.3 Host SSD Storage Integration (data/network & 1GB Expansion)](#53-host-ssd-storage-integration-datanetwork--1gb-expansion)
  - [5.4 Transfer Speed Optimization & Live Progress Indicators](#54-transfer-speed-optimization--live-progress-indicators)
- [6. Troubleshooting & Common Pitfalls](#6-troubleshooting--common-pitfalls)
  - [6.1 Error: connect tcp 10.13.37.2:80: no route to host](#61-error-connect-tcp-101337280-no-route-to-host)
  - [6.2 Connection Timed Out from External Devices](#62-connection-timed-out-from-external-devices)
  - [6.3 Wokwi Cannot Find Firmware Binary](#63-wokwi-cannot-find-firmware-binary)
  - [6.4 MicroSD Card Mount Failure](#64-microsd-card-mount-failure)
- [7. Quick-Reference Command Cheat Sheet](#7-quick-reference-command-cheat-sheet)

---

## 1. System & Architecture Overview

[`Project.MM/LocalConfig`](.) contains a fully self-contained local simulation setup for an **ESP32-based Embedded Network Attached Storage (NAS) and Static Web Server**. Designed for the `CSE0611324` Microprocessor & Microcontrollers laboratory curriculum, it runs completely on your workstation without cloud dependencies or upload rate limits.

```
                      +---------------------------------------------------+
                      |               Host Workstation                    |
                      |   VS Code + PlatformIO + Wokwi Simulator Engine   |
                      +-------------------------+-------------------------+
                                                |
                                    ws://localhost:9011
                                                |
                                                ▼
                                    +-----------------------+
                                    |     wokwigw.exe       |
                                    | (Listens: 0.0.0.0:9080)|
                                    +-----------+-----------+
                                                |
                         +----------------------+----------------------+
                         |                                             |
                         ▼                                             ▼
            [Wired Ethernet Interface]                    [Windows Mobile Hotspot]
             IP: e.g., 192.168.1.105                        Virtual IP: 192.168.137.1
                         |                                             |
                         ▼                                             ▼
            Lab Workstations / PCs                       Smartphones & Tablets
```

### 1.1 Embedded Hardware Architecture
* **Target Microcontroller**: Classic ESP32 DevKit V1 powered by the Xtensa Dual-Core 32-bit LX6 microprocessor operating at 240 MHz, with 520 KB on-chip SRAM.
* **Storage Medium**: Hardware VSPI-driven MicroSD Card module formatted with standard FAT32 block storage.
* **Firmware Framework**: Native Arduino-ESP32 core (`WebServer.h`, `SD.h`, `SPI.h`, `WiFi.h`).

### 1.2 Hardware VSPI & Storage Pinout
The storage subsystem directly interfaces with the ESP32 hardware VSPI bus via physical GPIO pins defined in [`src/main.cpp`](src/main.cpp) and [`diagram.json`](diagram.json):

| ESP32 Hardware Pin | Signal Function | MicroSD Module Pin | Description |
| :--- | :--- | :--- | :--- |
| **`GPIO 5`** | **`CS`** (SS) | `CS` | Chip Select (Active Low) |
| **`GPIO 18`** | **`SCK`** | `SCK` / `CLK` | Serial Clock |
| **`GPIO 23`** | **`MOSI`** | `DI` | Master Out Slave In |
| **`GPIO 19`** | **`MISO`** | `DO` | Master In Slave Out |
| **`3V3`** | **`VCC`** | `VCC` | 3.3V Regulated Power |
| **`GND`** | **`GND`** | `GND` | Ground Reference |

### 1.3 Zero-Overhead Streaming Architecture
To prevent SRAM exhaustion on the 520 KB microcontroller during multi-megabyte file transfers:
* **Uploads**: Handled via `server.upload()` chunk-by-chunk streaming directly to the SD filesystem.
* **Downloads**: Handled via `server.streamFile()` in binary chunk buffers.
* **RAM Footprint**: Fixed at approximately **~2 KB** of heap memory regardless of whether transferring a 10 KB assembly program or a 20 MB binary image.

### 1.4 Dual-Core FreeRTOS Task Separation
The ESP32 firmware leverages dual-core Symmetric Multiprocessing (SMP):
* **Core 0**: Dedicated strictly to the lwIP (Lightweight IP) TCP/IP protocol stack and asynchronous Wi-Fi driver packet handling.
* **Core 1**: Runs the primary application event loop (`server.handleClient()`), SD card FAT32 sector reads/writes, and automated self-diagnostic health checks pinned via `xTaskCreatePinnedToCore`.

### 1.5 Dual-Network Gateway Routing Model
Virtual Wi-Fi inside the Wokwi simulator uses a private virtual subnet (`10.13.37.2`). The companion bridge binary [`wokwigw.exe`](wokwigw.exe) bridges this virtual subnet to the host:
* Communicates with Wokwi over WebSocket on `ws://localhost:9011`.
* Forwards host port `9080` to virtual ESP32 port `80` via:
  ```powershell
  .\wokwigw.exe --forward 9080:10.13.37.2:80
  ```
* Binds to `0.0.0.0:9080` (`INADDR_ANY`), making the simulator reachable over **Localhost**, **Physical Ethernet LAN**, and **Windows Mobile Hotspot Wi-Fi** at the same time.

---

## 2. Prerequisites & Extension Setup

### 2.1 Required Software & Extensions
Ensure your workstation has the following installed:
1. **Visual Studio Code** (version 1.80+ recommended).
2. **PlatformIO IDE Extension** (`platformio.platformio-ide`):
   - Handles the GCC Xtensa compiler toolchain, Arduino-ESP32 core libraries, and binary compilation.
3. **Wokwi Simulator Extension** (`wokwi.wokwi-vscode`):
   - Provides cycle-accurate hardware simulation and virtual SPI/Wi-Fi peripherals.

### 2.2 Wokwi License Activation
If this is your first time using the Wokwi extension in VS Code:
1. Press `F1` (or `Ctrl + Shift + P`) to open the Command Palette.
2. Type and select **`Wokwi: Request License`**.
3. Follow the one-time browser verification link to claim your license.

### 2.3 Opening the Workspace Correctly
> [!IMPORTANT]
> To prevent path mismatch errors, open the directory [`Project.MM/LocalConfig`](.) directly in VS Code (`File` > `Open Folder...`).
>
> If you open the top-level repository root (`Microprocessor_Assembly_Lab`), you must tell Wokwi where to find the configuration:
> 1. Press `F1` $\rightarrow$ select **`Wokwi: Select Config File`**.
> 2. Pick [`wokwi.toml`](wokwi.toml).

---

## 3. Step-by-Step Simulation Execution

Follow these steps in exact order to launch the simulation successfully:

```
+-----------------------------------------------------------------------------------+
|  Step 0: Automated Environment & Dependencies (setup/install_dependencies.bat)     |
|                                     ▼                                             |
|  Step 1: Compile Firmware (PlatformIO Build: Ctrl + Alt + B or build_firmware.bat)|
|                                     ▼                                             |
|  Step 2: Configure Windows Firewall (Run setup_firewall.bat as Admin)              |
|                                     ▼                                             |
|  Step 3: Launch Gateway (.\wokwigw.exe --forward 9080:10.13.37.2:80 or .bat)      |
|                                     ▼                                             |
|  Step 4: Launch Wokwi Simulation (diagram.json -> Wokwi: Start Simulator)         |
|                                     ▼                                             |
|  Step 5: Verify Serial Output & Access http://localhost:9080/                      |
+-----------------------------------------------------------------------------------+
```

### Step 0: Automated Environment & Dependency Setup (setup/)
The [`setup/`](setup/) folder provides automated batch and PowerShell scripts that handle all prerequisites on fresh or offline machines:

1. **One-Click Dependency Installation**:
   - Double-click [`setup/install_dependencies.bat`](setup/install_dependencies.bat) (or run [`setup/install_dependencies.ps1`](setup/install_dependencies.ps1) in PowerShell).
   - *What this automates*:
     - Verifies Python installation; if Python is missing, automatically downloads and installs it silently with `Add to PATH` enabled via [`setup/setup_python.bat`](setup/setup_python.bat).
     - Installs or updates the PlatformIO CLI (`pio`) and adds its `Scripts` directory to the user environment `PATH`.
     - Ensures [`wokwigw.exe`](wokwigw.exe) is present in both `LocalConfig/` and `setup/`.
     - Pre-installs and verifies Espressif 32 toolchains (`toolchain-xtensa-esp-elf` and `framework-arduinoespressif32`).
2. **Offline Installation (No Internet Required via GitHub Releases)**:
   - For campus lab machines without internet access, download the pre-packaged ~600MB localized toolchains archive (`platformio_cache.zip`) from **[GitHub Releases: wokwi_env_setup_script](https://github.com/b1tranger/wokwi_env_setup_script/releases/tag/platformio_cache.zip)**.
   - Direct Download: [platformio_cache.zip](https://github.com/b1tranger/wokwi_env_setup_script/releases/download/platformio_cache.zip/platformio_cache.zip)
   - Place the downloaded archive into [`setup/PlatformIO_Espressif_Offline_Installer/`](setup/PlatformIO_Espressif_Offline_Installer/).
   - Run [`setup/install_dependencies.bat`](setup/install_dependencies.bat) or [`setup/PlatformIO_Espressif_Offline_Installer/install_offline.bat`](setup/PlatformIO_Espressif_Offline_Installer/install_offline.bat). Both automatically detect the archive, extract the toolchains, and complete setup with zero network required.
   - For complete technical documentation on offline setup, see [`setup/SETUP_GUIDE.md`](setup/SETUP_GUIDE.md).
3. **Reverting Changes & Uninstallation**:
   - If you ever need to revert firewall rules, stop gateway processes, and remove environment variables, run [`setup/uninstall_dependencies.bat`](setup/uninstall_dependencies.bat).

### Step 1: Compile Firmware via PlatformIO
Once dependencies are initialized, compile the C++ firmware into a simulation binary:
* **Option A (VS Code GUI)**: Click the **Build Checkmark (✓)** icon on the bottom blue status bar, or press `Ctrl + Alt + B`.
* **Option B (One-Click Script)**: Double-click [`setup/build_firmware.bat`](setup/build_firmware.bat) (or run [`setup/build_firmware.ps1`](setup/build_firmware.ps1)).
* **Option C (CLI)**: Open a terminal inside `LocalConfig` and run `pio run`.

PlatformIO compiles the firmware and outputs the final ELF and binary files to:
```text
.pio/build/esp32dev/firmware.bin
.pio/build/esp32dev/firmware.elf
```

### Step 2: Configure Windows Firewall (One-Click)
External devices connecting to your PC's IP on port `9080` will be blocked by Windows Firewall by default. To whitelist port `9080`:
1. In File Explorer or inside the VS Code terminal, locate [`setup_firewall.bat`](setup_firewall.bat) (also available as [`setup/setup_firewall.bat`](setup/setup_firewall.bat)).
2. Right-click and choose **Run as administrator** (or double-click; it auto-elevates via UAC prompt).
3. The script executes the following PowerShell rule across all network profiles (Domain, Private, Public):
   ```powershell
   New-NetFirewallRule -DisplayName "Wokwi Gateway NAS" -Direction Inbound -LocalPort 9080 -Protocol TCP -Profile Any -Action Allow
   ```
4. Verify the terminal outputs:
   ```text
   [SUCCESS] Port 9080 is now open across all profiles!
   ```

### Step 3: Launch Local Network Gateway (wokwigw)
The gateway must be running **before** starting the simulation so the ESP32 can register on the virtual network:
* **Option A (Direct Terminal)**: Open a PowerShell terminal inside `LocalConfig` and run:
  ```powershell
  .\wokwigw.exe --forward 9080:10.13.37.2:80
  ```
* **Option B (One-Click Script)**: Double-click [`setup/start_gateway.bat`](setup/start_gateway.bat) (or run [`setup/start_gateway.ps1`](setup/start_gateway.ps1)).

You will see output confirming the listener has started:
```text
wokwigw version 0.1.0
Listening on 0.0.0.0:9080 -> 10.13.37.2:80
WebSocket server listening on ws://127.0.0.1:9011
```
**Keep this terminal window open and running.** Do not close it.

### Step 4: Start Wokwi Simulation
1. Click to open [`diagram.json`](diagram.json) in VS Code editor.
2. Press `F1` (or `Ctrl + Shift + P`) to open the Command Palette.
3. Type and select: **`Wokwi: Start Simulator`** (or click the green **Play** button at the top of the diagram view).

### Step 5: Verify Boot Telemetry in Serial Monitor
Observe the integrated Serial Monitor window in VS Code. You should see the complete boot sequence:
```text
--------------------------------------------------
  [PHASE 1 EXECUTION] Mounting MicroSD via VSPI   
--------------------------------------------------
[PHASE 1 SUCCESS] FAT32 Storage Mounted.
[PHASE 1 CAPACITY] Total: 8 MB | Used: 1 MB
[STORAGE] Seeded modern /www/index.html to SD
[STORAGE] Seeded /lab_report.txt to SD
[PHASE 1 DIRECTORY TREE]:
  |- /www (DIR)
  |- /www/index.html (3.4 KB)
  |- /lab_report.txt (240 B)
--------------------------------------------------

[PHASE 2 NET] Connecting to Wi-Fi SSID: Wokwi-GUEST ...
[PHASE 2 NET] Wi-Fi Connected!
[PHASE 2 NET] Node IP Address: 10.13.37.2
[PHASE 2 HTTP] Server active and listening on port 80.
[PHASE 2 ENDPOINTS]
  - NAS Explorer : http://10.13.37.2/
  - Static Web   : http://10.13.37.2/site
  - File Download: http://10.13.37.2/get?file=<name>
  - File Upload  : http://10.13.37.2/upload (POST)
  - File Delete  : http://10.13.37.2/delete?file=<name>
```

Open your host browser to test local access:
* **NAS Dashboard**: [http://localhost:9080/](http://localhost:9080/)
* **Static Hosted Website**: [http://localhost:9080/site](http://localhost:9080/site)

---

## 4. Accessing the Server from External Devices

You can connect external smartphones, tablets, and peer lab PCs to the simulated ESP32 without modifying any simulation files.

### 4.1 Why Multi-Interface Access Works (0.0.0.0:9080 Binding)
When `wokwigw.exe` starts, it creates a socket listening on `0.0.0.0:9080` (`INADDR_ANY`). Rather than locking to loopback (`127.0.0.1`), it accepts incoming TCP packets on **every physical and virtual network adapter** active on the Windows host machine.

Any device that can ping or route to an IP address belonging to your host PC can access the ESP32 server over port `9080`.

---

### 4.2 Scenario 1: Home Hybrid Testing (Host on Wired Ethernet, Client Phone/Laptop on Router Wi-Fi)
In this home setup, your host workstation running the simulation is plugged into the Wi-Fi router via physical Ethernet cable, while your smartphone, tablet, or secondary laptop connects wirelessly to the same router:

```
                      +------------------------------------------+
                      |         Home Wi-Fi Router Gateway        |
                      |          (Subnet: e.g. 192.168.0.1)      |
                      +--------------------+---------------------+
                                           |
                    +----------------------+----------------------+
                    | (Physical Ethernet)                         | (Wi-Fi 2.4/5 GHz)
                    ▼                                             ▼
+---------------------------------------+     +---------------------------------------+
|  Host PC (Running Simulation)         |     |  Mobile Device / Secondary Laptop     |
|  Ethernet IP: e.g., 192.168.0.105     |     |  Wi-Fi IP: e.g., 192.168.0.120        |
|  wokwigw.exe listening: 0.0.0.0:9080  |     |  Opens Browser to Host Ethernet IP:   |
|  setup_firewall.bat PORT 9080 ALLOWED |     |  http://192.168.0.105:9080/          |
+---------------------------------------+     +---------------------------------------+
```

#### Step-by-Step Instructions:
1. **Find the Host Ethernet IP**:
   - On the host PC running the simulation, open PowerShell and execute:
     ```powershell
     ipconfig
     ```
   - Locate the section titled **`Ethernet adapter Ethernet`** (or `Ethernet adapter vEthernet` / your main wired NIC).
   - Note the **`IPv4 Address`** (for example: `192.168.0.105` or `192.168.1.50`).
   > [!IMPORTANT]
   > Do **not** look for "Wireless LAN adapter Wi-Fi" on the host PC if it is plugged in via Ethernet! The host PC is communicating through its wired NIC, so client devices must target the host's **Ethernet IPv4 address**.

2. **Verify Network Profile**:
   - Standard home routers bridge Ethernet LAN ports and Wi-Fi into the exact same broadcast subnet (`192.168.0.x`).
   - Run [`setup_firewall.bat`](setup_firewall.bat) as Administrator once to ensure inbound port 9080 is permitted.

3. **Connect from Phone/Laptop**:
   - Ensure the phone or secondary laptop is connected to your home Wi-Fi SSID.
   - Open Chrome, Safari, or Firefox on the mobile device and navigate to:
     - **NAS File Dashboard**: `http://<HOST_ETHERNET_IP>:9080/` (e.g. `http://192.168.0.105:9080/`)
     - **Hosted Static Webpage**: `http://<HOST_ETHERNET_IP>:9080/site`

---

### 4.3 Scenario 2: Lab Workstation Testing (Both Devices on Wired Ethernet LAN Switch)
In the microprocessor laboratory, both the host workstation running the simulation (PC 1) and peer student workstations (PC 2) are connected via physical RJ45 Ethernet patch cables to the same campus lab switch:

```
                      +------------------------------------------+
                      |         Campus Lab Ethernet Switch       |
                      |       (Local Subnet: e.g. 10.100.x.x)    |
                      +--------------------+---------------------+
                                           |
                    +----------------------+----------------------+
                    | (Ethernet Cable 1)                          | (Ethernet Cable 2)
                    ▼                                             ▼
+---------------------------------------+     +---------------------------------------+
|  Lab PC 1: Host Node (Simulation)     |     |  Lab PC 2: Peer Client Workstation    |
|  Ethernet IP: e.g., 10.100.22.45      |     |  Ethernet IP: e.g., 10.100.22.48      |
|  wokwigw.exe listening: 0.0.0.0:9080  |     |  Opens Chrome/Edge (No Install Needed)|
|  setup_firewall.bat PORT 9080 ALLOWED |     |  http://10.100.22.45:9080/            |
+---------------------------------------+     +---------------------------------------+
```

#### Step-by-Step Instructions:
1. **Ensure Both PCs are Plugged Into the Lab Switch**:
   - Both PC 1 and PC 2 should have active link lights on their Ethernet ports.
2. **Retrieve PC 1 Ethernet IP**:
   - On PC 1, open PowerShell and run:
     ```powershell
     ipconfig
     ```
   - Copy the `IPv4 Address` under `Ethernet adapter Ethernet` (e.g. `10.100.22.45` or `192.168.1.105`).
3. **Run Firewall Setup on PC 1**:
   - Run [`setup_firewall.bat`](setup_firewall.bat) as Administrator on PC 1.
4. **Access from PC 2**:
   - On PC 2, open any browser and enter `http://<PC1_ETHERNET_IP>:9080/`.
   - PC 2 can now immediately download files from the ESP32 or upload assembly programs and reports without installing any software.

---

### 4.4 Scenario 3: Portable Showcase Hotspot (Host Laptop Hotspot with Mobile Clients)
During project defense or when network access in the lab is restricted (e.g. campus Wi-Fi has strict Client/AP Isolation blocking inter-device communication), turn your host laptop into a Wi-Fi Access Point using Windows Mobile Hotspot:

```
+-----------------------------------------------------------------------------------+
|  Host Laptop (Windows 10 / 11)                                                    |
|  1. Enable Windows Mobile Hotspot (Share over: Wi-Fi)                             |
|  2. Windows automatically assigns Host Gateway IP: 192.168.137.1                  |
|  3. wokwigw.exe listens on 0.0.0.0:9080 (Binds directly to virtual hotspot NIC)  |
+-----------------------------------------------------------------------------------+
                                          ▲
                                          │ (Direct Wi-Fi 2.4/5 GHz Connection)
+-----------------------------------------------------------------------------------+
|  Evaluator / Peer Mobile Device (Smartphones, Tablets, External Laptops)          |
|  1. Connect to Laptop Hotspot SSID                                                |
|  2. Open Mobile Browser -> http://192.168.137.1:9080/                             |
+-----------------------------------------------------------------------------------+
```

#### Step-by-Step Instructions:
1. **Enable Mobile Hotspot on Host Laptop**:
   - Press `Win + I` $\rightarrow$ **Network & internet** $\rightarrow$ **Mobile hotspot**.
   - Set **Share my internet connection from**: `Ethernet` (or `Wi-Fi` if connected to campus Wi-Fi).
   - Set **Share over**: `Wi-Fi`.
   - Toggle **Mobile hotspot** to **ON**.
   - Note the **Network name (SSID)** and **Password**.
2. **Deterministic Gateway IP (`192.168.137.1`)**:
   - Windows automatically assigns the host PC the virtual IP **`192.168.137.1`** on the Microsoft Wi-Fi Direct Virtual Adapter.
   - This IP is **always identical** across all Windows machines, making it completely predictable for live presentations.
3. **Connect Client Mobile Devices**:
   - On evaluators' or team members' phones/tablets, connect to the laptop hotspot SSID.
4. **Browse Endpoints**:
   - Open any mobile browser and navigate to:
     - **NAS Dashboard**: `http://192.168.137.1:9080/`
     - **Static Site**: `http://192.168.137.1:9080/site`
5. **Why This is the Ultimate Presentation Safeguard**:
   - It forms a 100% self-contained private wireless LAN completely independent of campus firewalls, router port filtering, or internet outages.

---

### 4.5 Master Endpoint & Host IP Mapping Table

| Deployment Scenario | Connected Client Device | Host IP to Type into Client Browser | NAS Dashboard URL | Static Hosted Web URL |
| :--- | :--- | :--- | :--- | :--- |
| **Local Testing** | Host PC (Where VS Code runs) | `localhost` or `127.0.0.1` | [http://localhost:9080/](http://localhost:9080/) | [http://localhost:9080/site](http://localhost:9080/site) |
| **Scenario 1: Home Hybrid** | Phone / laptop on Home Wi-Fi (Host on Ethernet) | `<HOST_ETHERNET_IP>` *(from `ipconfig`)* | `http://<HOST_ETHERNET_IP>:9080/` | `http://<HOST_ETHERNET_IP>:9080/site` |
| **Scenario 2: Lab Wired** | Peer student PC on campus switch (Both on Ethernet) | `<PC1_ETHERNET_IP>` *(from `ipconfig`)* | `http://<PC1_ETHERNET_IP>:9080/` | `http://<PC1_ETHERNET_IP>:9080/site` |
| **Scenario 3: Laptop Hotspot** | Evaluator smartphones, tablets, or laptops on hotspot | `192.168.137.1` *(Deterministic Gateway)* | `http://192.168.137.1:9080/` | `http://192.168.137.1:9080/site` |

---

## 5. Zero-Install Local Network File Sharing (LocalSend Web Model)

### 5.1 Bi-Directional File Transfer Workflow
`Project.MM` functions identically to the popular **LocalSend "Share via Browser"** web feature. No software or apps need to be installed on client devices:

```text
  [Lab PC 1: Host Node]                                 [Lab PC 2: Peer Client]
  +----------------------------------+                  +----------------------------------+
  | Wokwi Simulator (ESP32 DevKit)   |                  | Standard Web Browser             |
  |   ↕ (ws://localhost:9011)        |                  | (Chrome / Edge / Safari)         |
  | wokwigw.exe (0.0.0.0:9080)       |                  |                                  |
  | Windows Firewall Port 9080 OPEN  |                  | Navigates to:                    |
  +-----------------+----------------+                  | http://<HOST_IP>:9080/           |
                    |                                   +-----------------+----------------+
                    |                                                     |
                    +=================== LAN SWITCH =====================+
                                (or Windows Mobile Hotspot)
```

1. **Step A (Upload from PC 1 $\rightarrow$ Download on PC 2)**:
   - On PC 1, go to `http://localhost:9080/` and upload an assembly file (e.g., `labtest2.asm`).
   - The file is written to the virtual MicroSD card.
   - On PC 2, refresh `http://<HOST_IP>:9080/` and click the **Download** button. The file streams directly from the ESP32 storage into PC 2's Downloads folder.
2. **Step B (Upload from PC 2 $\rightarrow$ Download on PC 1)**:
   - On PC 2, click **Choose File**, select a report (e.g., `report.pdf`), and click **Upload to ESP32**.
   - On PC 1, refresh the dashboard to see `report.pdf` listed and download it locally.
3. **Step C (Live Storage Telemetry)**:
   - As files are uploaded or deleted, the dynamic storage progress bar automatically updates the total capacity, used space, and free space in real-time.

---

### 5.2 Web Endpoints & Service Breakdown

The ESP32 firmware in [`src/main.cpp`](src/main.cpp) serves five dedicated REST/HTTP routes:

* **`GET /` (NAS Dashboard)**:
  - Generates the responsive glassmorphic dark-theme UI defined in [`include/html_templates.h`](include/html_templates.h).
  - Displays hardware telemetry (CPU frequency, chip model, free heap, storage usage) and the active file directory table.
* **`GET /site` (Static Web Hosting)**:
  - Streams the pre-seeded static webpage `/www/index.html` stored on the MicroSD card directly to the client browser.
* **`GET /get?file=<filename>` (File Download)**:
  - Streams any file on the FAT32 filesystem as a `binary/octet-stream` download attachment.
* **`POST /upload` (Multipart File Upload)**:
  - Receives multi-part file payloads and streams them directly into `SD.open(filename, FILE_WRITE)` using a fixed ~2 KB buffer.
* **`GET /delete?file=<filename>` (File Removal)**:
  - Deletes the specified file from the SD card using `SD.remove()` and redirects back to `/`. Rejects protected default files with `HTTP 403 Forbidden`.

---

### 5.3 Host SSD Storage Integration (`data/network` & 1GB Expansion)

By default, Wokwi creates an ephemeral in-memory FAT16 virtual card capped at 8 MB. To lift this limitation and map storage directly to your workstation's physical HDD/SSD:

1. **`wokwi.toml` Hardware Storage Mapping**:
   The simulator configuration in [`wokwi.toml`](wokwi.toml) binds the virtual SD card directly to the host directory [`data/network/`](data/network/):
   ```toml
   [[sdcard]]
   part = "sd1"
   folder = "data/network"
   size = "1G"
   writeback = true
   ```
2. **Key Capabilities Enabled**:
   * **1,024 MB (1 GB) Real Capacity**: The storage limit is expanded from 8 MB to 1 GB, removing capacity constraints for documents, PDFs, and laboratory archives.
   * **Live Bi-Directional Host Sync (`writeback = true`)**:
     - Files uploaded by clients through the web interface are saved into `/uploads/` and written directly back to [`data/network/uploads/`](data/network/) on your host computer's SSD.
     - Files deleted via the web interface are deleted from [`data/network/`](data/network/) on the host PC.
     - Any file placed directly into [`data/network/`](data/network/) on your host PC is automatically mounted and served by the ESP32 file server upon simulation start.
3. **Write Protection on System Files**:
   - Default system assets ([`data/default/lab_report.txt`](data/default/lab_report.txt) and [`data/www/index.html`](data/www/index.html)) are write-protected.
   - In the web table, protected items display a `🔒 Protected` badge.
   - Any manual `GET /delete` request targeting protected system files is rejected with **`HTTP 403 Forbidden`**.

---

### 5.4 Transfer Speed Optimization & Live Progress Indicators

To maximize file transfer throughput and provide real-time user feedback:

1. **Hardware SPI Bus Clock Boost (25 MHz)**:
   In [`src/main.cpp`](src/main.cpp), storage initialization is upgraded from the standard 4 MHz clock to **25 MHz** (`SD.begin(SD_CS_PIN, SPI, 25000000)`), maximizing hardware bus bandwidth on the ESP32 VSPI controller.
2. **Sector-Aligned 4 KB Write Buffering**:
   Instead of writing unaligned 1436-byte TCP segments directly to the SD card, `handleFileUpload()` buffers incoming stream chunks into a 4,096-byte memory block (`uploadWriteBuffer`) and writes in sector-aligned units. This minimizes FAT cluster allocation latency and virtual SPI transaction stalls.
3. **Real-Time Client Upload Progress & Speedometer**:
   The dashboard UI uses asynchronous XMLHttpRequest streaming with live telemetry:
   * **Real-Time Progress Bar**: Smooth glowing progress bar tracking `0%` to `100%`.
   * **Transfer Speed Meter**: Instantaneous smoothed transfer rate displayed in real time (e.g., `⚡ 124.5 KB/s` or `⚡ 1.2 MB/s`).
   * **Transferred Bytes**: Exact byte counts (e.g., `4.2 MB / 10.0 MB`).
   * **Dynamic ETA**: Estimated completion time remaining (e.g., `⏱ 45s left`).
   * **Zero Page Freezing**: Files upload asynchronously in the background and trigger an automatic table refresh upon completion.

---

## 6. Troubleshooting & Common Pitfalls

### 6.1 Error: `connect tcp 10.13.37.2:80: no route to host`
* **Root Cause**: The Wokwi simulator was started before `wokwigw.exe`, or Wokwi failed to connect to `ws://localhost:9011`. The virtual ESP32 is therefore not registered in the gateway's routing table.
* **Solution**:
  1. Verify [`wokwi.toml`](wokwi.toml) includes:
     ```toml
     [net]
     gateway = "ws://localhost:9011"
     ```
  2. Stop the Wokwi simulation in VS Code (click the Stop icon in the diagram).
  3. Ensure `wokwigw.exe` is actively running in its own terminal window:
     ```powershell
     .\wokwigw.exe --forward 9080:10.13.37.2:80
     ```
  4. Now restart the simulator: open [`diagram.json`](diagram.json), press `F1`, and select **`Wokwi: Start Simulator`**.
  5. The `wokwigw` terminal will log `New connection from 127.0.0.1` and assign DHCP IP `10.13.37.2`.

---

### 6.2 Connection Timed Out from External Devices
* **Root Cause 1: Windows Firewall Blocking Port 9080**:
  - Run [`setup_firewall.bat`](setup_firewall.bat) as Administrator to add the inbound rule for TCP port 9080.
* **Root Cause 2: Wrong IPv4 Address**:
  - Re-run `ipconfig` on the host machine to make sure your IP has not changed after switching networks.
* **Root Cause 3: AP / Client Isolation on Campus Wi-Fi**:
  - Public institutional Wi-Fi networks frequently block peer-to-peer traffic. Switch to **Method A (Windows Mobile Hotspot)** so your laptop acts as the router.

---

### 6.3 Wokwi Cannot Find Firmware Binary
* **Root Cause**: The project has not been compiled yet, or the workspace was opened at a different folder level.
* **Solution**:
  1. Run `pio run` (or press `Ctrl + Alt + B`) to verify `.pio/build/esp32dev/firmware.bin` is generated.
  2. If opened from the repository root, press `F1` $\rightarrow$ select **`Wokwi: Select Config File`** $\rightarrow$ choose [`wokwi.toml`](wokwi.toml).

---

### 6.4 MicroSD Card Mount Failure
* **Root Cause**: Wiring mismatch in simulation schematics.
* **Solution**: Inspect [`diagram.json`](diagram.json) to verify the VSPI pin assignments:
  - `esp:D5` $\rightarrow$ `sd1:CS`
  - `esp:D18` $\rightarrow$ `sd1:SCK`
  - `esp:D19` $\rightarrow$ `sd1:DO`
  - `esp:D23` $\rightarrow$ `sd1:DI`

---

## 7. Quick-Reference Command Cheat Sheet

```powershell
# 1. Compile Firmware
pio run

# 2. Configure Windows Firewall (Run as Admin)
.\setup_firewall.bat

# 3. Launch Local Network Gateway
.\wokwigw.exe --forward 9080:10.13.37.2:80

# 4. Check Host IP Addresses
ipconfig

# 5. Access Endpoints
# Localhost (Host PC):
http://localhost:9080/
http://localhost:9080/site

# Scenario 1 - Home Hybrid (Host on Ethernet, Phone/Laptop on Wi-Fi):
http://<HOST_ETHERNET_IP>:9080/
http://<HOST_ETHERNET_IP>:9080/site

# Scenario 2 - Lab Wired (Both PCs on Campus Ethernet Switch):
http://<PC1_ETHERNET_IP>:9080/
http://<PC1_ETHERNET_IP>:9080/site

# Scenario 3 - Laptop Mobile Hotspot (Phones & Tablets):
http://192.168.137.1:9080/
http://192.168.137.1:9080/site

# 6. Revert All Setup & Simulation Changes (Run as Admin)
.\setup\uninstall_dependencies.bat
```

