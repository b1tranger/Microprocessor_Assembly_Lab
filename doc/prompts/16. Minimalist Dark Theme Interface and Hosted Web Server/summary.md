# 16. Minimalist Dark Theme Interface and Hosted Web Server

- **Conversation ID**: `12d2caa0-dc44-4a5d-a2b7-a78b5731a28e`
- **Timestamp**: `2026-11-13T22:07:57+06:00`
- **Model**: `Gemini 3.8 Flash`
- **Target File**: [`index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html)

---

## Table of Contents
- [1. User Request Summary](#1-user-request-summary)
- [2. Code & Files Inspected / Modified](#2-code--files-inspected--modified)
- [3. Analysis & Key Insights](#3-analysis--key-insights)
  - [3.1 Minimalist Dark Theme & Zero Curved Corners (`border-radius: 0`)](#31-minimalist-dark-theme--zero-curved-corners-border-radius-0)
  - [3.2 Removal of the "Active" Status Badge](#32-removal-of-the-active-status-badge)
  - [3.3 File Server HTML Placement & Static Asset Pipeline](#33-file-server-html-placement--static-asset-pipeline)
  - [3.4 ESP32 C++ Core Firmware & PROGMEM Streaming Alignment](#34-esp32-c-core-firmware--progmem-streaming-alignment)
  - [3.5 Relative Navigation & Route Resolution](#35-relative-navigation--route-resolution)
  - [3.6 Wokwi Virtual SD Card 256 MB Capacity Limit](#36-wokwi-virtual-sd-card-256-mb-capacity-limit)
  - [3.7 Direct SD File Server Streaming & REST API (`/api/files`)](#37-direct-sd-file-server-streaming--rest-api-apifiles)
  - [3.8 Wokwi Binary Compilation & `data/network` Virtual SD Mirroring](#38-wokwi-binary-compilation--datanetwork-virtual-sd-mirroring)
  - [3.9 Toolchain Cache vs. Local Firmware Build Output](#39-toolchain-cache-vs-local-firmware-build-output)
  - [3.10 Blank Page Root Cause: 0-Byte SD Streaming & Wokwi In-Memory Writeback](#310-blank-page-root-cause-0-byte-sd-streaming--wokwi-in-memory-writeback)
  - [3.11 Mobile Responsive Layout & Icon-Only Action Buttons](#311-mobile-responsive-layout--icon-only-action-buttons)
  - [3.12 10-Second Auto-Sync Timer with Active Upload Protection](#312-10-second-auto-sync-timer-with-active-upload-protection)
  - [3.13 Lifecycle & Persistence of `data/network` Folders](#313-lifecycle--persistence-of-datanetwork-folders)
  - [3.14 0-Byte Uploads & Aborted Multipart Stream Handling](#314-0-byte-uploads--aborted-multipart-stream-handling)
  - [3.15 Browser Loopback Transfer vs. Virtual SPI Storage Writing Lag](#315-browser-loopback-transfer-vs-virtual-spi-storage-writing-lag)
  - [3.16 Network Self-Diagnostics Resource Contention & Stream Draining Fix](#316-network-self-diagnostics-resource-contention--stream-draining-fix)
  - [3.17 Upload Partial Write Terminal Loop & 4KB Sector-Aligned SD Buffer](#317-upload-partial-write-terminal-loop--4kb-sector-aligned-sd-buffer)
  - [3.18 Local Firmware Build Refresh Automation Scripts](#318-local-firmware-build-refresh-automation-scripts)
  - [3.19 Comprehensive Presentation Guide Synchronization](#319-comprehensive-presentation-guide-synchronization)
- [4. Final Solution & Deliverables](#4-final-solution--deliverables)

---

## 1. User Request Summary
The user requested a complete visual design overhaul for both the ESP32 NAS file server dashboard and the hosted static website:
1. **Minimalistic Dark Theme**: High-contrast, clean matte dark aesthetics with professional engineering typography.
2. **Without Curved-Corner Borders**: Absolute elimination of rounded/curved corners across all UI components (`border-radius: 0;`).
3. **Without the "Active" Label**: Removal of the "Active" / "Online" status pill in the navigation header.
4. **File Server HTML Placement**: Creation of a dedicated file server HTML file placed directly alongside [`data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html).

