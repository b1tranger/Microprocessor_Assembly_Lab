# 15. VS Code Simulation and File Server Access Guide

- **Conversation ID**: `fe594199-b957-4660-b83f-1b9ab3f73a1a`
- **Timestamp**: `2026-11-13T16:53:11+06:00`
- **Model**: `Gemini 3.8 Flash`
- **Target File**: [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md)

---

## Table of Contents
- [1. User Request Summary](#1-user-request-summary)
- [2. Code & Files Inspected / Modified](#2-code--files-inspected--modified)
- [3. Analysis & Architectural Insights](#3-analysis--architectural-insights)
  - [3.1 Hardware VSPI & Streaming Constraints](#31-hardware-vspi--streaming-constraints)
  - [3.2 Multi-Interface Socket Routing (0.0.0.0:9080)](#32-multi-interface-socket-routing-00009080)
  - [3.3 Windows Firewall & Virtual Subnet Gateway Bridging](#33-windows-firewall--virtual-subnet-gateway-bridging)
  - [3.4 Dedicated Folder Organization & Write-Protected Storage Engine](#34-dedicated-folder-organization--write-protected-storage-engine)
- [4. Final Solution & Deliverables](#4-final-solution--deliverables)

---

## 1. User Request Summary
- **Turn 1**: The user requested the creation of a single comprehensive operational run guide, [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md), inside [`Project.MM/LocalConfig/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig), documenting the steps to compile/simulate the ESP32 NAS server in VS Code and access it from another device across local Wi-Fi and Ethernet.
- **Turn 2**: The user clarified their real-world deployment contexts (Home testing: Host on Ethernet, client on Wi-Fi; Lab evaluation: Both on campus Ethernet; Portable showcase: Host laptop on Mobile Hotspot).
- **Turn 3**: The user requested relocating `Project.MM/setup/` to `Project.MM/LocalConfig/setup/`, updating `runGuide.md` with the full setup sequence, and removing redundant execution sections from `Project.MM/LocalConfig/README.md`.
- **Turn 4**: The user requested updating all file path references inside [`Project.MM/LocalConfig/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig) to be relative to the source markdown files rather than absolute GitHub web URLs.
- **Turn 5**: The user requested:
  1. Updating `.gitignore` for `Project.MM/LocalConfig/setup/` to keep scripts tracked while excluding heavy localized toolchains.
  2. Creating an automated uninstaller script (`uninstall_dependencies.bat` and `uninstall_dependencies.ps1`) in `Project.MM/LocalConfig/setup/` that reverts all setup changes (terminates gateway processes, removes the Windows Firewall rule, cleans `PLATFORMIO_CORE_DIR`, and purges build artifacts).
  3. Packaging the ~600MB localized dependencies into `Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/platformio_cache.zip` and gitignoring it so the user can upload it to GitHub Releases, enabling offline users to download it separately and complete setup via automated scripts.
- **Turn 6**: The user requested:
  1. Separating the default file (`lab_report.txt`) and static website interface (`index.html`) from hardcoded strings in `src/main.cpp` into dedicated folders on disk (`data/default/` and `data/www/`).
  2. Enabling adding or removing files simply by placing or removing them from those dedicated folders.
  3. Enforcing write protection so default system files like `lab_report.txt` cannot be deleted from the file server web interface by users.
- **Turn 7**: The user requested removing redundant extracted files (`.platformio/`) from [`Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer) after having created `platformio_cache.zip`. This reclaimed ~4.1 GB of redundant local storage while keeping the compressed archive for GitHub Releases.
- **Turn 8**: The user asked whether files in `setup/` depend on `PlatformIO_Espressif_Offline_Installer/` (clarified as an optional offline fallback/accelerator), and requested staging a self-contained new folder at the project root (`wokwi-offline-environment/`) with all necessary files to publish as a standalone GitHub repository for offline Wokwi setup, along with gitignoring the new staging folder from the parent repository.
- **Turn 9**: The user published the new repository and uploaded the offline cache to **[Release platformio_cache.zip (b1tranger/wokwi_env_setup_script)](https://github.com/b1tranger/wokwi_env_setup_script/releases/tag/platformio_cache.zip)**. The user requested updating all documentation and scripts to link to this GitHub Release, and removing the heavy localized dependencies (`platformio_cache.zip`) and the temporary staging folder (`wokwi-offline-environment/`) to free up disk space.
- **Turn 10**: The user reported that `setup_firewall.bat` closed immediately after execution without letting users verify the success status. Diagnosed the root cause: legacy `cacls.exe` failed with errorlevel 5 on modern Windows 10/11 even within elevated sessions, causing the elevated process to re-enter `:UACPrompt` and immediately exit (`exit /B`). Fixed both copies (`LocalConfig/setup_firewall.bat` and `LocalConfig/setup/setup_firewall.bat`) with modern `net session` privilege detection and PowerShell UAC elevation, and added native `setup_firewall.ps1`.
- **Turn 11**: The user reported that file storage was capped at 8 MB and asked whether physical host storage (HDD/SSD) could be mapped to `data/network` to eliminate storage concerns, and asked to boost transfer speeds and add upload progress and transfer speed indicators to the web interface. Configured `wokwi.toml` with `[[sdcard]] folder = "data/network"`, `size = "1G"`, and `writeback = true`. Boosted SPI clock to 25 MHz and added 4KB sector-aligned write buffering (`uploadWriteBuffer`) in `main.cpp`. Created a real-time progress card with live speed meter, progress bar, byte counts, and dynamic ETA in `html_templates.h` and `main.cpp`.
- **Turn 12**: The user asked why the URLs use `http` instead of `https`. Documented the architectural reasons why local IoT/microcontroller nodes and standard LAN services operate on unencrypted HTTP (lack of trusted public CA on RFC-1918 local IPs, extreme RAM/crypto handshake overhead on microcontrollers), why modern browsers trigger `ERR_SSL_PROTOCOL_ERROR` when auto-upgrading to HTTPS, and how to configure client browsers. Added Section 6.5 to [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md).

---

## 2. Code & Files Inspected / Modified

### Files Inspected:
* [`Project.MM/LocalConfig/platformio.ini`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/platformio.ini): Build flags, board definition (`esp32dev`), and framework (`arduino`).
* [`Project.MM/LocalConfig/wokwi.toml`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/wokwi.toml): Simulator firmware targets and `[net]` gateway websocket configuration (`ws://localhost:9011`).
* [`Project.MM/LocalConfig/diagram.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/diagram.json): Physical schematics, part identifiers, and hardware VSPI pin mappings.
* [`Project.MM/LocalConfig/setup_firewall.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup_firewall.bat): UAC-elevated PowerShell firewall rule generator for TCP port 9080.
* [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp): C++ firmware containing storage mounting, streaming upload/download handlers, and diagnostic tasks.
* [`Project.MM/LocalConfig/include/html_templates.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/html_templates.h): Glassmorphic UI templates stored in Flash ROM via `PROGMEM`.

### Files Modified & Reorganized:
* **Moved Directory**: `Project.MM/setup/` $\rightarrow$ [`Project.MM/LocalConfig/setup/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup).
* [`Project.MM/LocalConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md): Stripped duplicate execution and networking sections; added prominent redirect link to `runGuide.md`; added documentation for `data/` and `scripts/generate_assets.*`.
* [`Project.MM/LocalConfig/runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md): Updated step-by-step process with **Step 0: Automated Environment & Dependency Setup (`setup/`)**, **Step 1: Firmware Compilation**, and **Section 5.3: Dedicated Folders & Write-Protected System Files**.
* [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp): Updated to dynamically seed embedded assets from `include/default_assets.h`, route client uploads into `/uploads/`, reject deletion attempts on protected files with `HTTP 403 Forbidden`, and display file locations with `🔒 Protected` badges in the dashboard.
* [`Project.MM/LocalConfig/include/html_templates.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/html_templates.h): Removed hardcoded `SEED_INDEX_HTML` string; added CSS styles for `.badge-protected` and `.tag-folder`.
* [`Project.MM/LocalConfig/platformio.ini`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/platformio.ini): Added `extra_scripts = pre:scripts/generate_assets.py` to trigger asset compilation automatically.
* [`Project.MM/LocalConfig/setup/build_firmware.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/build_firmware.ps1): Added Step 0 asset synchronization step calling `scripts/generate_assets.ps1` before compiling.
* [`Project.MM/LocalConfig/setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/SETUP_GUIDE.md): Documented asset synchronization and write protection during build.
* [`.gitignore`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/.gitignore): Updated to properly ignore `Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/*.zip`, `.platformio/`, `wheels/`, and local `.pio/` while keeping installer automation scripts tracked.

### Files Created:
* [`Project.MM/LocalConfig/data/default/lab_report.txt`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/default/lab_report.txt): Dedicated standalone text document for the default laboratory report.
* [`Project.MM/LocalConfig/data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html): Dedicated standalone modern HTML/CSS landing page for the static web server.
* [`Project.MM/LocalConfig/scripts/generate_assets.py`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/scripts/generate_assets.py): Python pre-build script for PlatformIO.
* [`Project.MM/LocalConfig/scripts/generate_assets.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/scripts/generate_assets.ps1): PowerShell script for Windows asset compilation.
* [`Project.MM/LocalConfig/scripts/generate_assets.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/scripts/generate_assets.bat): One-click CMD launcher for asset compilation.
* [`Project.MM/LocalConfig/include/default_assets.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/default_assets.h): Auto-generated C++ header embedding all files in `data/` as PROGMEM arrays with an asset registry table.
* [`Project.MM/LocalConfig/setup/uninstall_dependencies.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/uninstall_dependencies.bat) & [`uninstall_dependencies.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/uninstall_dependencies.ps1): Automated uninstaller scripts.
* `Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/platformio_cache.zip`: ~600MB packaged offline dependencies bundle for GitHub Releases.
* [`doc/prompts/15. VS Code Simulation and File Server Access Guide/transcript_full.jsonl`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/prompts/15.%20VS%20Code%20Simulation%20and%20File%20Server%20Access%20Guide/transcript_full.jsonl): Verbatim raw interaction log.
* [`doc/prompts/15. VS Code Simulation and File Server Access Guide/conversation.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/prompts/15.%20VS%20Code%20Simulation%20and%20File%20Server%20Access%20Guide/conversation.md): Step-by-step verbatim Markdown transcript of all actions, internal thinking, and tool executions.
* [`doc/prompts/15. VS Code Simulation and File Server Access Guide/summary.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/prompts/15.%20VS%20Code%20Simulation%20and%20File%20Server%20Access%20Guide/summary.md): This structured session summary.

---

## 3. Analysis & Architectural Insights

### 3.1 Hardware VSPI & Streaming Constraints
The simulated system models an ESP32 microcontroller with 520 KB on-chip SRAM communicating with a MicroSD card over the hardware VSPI bus (`SCK:18`, `MISO:19`, `MOSI:23`, `CS:5`). To prevent Out-Of-Memory (OOM) crashes during large file transfers between lab machines:
* Uploads are streamed incrementally chunk-by-chunk using `server.upload()`.
* Downloads use binary chunked streaming via `server.streamFile()`.
* Total SRAM usage remains constrained at **~2 KB** regardless of file size.

### 3.2 Multi-Interface Socket Routing (0.0.0.0:9080)
The local companion forwarder `wokwigw.exe` binds to `0.0.0.0:9080` (`INADDR_ANY`), which instructs the Windows TCP/IP stack to accept incoming packets across all local interfaces:
1. **Loopback Adapter (`127.0.0.1` / `localhost:9080`)**: For browser testing on the host PC.
2. **Windows Mobile Hotspot (`192.168.137.1:9080`)**: Provides a deterministic gateway IP that bypasses campus network isolation, allowing smartphones and tablets to connect over Wi-Fi directly to the host PC.
3. **Physical Ethernet LAN (`<LAN_IP>:9080`)**: Enables neighboring desktop PCs plugged into the same lab Ethernet switch to access the node directly.

### 3.3 Windows Firewall & Virtual Subnet Gateway Bridging
The Wokwi simulation runs the ESP32 on a private virtual subnet (`10.13.37.2`). `wokwigw.exe` communicates with Wokwi over `ws://localhost:9011` and forwards TCP port 9080 to `10.13.37.2:80`. Because Windows blocks incoming connections on non-standard ports by default, [`setup_firewall.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup_firewall.bat) configures an inbound firewall rule (`Wokwi Gateway NAS`) across Domain, Private, and Public profiles to guarantee reliable zero-timeout connectivity.

### 3.4 Dedicated Folder Organization & Write-Protected Storage Engine
Separating default assets from code addresses two critical embedded system challenges:
1. **Clean Decoupling**: Removing multi-kilobyte HTML and text string literals from `main.cpp` and `html_templates.h` prevents clutter and allows frontend assets to be edited directly as standalone `.html` or `.txt` files with standard syntax highlighting and linting.
2. **Automated Dynamic Asset Embedding**: The script `generate_assets.py` / `.ps1` scans `data/` and converts all files into flash ROM byte arrays inside `include/default_assets.h`. Any file placed in `data/default/` or `data/www/` is automatically seeded into the virtual FAT32 SD card upon ESP32 boot.
3. **Write Protection Enforcement**:
   - Files seeded from `data/default/` and `data/www/` (and root `/lab_report.txt`) are flagged with `isProtected = true`.
   - In the web UI, the Actions column replaces the `Delete` button with a `🔒 Protected` badge.
   - On the backend, `handleDelete()` validates target paths with `isProtectedPath()` and returns `HTTP 403 Forbidden` if a user attempts to manually trigger deletion via direct HTTP requests.
   - User uploads are neatly isolated into `/uploads/`, preserving default files from accidental modification or deletion.

---

## 4. Final Solution & Deliverables
The complete system delivers:
1. **Dedicated Host Folders**:
   - [`data/default/lab_report.txt`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/default/lab_report.txt): Standalone text document for the default laboratory report.
   - [`data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html): Standalone HTML landing page for the static web server.
2. **Automated Asset Generators**:
   - `scripts/generate_assets.bat`, `generate_assets.ps1`, and `generate_assets.py` to compile `data/` files into `include/default_assets.h`.
3. **Write-Protected Storage Engine**:
   - `src/main.cpp` seeds files into `/default/` and `/www/`, isolates uploads to `/uploads/`, rejects deletion of protected files with `HTTP 403 Forbidden`, and renders a `🔒 Protected` badge in the UI.
4. **Updated Documentation**:
   - [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md) Section 5.3 detailing the dedicated directory structure, dynamic boot seeding, and write protection.
   - [`README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md) and [`setup/SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/SETUP_GUIDE.md) updated with asset generation instructions.
5. **Reclaimed Storage & Cleanup**:
   - Safely purged the redundant uncompressed `.platformio/` folder (~4.1 GB) and the localized `platformio_cache.zip` archive (~670 MB) from `Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/` after publishing to GitHub Releases.
   - Removed the temporary staging directory `wokwi-offline-environment/` (~690 MB) once the user published the standalone repository.
   - Total disk space reclaimed: **~5.4 GB**.
6. **Integrated GitHub Release Links**:
   - Updated [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md), [`SETUP_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/SETUP_GUIDE.md), [`README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md), [`PlatformIO_Espressif_Offline_Installer/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/PlatformIO_Espressif_Offline_Installer/README.md), and [`install_dependencies.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup/install_dependencies.ps1) with direct links to the official release: [b1tranger/wokwi_env_setup_script Releases](https://github.com/b1tranger/wokwi_env_setup_script/releases/tag/platformio_cache.zip).
7. **Host SSD Storage Integration (`data/network`) & Performance Optimization**:
   - Enabled `[[sdcard]] folder = "data/network"`, `size = "1G"`, and `writeback = true` in `wokwi.toml`, lifting the 8MB cap to 1,024 MB and saving/deleting files directly on the host computer's SSD.
   - Boosted SPI clock from 4 MHz to 25 MHz and implemented 4KB sector-aligned write buffering (`uploadWriteBuffer`) in `main.cpp`.
   - Built a real-time upload progress card in `html_templates.h` and `main.cpp` displaying live progress bar (0-100%), instantaneous & smoothed transfer speed (`⚡ KB/s`), byte counts, and dynamic ETA calculation.
8. **HTTP vs HTTPS Troubleshooting & Architectural Documentation**:
   - Added Section 6.5 (*Browser Shows ERR_SSL_PROTOCOL_ERROR or Forces HTTPS*) to [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md) clarifying why local microcontroller nodes do not use TLS and providing explicit resolution steps for modern mobile and desktop browsers.
9. **Session Transcripts**: Fully synchronized in [`doc/prompts/15. VS Code Simulation and File Server Access Guide/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/doc/prompts/15.%20VS%20Code%20Simulation%20and%20File%20Server%20Access%20Guide).
