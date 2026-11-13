# Microprocessor & Microcontrollers Lab Project (Project.MM)

## Table of Contents
- [1. Project Overview](#1-project-overview)
- [2. Repository Architecture](#2-repository-architecture)
- [3. Quick Start: Local VS Code Simulation (LocalConfig/)](#3-quick-start-local-vs-code-simulation-localconfig)
  - [3.1 Quick Start: Wokwi Web Cloud Simulation (CloudConfig/)](#31-quick-start-wokwi-web-cloud-simulation-cloudconfig)
  - [3.2 Multi-Device & 2-Computer LAN File Sharing (LocalSend Web Model)](#32-multi-device--2-computer-lan-file-sharing-localsend-web-model)
- [4. First-Time Environment Setup](#4-first-time-environment-setup)
- [5. Simulated Hardware & Web Endpoints](#5-simulated-hardware--web-endpoints)
- [6. Documentation References](#6-documentation-references)

---

## 1. Project Overview
This project implements an **Embedded Network Attached Storage (NAS) and Static Web Server** running on an **ESP32 microcontroller** with a **FAT32 MicroSD card module** interfaced over the hardware SPI bus.

The system is fully simulated locally inside Visual Studio Code using the **Wokwi Simulator** and **PlatformIO IDE**, with network traffic bridged to your desktop web browser via the **Wokwi IoT Gateway (`wokwigw`)**.

---

## 2. Repository Architecture

```text
Project.MM/
│
├── PRESENTATION_GUIDE.md      # Comprehensive presentation guide & oral defense aide
├── README.md                  # Project root overview and navigation
│
├── LocalConfig/               # Local VS Code Workspace (Run interactive simulation here)
│   ├── platformio.ini         # Toolchain & ESP32 Arduino framework descriptor
│   ├── wokwi.toml             # Wokwi simulation descriptor & network gateway target
│   ├── diagram.json           # Circuit schematics & SPI pin wiring
│   ├── wokwigw.exe            # Gateway binary for standalone execution
│   ├── setup_firewall.bat     # One-click UAC auto-elevated Windows Firewall rule installer
│   ├── presentationBridge.md  # Presenter's 10-minute speech script & team role division
│   ├── README.md              # Project-level execution and operational guide
│   ├── .gitignore             # Ignores .pio/ build artifacts & IDE cache
│   ├── include/
│   │   └── html_templates.h   # Modular glassmorphic HTML/CSS templates & PROGMEM strings
│   └── src/
│       └── main.cpp           # ESP32 C++ firmware (Dual-phase storage & web server)
│
├── CloudConfig/               # Standalone Wokwi Web Workspace (Run on wokwi.com)
│   ├── README.md              # Step-by-step Wokwi Web import and execution guide
│   ├── sketch.ino             # Arduino sketch with in-simulation loopback client
│   ├── html_templates.h       # Glassmorphic UI CSS and static site templates
│   ├── diagram.json           # Wokwi cloud circuit schematic
│   └── libraries.txt          # Library manifest (Empty: drivers built into core)
│
├── setup/                     # Dedicated dependencies, installers, and setup tools
│   ├── SETUP_GUIDE.md         # In-depth setup, dependency, and troubleshooting guide
│   ├── install_dependencies.ps1 # Auto-installer for Python & PlatformIO CLI
│   ├── build_firmware.ps1     # Automated PlatformIO compilation script
│   ├── start_gateway.ps1      # Launcher for Wokwi IoT Gateway (wokwigw)
│   └── wokwigw.exe            # Pre-packaged Wokwi IoT Gateway binary
│
└── doc/                       # Project research, proposals, and lab documentation
    ├── CLOUD_VS_VSCODE_VS_HARDWARE.md # Tri-platform architectural comparison
    └── research/              # Academic proposals and implementation guides
```

---

## 3. Quick Start: Local VS Code Simulation (`LocalConfig/`)

Once initial dependencies are installed, you run the simulation entirely inside [`Project.MM/LocalConfig/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig) following [`Project.MM/LocalConfig/runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md):

### Step 1: Open the Project in VS Code
Open the directory `Project.MM/LocalConfig` in VS Code (`File` > `Open Folder...`).

### Step 2: Launch the Network Bridge
Open PowerShell inside `Project.MM/LocalConfig/` and run:
```powershell
.\wokwigw.exe --forward 9080:10.13.37.2:80
```
*(Leave this terminal window running in the background).*

### Step 3: Start the Wokwi Simulation
1. Open [`Project.MM/LocalConfig/diagram.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/diagram.json).
2. Press **`F1`** (or `Ctrl + Shift + P`) and run **`Wokwi: Start Simulator`**.
3. Watch the Serial Monitor mount storage, seed files, connect to virtual Wi-Fi, and start listening on port 80.

### Step 4: Interact via Your Browser
- **NAS File Manager**: [http://localhost:9080/](http://localhost:9080/)
- **Hosted Static Webpage**: [http://localhost:9080/site](http://localhost:9080/site)
- **Direct File Download**: [http://localhost:9080/get?file=lab_report.txt](http://localhost:9080/get?file=lab_report.txt)

---

## 3.1 Quick Start: Wokwi Web Cloud Simulation (`CloudConfig/`)

If you want to run the project entirely inside your browser on **[wokwi.com](https://wokwi.com)** without installing any software:
1. Open [`Project.MM/CloudConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/CloudConfig/README.md).
2. Follow the 5-minute setup to create a project with `sketch.ino`, `diagram.json`, and `html_templates.h`.
3. Hit **Play** to observe the in-simulation FreeRTOS client automatically test storage, web server, and file streaming over `127.0.0.1`!

---

## 3.2 Multi-Device & 2-Computer LAN File Sharing (LocalSend Web Model)

The local gateway (`wokwigw.exe`) binds to `0.0.0.0:9080`, allowing the simulated ESP32 NAS to act as a **zero-install local file-sharing hub** across the entire lab room (operating identically to the **LocalSend Web** "Share via Browser" model):

1. **Firewall Rule**: Run [`Project.MM/LocalConfig/setup_firewall.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup_firewall.bat) as Administrator once to permit inbound TCP port 9080 across all network profiles.
2. **Access from Other Lab Computers**: Connect the second computer to the same Ethernet switch or host Wi-Fi hotspot, and open `http://<HOST_IP>:9080/` in its browser.
3. **Bi-directional Sharing**: Upload files from either computer $\rightarrow$ they are written directly to the ESP32 MicroSD FAT32 storage $\rightarrow$ download them from the other machine!

---

## 4. First-Time Environment Setup

If you are setting up the environment for the first time or on a new PC, all tools and automated scripts are located in [`Project.MM/LocalConfig/setup/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup):

1. **Automated Dependency Setup**:
   ```cmd
   .\Project.MM\LocalConfig\setup\install_dependencies.bat
   ```
   *(Or in PowerShell: `powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\install_dependencies.ps1`)*

2. **Build the Firmware**:
   ```cmd
   .\Project.MM\LocalConfig\setup\build_firmware.bat
   ```
   *(Or in PowerShell: `powershell -ExecutionPolicy Bypass -File .\Project.MM\LocalConfig\setup\build_firmware.ps1`)*
3. **Claim Free Wokwi License**:
   In VS Code: Press `F1` $\rightarrow$ `Wokwi: Request a New License` $\rightarrow$ authorize in browser.

*(For detailed manual installation instructions, refer to the [`Project.MM/LocalConfig/setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/SETUP_GUIDE.md)).*

---

## 5. Simulated Hardware & Web Endpoints

### SPI Hardware Pin Mapping:
- **`esp:D5`** $\rightarrow$ `sd1:CS` (Chip Select)
- **`esp:D23`** $\rightarrow$ `sd1:DI` (MOSI)
- **`esp:D19`** $\rightarrow$ `sd1:DO` (MISO)
- **`esp:D18`** $\rightarrow$ `sd1:SCK` (Serial Clock)
- **`esp:3V3`** $\rightarrow$ `sd1:VCC`, **`esp:GND.1`** $\rightarrow$ `sd1:GND`

### Firmware Architecture (`Project.MM/LocalConfig/src/main.cpp`):
- **Phase 1**: Hardware VSPI mounting, automatic seeding of `/www/index.html` and `/lab_report.txt`, and file enumeration.
- **Phase 2**: Asynchronous WebServer handling root dashboard (`/`), static hosting (`/site`), streaming downloads (`/get`), multipart uploads (`/upload`), and background auto-diagnostics running on FreeRTOS Core 1.

---

## 6. Documentation References

- **Comprehensive Run & Network Access Guide**: [`Project.MM/LocalConfig/runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md)
- **Local Simulation Workspace Guide**: [`Project.MM/LocalConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md)
- **Team Presentation Bridge (10-Minute Script & Speaker Roles)**: [`Project.MM/LocalConfig/presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/presentationBridge.md)
- **Presentation & Oral Defense Guide**: [`Project.MM/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/PRESENTATION_GUIDE.md)
- **Cloud vs. VS Code vs. Physical Hardware**: [`Project.MM/doc/CLOUD_VS_VSCODE_VS_HARDWARE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/doc/CLOUD_VS_VSCODE_VS_HARDWARE.md)
- **Cloud Simulation Workspace Guide**: [`Project.MM/CloudConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/CloudConfig/README.md)
- **Setup & Dependencies**: [`Project.MM/LocalConfig/setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/SETUP_GUIDE.md)
- **Theory & Archiving Notes**: [`doc/prompts/12.Wokwi VS Code Extension and ESP32 NAS Setup.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/prompts/12.Wokwi%20VS%20Code%20Extension%20and%20ESP32%20NAS%20Setup.md)

