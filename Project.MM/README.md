# Microprocessor & Microcontrollers Lab Project (Project.MM)

## Table of Contents
- [1. Project Overview](#1-project-overview)
- [2. Repository Architecture](#2-repository-architecture)
- [3. Quick Start (Running the Project)](#3-quick-start-running-the-project)
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
├── README.md                  # Project root overview and navigation
│
├── setup/                     # Dedicated dependencies, installers, and setup tools
│   ├── SETUP_GUIDE.md         # In-depth setup, dependency, and troubleshooting guide
│   ├── install_dependencies.ps1 # Auto-installer for Python & PlatformIO CLI
│   ├── build_firmware.ps1     # Automated PlatformIO compilation script
│   ├── start_gateway.ps1      # Launcher for Wokwi IoT Gateway (wokwigw)
│   └── wokwigw.exe            # Pre-packaged Wokwi IoT Gateway binary
│
├── ESP32_NAS_Server/          # Active Project Workspace (Run the simulation here)
│   ├── platformio.ini         # Toolchain & ESP32 Arduino framework descriptor
│   ├── wokwi.toml             # Wokwi simulation descriptor & network gateway target
│   ├── diagram.json           # Circuit schematics & SPI pin wiring
│   ├── wokwigw.exe            # Gateway binary for standalone execution
│   ├── README.md              # Project-level execution and operational guide
│   ├── .gitignore             # Ignores .pio/ build artifacts & IDE cache
│   └── src/
│       └── main.cpp           # ESP32 C++ firmware (Dual-phase storage & web server)
│
└── doc/                       # Project research, proposals, and lab documentation
    └── research/              # Academic proposals and implementation guides
```

---

## 3. Quick Start (Running the Project)

Once initial dependencies are installed, you run the simulation entirely inside [`Project.MM/ESP32_NAS_Server/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/ESP32_NAS_Server) without needing the `Project.MM/setup/` folder:

### Step 1: Open the Project in VS Code
Open the directory `Project.MM/ESP32_NAS_Server` in VS Code (`File` > `Open Folder...`).

### Step 2: Launch the Network Bridge
Open PowerShell inside `Project.MM/ESP32_NAS_Server/` and run:
```powershell
.\wokwigw.exe --forward 9080:10.13.37.2:80
```
*(Leave this terminal window running in the background).*

### Step 3: Start the Wokwi Simulation
1. Open [`Project.MM/ESP32_NAS_Server/diagram.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/ESP32_NAS_Server/diagram.json).
2. Press **`F1`** (or `Ctrl + Shift + P`) and run **`Wokwi: Start Simulator`**.
3. Watch the Serial Monitor mount storage, seed files, connect to virtual Wi-Fi, and start listening on port 80.

### Step 4: Interact via Your Browser
- **NAS File Manager**: [http://localhost:9080/](http://localhost:9080/)
- **Hosted Static Webpage**: [http://localhost:9080/site](http://localhost:9080/site)
- **Direct File Download**: [http://localhost:9080/get?file=lab_report.txt](http://localhost:9080/get?file=lab_report.txt)

---

## 4. First-Time Environment Setup

If you are setting up the environment for the first time or on a new PC, all tools and automated scripts are located in [`Project.MM/setup/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/setup):

1. **Automated Dependency Setup**:
   ```powershell
   .\Project.MM\setup\install_dependencies.ps1
   ```
2. **Build the Firmware**:
   ```powershell
   .\Project.MM\setup\build_firmware.ps1
   ```
3. **Claim Free Wokwi License**:
   In VS Code: Press `F1` $\rightarrow$ `Wokwi: Request a New License` $\rightarrow$ authorize in browser.

*(For detailed manual installation instructions, refer to the [`Project.MM/setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/setup/SETUP_GUIDE.md)).*

---

## 5. Simulated Hardware & Web Endpoints

### SPI Hardware Pin Mapping:
- **`esp:D5`** $\rightarrow$ `sd1:CS` (Chip Select)
- **`esp:D23`** $\rightarrow$ `sd1:DI` (MOSI)
- **`esp:D19`** $\rightarrow$ `sd1:DO` (MISO)
- **`esp:D18`** $\rightarrow$ `sd1:SCK` (Serial Clock)
- **`esp:3V3`** $\rightarrow$ `sd1:VCC`, **`esp:GND.1`** $\rightarrow$ `sd1:GND`

### Firmware Architecture (`Project.MM/ESP32_NAS_Server/src/main.cpp`):
- **Phase 1**: Hardware VSPI mounting, automatic seeding of `/www/index.html` and `/lab_report.txt`, and file enumeration.
- **Phase 2**: Asynchronous WebServer handling root dashboard (`/`), static hosting (`/site`), streaming downloads (`/get`), and background auto-diagnostics running on FreeRTOS Core 1.

---

## 6. Documentation References

- **Setup & Dependencies**: [`Project.MM/setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/setup/SETUP_GUIDE.md)
- **ESP32 Project Workspace Guide**: [`Project.MM/ESP32_NAS_Server/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/ESP32_NAS_Server/README.md)
- **Theory & Archiving Notes**: [`doc/prompts/12.Wokwi VS Code Extension and ESP32 NAS Setup.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/prompts/12.Wokwi%20VS%20Code%20Extension%20and%20ESP32%20NAS%20Setup.md)