---

## 2. Code & Files Inspected / Modified
1. [`Project.MM/LocalConfig/data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html):
   - Redesigned with sharp 90-degree geometry (`border-radius: 0 !important;`).
   - Replaced radial multi-gradient background with deep matte `#0c0d11` and `#13151b` card surfaces.
   - Clean industrial spec item boxes with monospace headers and electric cyan interactive action buttons.
2. [`Project.MM/LocalConfig/data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html) *(New)*:
   - Standalone, fully functional file server interface HTML placed inside `data/www/`.
   - Contains storage utilization card, real-time file upload module with speed calculation and ETA, and the complete file directory table.
3. [`Project.MM/LocalConfig/data/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/fileserver.html) *(Removed)*:
   - Deleted redundant duplicate file to maintain a clean directory structure. The single source of truth is maintained in `data/www/fileserver.html`.
4. [`Project.MM/LocalConfig/include/html_templates.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/html_templates.h):
   - Overhauled `NAS_PAGE_HEADER` and `NAS_PAGE_FOOTER` PROGMEM templates to match the new minimalist dark theme.
   - Removed `.badge-online` status badge.
   - Enforced `* { border-radius: 0 !important; }` across all UI elements.
5. [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp):
   - Replaced procedural C++ HTML chunk streaming in `handleRoot` with direct SD streaming of `/www/fileserver.html` via `server.streamFile()`.
   - Added REST JSON endpoint `handleApiFiles()` at `/api/files` returning live storage statistics and file directory data.
   - Added direct route handlers for `/fileserver.html`, `/www/fileserver.html`, `/index.html`, `/www/index.html`, and `/api/files`.
6. [`Project.MM/LocalConfig/scripts/generate_assets.py`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/scripts/generate_assets.py):
   - Corrected duplicated variable dictionary syntax error.
7. [`Project.MM/LocalConfig/include/default_assets.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/default_assets.h):
   - Regenerated via [`generate_assets.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/scripts/generate_assets.ps1) to embed `/www/fileserver.html`, `/www/index.html`, and `/default/lab_report.txt` into Flash ROM.
8. [`Project.MM/LocalConfig/wokwi.toml`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/wokwi.toml):
   - Corrected virtual SD card capacity from `size = "1G"` to `size = "256M"` to adhere to Wokwi's simulator maximum ceiling.
9. [`Project.MM/LocalConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md) & [`Project.MM/LocalConfig/runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md):
   - Synchronized technical specs and documentation to reflect the 256 MB maximum capacity.

---

## 3. Analysis & Key Insights

### 3.1 Minimalist Dark Theme & Zero Curved Corners (`border-radius: 0`)
- **Visual Ergonomics**: Replaced intense multi-colored gradients and heavy blur backdrop filters with a solid, high-precision dark palette (`#0c0d11` body background, `#13151b` card backgrounds, `#181b22` input/table surfaces, `#272b35` borders).
- **Geometric Rigor**: Curved borders introduce unnecessary visual noise in high-density engineering dashboards. Setting `border-radius: 0 !important;` globally across cards, input elements, buttons (`.btn`, `.btn-upload`, `.btn-action`), badges, and progress bar containers enforces a crisp, modern architectural aesthetic.

### 3.2 Removal of the "Active" Status Badge
- Previously, the dashboard header featured an animated blinking dot and text badge:
  ```html
  <span class="badge-online"><span class="badge-dot"></span> Online</span>
  ```
- Removing this element reduces header clutter and aligns the interface with modern minimalist design patterns. The right side of the header now cleanly hosts only the navigation action button (`[ 🌐 Static Site ]`).

### 3.3 File Server HTML Placement & Static Asset Pipeline
- The file server interface was originally rendered purely via C++ PROGMEM strings in `include/html_templates.h`.
- By creating [`data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html), developers can now directly view, edit, and preview the file server interface outside the microcontroller simulation.
- Running [`generate_assets.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/scripts/generate_assets.ps1) automatically converts all files in `data/www/` into byte arrays in `include/default_assets.h`, ensuring the virtual FAT32 MicroSD card mounts with both `fileserver.html` and `index.html` write-protected under `/www/`.

### 3.4 ESP32 C++ Core Firmware & PROGMEM Streaming Alignment
- The native ESP32 WebServer core streams dashboard pages in chunks via `server.sendContent(FPSTR(NAS_PAGE_HEADER))` to maintain a fixed ~2 KB RAM overhead.
- Keeping `include/html_templates.h` and [`data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html) synchronized ensures that both the embedded live server and the local static HTML file produce identical visual experiences.

### 3.6 Wokwi Virtual SD Card 256 MB Capacity Limit
- When loading `diagram.json`, the Wokwi VS Code extension validates `wokwi.toml` against its virtual disk creation schema.
- Specifying `size = "1G"` failed with `'size' must be at most 256 MB` because Wokwi's in-memory/simulated FAT formatting engine imposes a strict 256 MB maximum threshold.
- Adjusting to `size = "256M"` resolves the simulator configuration error while maintaining maximum allowable storage for files uploaded to `data/network/`.

### 3.8 Wokwi Binary Compilation & `data/network` Virtual SD Mirroring
- When starting the simulation in VS Code via `diagram.json`, Wokwi loads the pre-compiled binary located at `.pio/build/esp32dev/firmware.bin` as specified in `wokwi.toml`.
- Because this binary was originally built on October 25, 2026, subsequent source edits in `src/main.cpp` and `html_templates.h` were not reflected during execution until a fresh build was executed.
- Furthermore, Wokwi maps the virtual MicroSD card directly to `data/network`. When `data/network/www/index.html` was 0 bytes and `fileserver.html` was absent, the simulator mounted an unpopulated web directory.
- Recompiling `firmware.bin` via PlatformIO and synchronizing `data/network/www/` with full copies of `fileserver.html` and `index.html` (along with self-healing 0-byte checks in firmware startup) completely restored expected live simulator behavior.

### 3.9 Toolchain Cache vs. Local Firmware Build Output
- Clarified that [`platformio_cache.zip`](https://github.com/b1tranger/wokwi_env_setup_script/releases/tag/platformio_cache.zip) contains compiler toolchains (`toolchain-xtensa-esp-elf`, `framework-arduinoespressif32`) for offline setup on fresh lab PCs.
- It does not contain compiled firmware binaries (`firmware.bin`), which are build outputs generated locally when running `setup/build_firmware.bat` or `pio run`.
- Therefore, changes to project firmware logic or HTML templates do not require updating the release archive `platformio_cache.zip`.

### 3.10 Blank Page Root Cause: 0-Byte SD Streaming & Wokwi In-Memory Writeback
- **Mechanism of Failure**:
  - In [`wokwi.toml`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/wokwi.toml), Wokwi maps the virtual MicroSD card to `data/network` with `writeback = true`.
  - When the user navigated to `http://localhost:9080/`, `handleRoot()` streamed `/www/fileserver.html` directly from SD.
  - Because `data/network/www/fileserver.html` had been truncated to 0 bytes on the host disk, `server.streamFile(htmlFile, "text/html")` streamed 0 bytes with HTTP 200 OK (`Content-Length: 0`), resulting in a completely blank white screen in the browser.
  - When files were copied into `data/network/` while Wokwi was actively running in VS Code, Wokwi's virtual SD background worker flushed its stale in-memory 0-byte FAT sectors back onto disk.
- **Architectural Mitigation & Self-Healing Routes**:
  - `handleRoot()` and `handleSite()` in [`src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp) now explicitly check `htmlFile && htmlFile.size() > 0`.
  - If a file is missing or 0 bytes, the firmware automatically deletes the corrupt entry via `SD.remove()` and re-seeds it cleanly from `EMBEDDED_ASSETS`.
  - If SD hardware write fails entirely, the routes fall back to streaming directly from Flash ROM via `server.send_P(200, "text/html", ...)`.
  - Fresh firmware was recompiled to [`.pio/build/esp32dev/firmware.bin`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/.pio/build/esp32dev/firmware.bin) (1,291,184 bytes).

### 3.11 Mobile Responsive Layout & Icon-Only Action Buttons
- **Media Query Adaptation (`@media (max-width: 640px)`)**:
  - The navigation header switches from horizontal split to vertical stack with full-width responsive action pills.
  - File upload inputs stack vertically, formatting the file selector button and upload trigger into comfortable full-width mobile touch targets.
  - Table cell padding reduces to `10px 8px`, with `word-break: break-word` on filenames to eliminate accidental horizontal page scrolling.
- **Icon-Only Buttons for Small Screens**:
  - Desktop view displays full text labels: `⬇ Download`, `🗑 Delete`, `🔒 Protected`.
  - Mobile view (`max-width: 640px`) hides `.btn-text` (`display: none;`) while leaving `.btn-icon` visible:
    - Download button: `⬇` (with full `title` and `aria-label`).
    - Delete button: `🗑` (with full `title` and `aria-label`).
    - Protected badge: `🔒` (with full `title` and `aria-label`).
  - This shrinks action cell horizontal footprint from ~180px down to ~55px.

### 3.12 10-Second Auto-Sync Timer with Active Upload Protection
- **Client-Side Live Polling**:
  - Integrated `tickAutoSync()` running on a 1-second interval, triggering dynamic data refresh via `loadFiles()` every 10 seconds.
  - Eliminates the need for manual browser reloads after uploading or modifying files.
  - Includes a visual header badge: `⟳ Auto-sync: <N>s` with manual click-to-sync capability.
  - **Upload Lock**: During active file uploads (`isUploading = true`), countdown pauses (`--`) to avoid interrupting long multipart transmissions.

### 3.13 Lifecycle & Persistence of `data/network` Folders
- Folders (`/default`, `/www`, `/uploads`) are **not** wiped or recreated on every run.
- Wokwi maps the virtual MicroSD card directly to `data/network/` with `writeback = true`.
- During ESP32 boot, `phase1_seedInitialFiles()` checks `if (!SD.exists("/dir")) SD.mkdir("/dir")`. If the folders already exist on disk, creation is skipped, and all contained files remain intact.
- Wokwi writes sector modifications back to `data/network/`, persisting uploads across simulation restarts.

### 3.14 0-Byte Uploads & Aborted Multipart Stream Handling
- **Root Cause**:
  - In `handleFileUpload()`, on `UPLOAD_FILE_START`, the server opened the target file path via `SD.open(targetPath, FILE_WRITE)`. This created a directory entry on FAT32.
  - If a simulated network timeout, packet stall, or client abort occurred before the boundary finished, ESP32's `WebServer/src/Parsing.cpp` invoked `upload.status = UPLOAD_FILE_ABORTED`.
  - The previous handler only called `uploadFile.close()` without purging the file. This left an incomplete 0-byte file in `/uploads/` that was listed by `/api/files` and opened as corrupt by viewers.
  - Subsequent upload attempts failed to overwrite the stale cluster allocation properly.
- **Architectural Solution**:
  - Direct streaming I/O via `uploadFile.write(upload.buf, upload.currentSize)` bypassing manual double-buffering.
  - Added pre-upload sanitization: `if (SD.exists(currentUploadTarget)) SD.remove(currentUploadTarget);`.
  - Added abort auto-purge: on `UPLOAD_FILE_ABORTED`, `uploadFile.close()` is immediately followed by `SD.remove(currentUploadTarget)` to prevent incomplete 0-byte files from ever remaining on storage.
  - Enforced strict HTTP status validation on `/upload`: returns HTTP 500 JSON error if the file was aborted or wrote 0 bytes.

### 3.15 Browser Loopback Transfer vs. Virtual SPI Storage Writing Lag
- **Why Upload Reaches 100% Immediately**:
  - When accessing `http://localhost:9080/`, traffic traverses the host loopback interface. The browser dumps the entire file payload into the local socket buffer in a few milliseconds, advancing `xhr.upload.onprogress` to 100%.
- **Why There Is a Subsequent Delay**:
  - The ESP32 in Wokwi is a cycle-accurate virtual simulation running Xtensa dual cores at ~20-50% real-time speed.
  - The firmware must consume packets through lwIP, parse multipart MIME boundaries, and bit-bang/SPI write each 512-byte block across GPIO 18/23/19 to FAT32.
  - Writing megabytes of data to virtual SD takes several seconds of CPU time. The browser waits for the HTTP 200 response during this interval.
  - Enhanced UI in `data/www/fileserver.html` to display a dedicated transition state at 100% (`Writing to Storage: <filename>`, `⚡ Committing...`, `⏱ Finalizing SD card write`) so users understand the server is committing data to storage.

### 3.16 Network Self-Diagnostics Resource Contention & Stream Draining Fix
- **Diagnostic Output Trace**:
  - Test 1 (`/`): Response `200`
  - Test 2 (`/site`): Response `-11` (`HTTPC_ERROR_READ_TIMEOUT`)
  - Test 3 (`/get?file=lab_report.txt`): Response `-11` (`HTTPC_ERROR_READ_TIMEOUT`)
  - Test 4 (`/delete`): Response `-1` (`HTTPC_ERROR_CONNECTION_REFUSED`)
  - Test 5 (`/api/files`): Response `-1` (`HTTPC_ERROR_CONNECTION_REFUSED`)
- **Mechanism of Failure**:
  - Both `loopTask` (`server.handleClient()`) and `runClientTests` are pinned to Core 1 at priority 1.
  - In Test 1, `http.GET()` received `200 OK` from headers and called `http.end()` immediately without draining the 23 KB response body.
  - Closing a TCP socket with unread data in the receive buffer causes lwIP to issue a TCP RST (Reset).
  - The server's `server.streamFile()` was interrupted mid-stream on Core 1. Because there was 0 ms delay between tests, Test 2 fired while the server was still in error recovery, leading to successive 5-second timeouts (`-11`) and socket pool exhaustion (`-1`).
  - Serial monitor formatting had a staircase artifact because prints used `\n` without `\r`.
- **Architectural Solution**:
  - Created `performTestRequest(url)` helper setting `http.setReuse(false)` and fully draining the response stream via `stream->read()`.
  - Added cooperative FreeRTOS yield `vTaskDelay(800 / portTICK_PERIOD_MS)` between tests to give `loopTask` dedicated Core 1 execution time to complete TCP teardowns.
  - Formatted all diagnostic outputs with `\r\n`.
  - Recompiled firmware binary to 1,298,256 bytes.

### 3.17 Upload Partial Write Terminal Loop & 4KB Sector-Aligned SD Buffer
- **Terminal Trace**:
  - `[UPLOAD WARN] Partial write: 0 / 1436 bytes` repeating indefinitely on every incoming TCP packet.
- **Root Cause**:
  - VSPI clock was configured to 25 MHz (`25000000`). In Wokwi simulation, the virtual SD card component cannot reliably latch bulk sector writes at 25 MHz, causing block write timeouts or CRC errors (`FR_DISK_ERR` / `EIO`).
  - In standard C library file streaming, once `fwrite()` encounters a stream I/O error, the stream error flag is set (`ferror(_f) != 0`). Every subsequent call to `fwrite()` immediately fails and returns 0 without attempting I/O.
  - Writing raw 1,436-byte network chunks unbuffered forced partial-sector read-modify-write operations across 512-byte FAT32 boundaries.
  - Filenames containing apostrophes (`'`) like `The Regressed Mercenary's Machinations` posed directory entry formatting collisions.
  - Bare `\n` in `Serial.printf` caused staircase indentation in serial consoles.
- **Architectural Solution**:
  - Reverted `SD.begin()` from 25 MHz to standard reliable 4 MHz (`4000000`).
  - Implemented 4,096-byte sector-aligned buffer (`uploadWriteBuffer[4096]`), accumulating 1,436-byte network chunks and flushing exclusively in 8-sector (4 KB) aligned blocks.
  - Added `uploadWriteError` circuit breaker: halts further disk writes immediately on the first error, logs once, and safely purges the incomplete file, eliminating terminal spam.
  - Added filename sanitization to replace apostrophes and illegal characters with underscores.
  - Replaced all upload debug prints with `\r\n`.
  - Recompiled firmware binary to 1,299,200 bytes.

### 3.18 Local Firmware Build Refresh Automation Scripts
- **Need for Standalone Refresh Tooling**:
  - Developers editing HTML/CSS assets in `data/www/` or modifying C++ firmware in `src/main.cpp` required a quick, one-click mechanism inside `Project.MM/LocalConfig` to rebuild the binary and sync all files without needing to navigate into `setup/` subfolders.
- **Implementation**:
  - [`refresh_firmware.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/refresh_firmware.ps1): Automates the 3-stage pipeline:
    1. Runs `scripts/generate_assets.ps1` to sync `data/` assets into Flash ROM (`include/default_assets.h`).
    2. Mirrors `data/www/` to `data/network/www/` for Wokwi virtual SD writeback.
    3. Runs PlatformIO incremental compilation (`pio run` or `python -m platformio run`).
  - [`refresh_firmware.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/refresh_firmware.bat) & [`build_firmware.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/build_firmware.bat): Windows batch wrappers that bypass PowerShell execution policies and pause on completion for terminal review.

### 3.19 Comprehensive Presentation Guide Synchronization
- **Scope & Objectives**:
  - Fully updated [`Project.MM/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/PRESENTATION_GUIDE.md) to reflect all new engineering developments in `Project.MM/LocalConfig`.
- **Key Revisions Made**:
  - **Specs & Architecture**: Updated SD card size limit to 256 MB, hardware VSPI bus to 4 MHz, added `/api/files` REST telemetry, and updated directory tree with `refresh_firmware.bat`, `refresh_firmware.ps1`, `build_firmware.bat`, `data/network/`, and `include/default_assets.h`.
  - **Toolchain & Build Flow**: Added Section 4.4 detailing the one-click build refresh automation script and updated the Mermaid compilation diagram to include the asset serialization stage.
  - **Firmware Subsystems**: Documented Flash ROM reseeding/fallback, 4 KB sector-aligned multipart upload buffering, punctuation sanitization, instant error circuit breaking, and stream-drained diagnostic test socket hygiene.
  - **UI & Aesthetics**: Integrated the Minimalist Dark theme design rationale, 10-second non-flicker auto-sync, 100% storage commit transition state, and mobile icon-only action buttons (`⬇`, `🗑`, `🔒`).
  - **Demonstration Walkthrough**: Updated Steps 3, 4, 7, and added Step 9 (Mobile Responsive Viewport Inspection).
  - **Evaluator Defense**: Added Q12 through Q16 addressing geometric design, upload commit delay, abort purging, 4 MHz SPI clock stability, and decoupled asset generation.

---

## 4. Final Solution & Deliverables
- **Hosted Website**: [`Project.MM/LocalConfig/data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html) updated to minimalist dark theme with sharp borders and relative link `href="fileserver.html"`.
- **Mobile Responsive File Server HTML**: [`Project.MM/LocalConfig/data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html) (23,138 bytes) featuring icon-only action buttons for mobile (`<= 640px`), full-width touch form controls, 10-second auto-sync countdown with upload locking, and commit status transitions at 100%.
- **Synchronized C++ Templates**: [`Project.MM/LocalConfig/include/html_templates.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/html_templates.h) aligned with identical media queries and icon-only button styling.
- **SD Card Synchronization**: [`Project.MM/LocalConfig/data/network/www/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/network/www/) synchronized with `fileserver.html` and `index.html`.
- **Hardened Firmware with Sector-Aligned Upload Buffering**: [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp) with 4 KB sector buffering, 4 MHz VSPI reliability, instant upload error circuit breaker, filename sanitization, automatic abort cleanup, stream draining, cooperative yield delays, 0-byte size guards, auto-reseeding, and Flash ROM fallback.
- **One-Click Build Refresh Scripts**: [`refresh_firmware.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/refresh_firmware.bat), [`refresh_firmware.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/refresh_firmware.ps1), and [`build_firmware.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/build_firmware.bat) in `Project.MM/LocalConfig/`.
- **Definitive Presentation Guide**: [`Project.MM/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/PRESENTATION_GUIDE.md) comprehensively synchronized with all architecture, UI, hardware, Q&A, and demonstration updates.
- **Compiled Firmware Binary**: Fresh PlatformIO firmware binary [`.pio/build/esp32dev/firmware.bin`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/.pio/build/esp32dev/firmware.bin) (1,299,200 bytes).
- **Archived Trajectory**: Fully documented in `doc/prompts/16. Minimalist Dark Theme Interface and Hosted Web Server/`.

