# Presentation Bridge v2: Rapid 3-Minute Deck & Live Demo Guide (Project.MM)

> **Course**: CSE0611324 — Microprocessors, Microcontrollers and Assembly Language Lab  
> **Course Lecturers**: Tahmina Yeasmin Lima Ma'am & Abrar Mahbub Tanim Sir  
> **Presentation Team**: Jannatul Ferdus, Gaus Saraf Murady, Sadia Islam  
> **Workspace**: [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig)  
> **Definitive Presentation Guide**: [`Project.MM/Presentation/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/PRESENTATION_GUIDE.md)  
> **Legacy 10-Minute Bridge (v1)**: [`Project.MM/Presentation/v1_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v1_presentationBridge.md)  
> **Slide Reference Deck**: [`temp/v2.2_ESP32 Embedded NAS & Static Web Node.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/temp/v2.2_ESP32%20Embedded%20NAS%20&%20Static%20Web%20Node.pdf)  
> **Time Budget**: **Under 3 Minutes Presentation** + **1–2 Minutes Live File Server Demo** + Faculty Q&A

---

## Table of Contents
- [1. Presentation Strategy & Strict Time Allocation](#1-presentation-strategy--strict-time-allocation)
  - [1.1 The Golden 3-Minute Rule](#11-the-golden-3-minute-rule)
  - [1.2 Role & Time Distribution Matrix](#12-role--time-distribution-matrix)
- [2. Slide Deck Audit: What to Remove, Shorten & Merge](#2-slide-deck-audit-what-to-remove-shorten--merge)
  - [2.1 Audit of the 10-Slide Deck (`v2.2` PDF)](#21-audit-of-the-10-slide-deck-v22-pdf)
  - [2.2 Recommended Streamlined 7-Slide Deck Structure](#22-recommended-streamlined-7-slide-deck-structure)
- [3. Suggested Slide Contents & Visual Blueprints](#3-suggested-slide-contents--visual-blueprints)
  - [Slide 1: Title, Team & The Power Comparison Hook](#slide-1-title-team--the-power-comparison-hook)
  - [Slide 2: Scope, Objectives & Simulator Choice](#slide-2-scope-objectives--simulator-choice)
  - [Slide 3: Hardware, Budget & Technical Feasibility (Merged)](#slide-3-hardware-budget--technical-feasibility-merged)
  - [Slide 4: Storage Pinout & Dual-Phase Architecture](#slide-4-storage-pinout--dual-phase-architecture)
  - [Slide 5: Simulation Setup & 4 Local Network Scenarios (New)](#slide-5-simulation-setup--4-local-network-scenarios-new)
  - [Slide 6: Real-World Impact, Debugging & Hardware Realities (Merged)](#slide-6-real-world-impact-debugging--hardware-realities-merged)
  - [Slide 7: Conclusion & Demo Transition](#slide-7-conclusion--demo-transition)
- [4. Rapid 3-Minute Spoken Script](#4-rapid-3-minute-spoken-script)
  - [Part 1: Hook, Scope & Hardware Feasibility (Speaker 1 — 0:00 to 0:50)](#part-1-hook-scope--hardware-feasibility-speaker-1--000-to-050)
  - [Part 2: Architecture, Setup & Network Scenarios (Speaker 2 — 0:50 to 1:50)](#part-2-architecture-setup--network-scenarios-speaker-2--050-to-150)
  - [Part 3: Impact, Solutions & Conclusion (Speaker 3 — 1:50 to 2:45)](#part-3-impact-solutions--conclusion-speaker-3--150-to-245)
- [5. Standalone Live File Server Demonstration Guide (1 to 2 Minutes)](#5-standalone-live-file-server-demonstration-guide-1-to-2-minutes)
  - [5.1 Live Demo Sequence](#51-live-demo-sequence)
  - [5.2 Demonstrator Narration Script](#52-demonstrator-narration-script)
- [6. High-Yield Evaluator Q&A Defense Quick-Reference](#6-high-yield-evaluator-qa-defense-quick-reference)

---

## 1. Presentation Strategy & Strict Time Allocation

### 1.1 The Golden 3-Minute Rule
In high-stakes academic evaluations with tight time limits, **over-explaining kills presentations**. Faculty evaluators already understand basic computer science terminology; they want to see:
1. **The engineering problem & the contrast**: Why build this on a microcontroller instead of a PC?
2. **The feasibility proof**: How does a chip with only 520 KB of RAM stream multi-megabyte files?
3. **The working proof**: How does your local simulation bridge to real networks and devices?
4. **The live demonstration**: Immediate, physical proof of operation before questions begin.

> [!IMPORTANT]
> **Cadence Target**: 120 words per minute.
> - **Total Presentation Word Budget**: **~340–370 words** across the entire 3-minute deck.
> - **Live Demo Window**: **60 to 90 seconds** focused strictly on the web UI and live file transfer.
> - **Rule of Conduct**: Never read bullet points off slides. Point to the diagram, state the key takeaway, and advance.

### 1.2 Role & Time Distribution Matrix

| Segment | Speaker | Scope & Content | Target Time | Word Budget |
| :--- | :--- | :--- | :--- | :--- |
| **Part 1** | **Speaker 1** (Jannatul Ferdus) | **The Hook, Problem Scope & Feasibility**<br>• 60W PC vs. <1W ESP32 Hook<br>• Objectives: Wireless NAS + Static Web Host<br>• Merged Budget (~750 BDT) & 2 KB RAM streaming guarantee | **0:00 – 0:50** (50s) | ~110 words |
| **Part 2** | **Speaker 2** (Gaus Saraf Murady) | **Architecture, Setup & 4 Network Scenarios**<br>• VSPI Pinout (GPIO 5, 18, 19, 23)<br>• Rapid Setup (Build $\rightarrow$ Firewall $\rightarrow$ Gateway $\rightarrow$ Wokwi)<br>• 4 Simulation Scenarios (Ethernet, Lab Switch, Hotspot, Wi-Fi) | **0:50 – 1:50** (60s) | ~130 words |
| **Part 3** | **Speaker 3** (Sadia Islam) | **Real-World Impact, Debugging & Wrap-Up**<br>• Bangladesh use cases (Floods, Agri-logging, Offline schools)<br>• Debugging wins (D5 silkscreen, SCK schema, Decoupling caps)<br>• Handoff to live demonstration | **1:50 – 2:45** (55s) | ~115 words |
| **Demo** | **Operator / Speaker 2** | **Live Interactive File Server Demonstration**<br>• Dashboard capacity & file table<br>• Real-time file upload & sector commit<br>• Static site rendering (`/site`)<br>• Download & storage reclaim | **2:45 – 4:00** (75s) | ~90 words |
| **Q&A** | **All Members** | **Faculty Oral Defense & Questions** | Buffer / As required | — |

---

## 2. Slide Deck Audit: What to Remove, Shorten & Merge

### 2.1 Audit of the 10-Slide Deck (`v2.2` PDF)

| Original Slide in `v2.2` PDF | Status & Evaluation | Recommendation for 3-Minute Delivery |
| :--- | :--- | :--- |
| **Slide 1: Title & Hook** | **KEEP & REFINE** | Excellent visual contrast (60W PC vs. 0.5W ESP32). Keep as Slide 1. |
| **Slide 2: Scope & Simulator Choice** | **SHORTEN** | Too much empty space; the simulator choice (Wokwi) can be a 1-sentence mention. |
| **Slide 3: Budget & Financial Feasibility** | **MERGE with Slide 4** | Sourcing components is simple; does not need its own full slide. |
| **Slide 4: Technical & Computational Feasibility** | **MERGE with Slide 3** | As noted by the user, having both Slide 3 and Slide 4 is redundant. Merge them into a single high-impact slide: **"Hardware, Budget & Technical Feasibility"**. |
| **Slide 5: Dual-Phase Implementation** | **STREAMLINE** | Keep the clean VSPI wiring diagram, but shorten text bullets to two concise phases. |
| **Slide 6: Live Demonstration Sequence** | **CONVERT / MOVE** | Keep as a transition card or move to after Slide 6 so the team presents all slides *before* switching screens to the live demo. |
| **Slide 7: Real-Life Impact in Bangladesh** | **SHORTEN & MERGE** | Compelling photos (flood relief, agriculture, rural school). Keep photos but condense text. |
| **Slide 8: Issues Faced & Debugging Solutions** | **MERGE with Slide 9** | 4 text bullets are too dense to read in 20 seconds. Merge top 2 debugging wins with hardware realities into one engineering slide. |
| **Slide 9: Physical Hardware Realities** | **MERGE with Slide 8** | Merge with Slide 8 into: **"Engineering Solutions & Hardware Realities"**. |
| **Slide 10: Conclusion & Questions** | **KEEP** | Clean concluding slide with member names and final summary. |
| **NEW REQUIREMENT**: Setup Steps & 4 Scenarios | **ADD NEW SLIDE** | Add a dedicated slide after Architecture: **"Simulation Setup & 4 Local Network Scenarios"** directly from [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md). |

### 2.2 Recommended Streamlined 7-Slide Deck Structure

```
Slide 1: Title, Team & The Power Comparison Hook (Keep)
    │
    ▼
Slide 2: Scope, Objectives & Simulator Choice (Shortened)
    │
    ▼
Slide 3: Hardware, Budget & Technical Feasibility (Merged Slides 3 & 4)
    │
    ▼
Slide 4: Storage Pinout & Dual-Phase Architecture (Streamlined Slide 5)
    │
    ▼
Slide 5: Simulation Setup & 4 Local Network Scenarios (NEW from runGuide.md)
    │
    ▼
Slide 6: Real-World Impact, Debugging & Hardware Realities (Merged Slides 7, 8 & 9)
    │
    ▼
Slide 7: Conclusion & Demo Transition (Slide 10 -> Transition to Live Demo)
```

---

## 3. Suggested Slide Contents & Visual Blueprints

### Slide 1: Title, Team & The Power Comparison Hook
* **Slide Header**: `CSE0611324 • MICROPROCESSOR LAB | Autumn 2026`
* **Title**: **ESP32 Embedded NAS & Static Web Node**
* **Subtitle**: Sub-1W Autonomous Edge Storage & Air-Gapped Web Server
* **Visuals**:
  - Horizontal bar graph:
    - **Traditional PC / NAS**: `60 Watts` (Red)
    - **ESP32 Edge NAS Node**: `< 1 Watt (0.5W)` (Bright Blue)
  - Simulator badge: `Wokwi (Full WASM + SPI + LwIP Stack)`
* **Footer / Side Panel**:
  - **Faculty Evaluators**: Tahmina Yeasmin Lima (Lecturer), Abrar Mahbub Tanim (Lecturer)
  - **Presented By**: Jannatul Ferdus (058), Gaus Saraf Murady (088), Sadia Islam (096)

---

### Slide 2: Scope, Objectives & Simulator Choice
* **Slide Title**: **Project Scope & Core Objectives**
* **Visual Layout**: 3 visual cards with modern icons:
  1. 🗄️ **Wireless Edge NAS**:
     - Browser-based multipart file uploads, chunked downloads, and dynamic file deletion.
  2. 🌐 **Static Web Hosting**:
     - Streams HTML5/CSS landing pages directly from MicroSD card (`/www/index.html`).
  3. 🛡️ **100% Air-Gapped & Zero-Cloud**:
     - Operates completely without internet, third-party software, or monthly subscription fees.
* **Simulator Justification Callout (Bottom Banner)**:
  - *"Why Wokwi? Unlike Tinkercad or Proteus, Wokwi executes compiled Xtensa binary code with cycle-accurate SPI bus signaling and the full LwIP TCP/IP stack."*

---

### Slide 3: Hardware, Budget & Technical Feasibility (Merged)
* **Slide Title**: **Hardware, Budget & Technical Feasibility**
* **Left Column — Sourcing & Bill of Materials (< 750 BDT)**:
  | Component | Specification | Local Cost |
  | :--- | :--- | :--- |
  | **ESP32 DevKit V1** | 240 MHz Dual-Core + Wi-Fi | ~400 BDT |
  | **MicroSD SPI Module** | 3.3V Level Shifter Socket | ~80 BDT |
  | **MicroSD Card** | Class 10 (8–32 GB FAT32) | ~250 BDT |
  | **Dupont Jumpers** | 6 Wires (< 15 cm length) | ~20 BDT |
  | **Total Budget** | **Complete Physical Unit** | **~750 BDT (~$7 USD)** |
* **Right Column — Technical & Computational Feasibility**:
  - ⚡ **Dual-Core FreeRTOS Partitioning**:
    - `Core 0`: Dedicated strictly to LwIP Wi-Fi radio & TCP packet handling.
    - `Core 1`: Dedicated to FAT32 SD block reads/writes and HTTP routing.
  - 💾 **Constant 2 KB RAM Streaming Guarantee**:
    - Multipart uploads and chunked downloads flush directly to SD sectors in 2 KB buffers; RAM consumption never increases with file size.
  - 📦 **Flash ROM Asset Management**:
    - Minimalist industrial dark-theme UI stored in 4 MB Flash via `PROGMEM` / `FPSTR()`, saving 300 KB SRAM.

---

### Slide 4: Storage Pinout & Dual-Phase Architecture
* **Slide Title**: **Hardware Interface & Dual-Phase Firmware**
* **Left Graphic — Hardware VSPI Pin Mapping**:
  - `GPIO 5` $\rightarrow$ `CS` (Chip Select — Active Low)
  - `GPIO 18` $\rightarrow$ `SCK` (Serial Clock @ 4 MHz)
  - `GPIO 23` $\rightarrow$ `DI` / `MOSI` (Master Out Slave In)
  - `GPIO 19` $\rightarrow$ `DO` / `MISO` (Master In Slave Out)
  - `3V3` & `GND` $\rightarrow$ `VCC` & `GND`
* **Right Graphic — Two-Phase Execution Flow**:
  - **Phase 1: Storage Subsystem Initialization**:
    - Mounts FAT32 over hardware VSPI, verifies `/default`, `/www`, and `/uploads`, seeds default assets from Flash ROM if missing.
  - **Phase 2: Network & REST Service**:
    - Connects to Wi-Fi, binds port 80 endpoints (`/`, `/site`, `/get`, `/upload`, `/delete`), and spawns FreeRTOS loopback diagnostics.

---

### Slide 5: Simulation Setup & 4 Local Network Scenarios (New)
* **Slide Title**: **Simulation Execution & Multi-Device Access Model**
* **Top Banner — Rapid Setup Sequence (Just mention the 5 steps)**:
  ```text
  [Step 0: Install Dependencies] ➔ [Step 1: Build Firmware] ➔ [Step 2: Open Port 9080 Firewall] ➔ [Step 3: Launch wokwigw] ➔ [Step 4: Start Wokwi]
  ```
* **Bottom Grid — 4 Validated Simulation Scenarios (from `runGuide.md`)**:
  | Scenario | Network Topology | Host & Client Connection | Key Advantage |
  | :--- | :--- | :--- | :--- |
  | **1. Home Hybrid** | Router Wi-Fi + Ethernet | Host PC on Ethernet (`192.168.0.x`), Phone on Wi-Fi | Zero interference, maximum upload stability |
  | **2. Lab Workstation** | Campus Lab Ethernet Switch | PC 1 (Host) and PC 2 (Peer) on wired lab switch | **LocalSend Web model**: Instant 2-PC file sharing without software |
  | **3. Showcase Hotspot** | Windows Mobile Hotspot | Laptop Hotspot (`192.168.137.1`), Mobile clients connect | **Deterministic IP presentation safeguard**; defeats campus Wi-Fi isolation |
  | **4. All-Wireless** | Single Wi-Fi SSID | Both Host laptop and phones connect to same router | Standard dorm/home wireless convenience |

---

### Slide 6: Real-World Impact, Debugging & Hardware Realities (Merged)
* **Slide Title**: **Real-World Impact & Engineering Solutions**
* **Top Row — 3 Socio-Economic Bangladesh Use Cases**:
  - 🌊 **Monsoon Flood Relief**: Broadcasts offline evacuation maps and survival guides when cell towers fail.
  - 🌾 **Agri-Sensor Logging**: Collects remote field crop telemetry on SD card for wireless retrieval.
  - 🏫 **Rural Schools & Clinics**: Offline digital textbooks and health records for 750 BDT with zero cloud fees.
* **Bottom Row — Key Debugging Wins & Silicon Mitigations**:
  - 🐛 **Wokwi Silkscreen & Clock Fix**: Mapped `esp:D5` and `sd1:SCK` to restore broken SPI signals.
  - 🌐 **Gateway & Firewall Automation**: Bundled `wokwigw` with auto-elevating `setup_firewall.bat` for port 9080.
  - 🔋 **Physical Hardware Transition**: Added 100 $\mu$F decoupling capacitor to stop Wi-Fi brownouts; capped SPI clock at 10 MHz.

---

### Slide 7: Conclusion & Demo Transition
* **Slide Title**: **Validated Embedded Node Ready for Demonstration**
* **Summary Statement**:
  > *"We have successfully engineered, simulated, and network-bridged an autonomous, sub-1W embedded NAS and static web host for under 750 BDT."*
* **Team Members**: Jannatul Ferdus • Gaus Saraf Murady • Sadia Islam
* **Call to Action**:
  - 🔴 **"Switching to Live Interactive File Server Demo (http://localhost:9080)"**

---

## 4. Rapid 3-Minute Spoken Script

> [!TIP]
> Keep speech crisp and punchy. Do not read the slides word-for-word. The slides provide visual evidence; your voice explains the core engineering decisions.

```
0:00 ──[ Speaker 1: Hook & Feasibility ]──> 0:50
0:50 ──[ Speaker 2: Architecture, Setup & 4 Scenarios ]──> 1:50
1:50 ──[ Speaker 3: Real Impact, Debugging & Hand-off ]──> 2:45
2:45 ──[ Operator / Team: Live 1-2 Min File Server Demo ]──> 4:00
```

---

### Part 1: Hook, Scope & Hardware Feasibility (Speaker 1 — 0:00 to 0:50)

*(Slide 1: Title & Hook)*
> *"Respected teachers and fellow classmates, traditional file servers and commercial NAS units draw 15 to 60 Watts and cost thousands of takas.  
> Today, our team demonstrates that an ultra-low-cost, 400-Taka ESP32 microcontroller can autonomously operate as a local wireless NAS and static web server, consuming less than 1 Watt of power."*

*(Slide 2: Scope & Objectives)*
> *"Our project achieves two goals:  
> First, a wireless file storage server that handles uploads, chunked downloads, and file deletion directly in the browser.  
> Second, a static web host that serves HTML5 pages from an SD card—100% offline, with zero cloud dependency.  
> We chose Wokwi over Tinkercad and Proteus because Wokwi simulates real compiled ESP32 machine code, hardware SPI lines, and the LwIP network stack."*

*(Slide 3: Hardware, Budget & Technical Feasibility)*
> *"As seen in our Bill of Materials, the entire physical hardware costs under 750 Taka.  
> How can a small chip handle multi-megabyte files?  
> Through two key engineering designs:  
> First, FreeRTOS splits tasks across both cores—Core 0 handles Wi-Fi, while Core 1 handles SD storage, so network packets never drop.  
> Second, our firmware streams incoming files in small 2 KB buffers directly into SD sectors. RAM usage stays strictly at 2 KB regardless of file size."*

**Handoff**: *"Now, Gaus will explain our hardware wiring, setup steps, and local network scenarios."*

---

### Part 2: Architecture, Setup & Network Scenarios (Speaker 2 — 0:50 to 1:50)

*(Slide 4: Storage Pinout & Dual-Phase Architecture)*
> *"Our circuit connects the MicroSD module to the ESP32 hardware VSPI bus on GPIO 5, 18, 19, and 23.  
> At boot, Phase 1 mounts the FAT32 filesystem and seeds default web assets from Flash memory.  
> Phase 2 connects to Wi-Fi and launches the web server on port 80."*

*(Slide 5: Simulation Setup & 4 Local Network Scenarios)*
> *"To run the simulation, we authored automated scripts covering five rapid steps: installing dependencies, building firmware, opening firewall port 9080, launching the gateway, and starting Wokwi.  
> What makes our simulation unique is that it is not trapped inside the browser.  
> By binding `wokwigw` to port 9080, our server operates across four distinct real-world scenarios:  
> 1. Home Hybrid, connecting Ethernet PC to Wi-Fi phones.  
> 2. Lab Workstations, where two lab computers share files across the Ethernet switch like LocalSend Web.  
> 3. Windows Mobile Hotspot, providing a deterministic IP of `192.168.137.1` that guarantees a working demo even if campus Wi-Fi blocks peer devices.  
> And 4. All-Wireless, connecting all devices to standard Wi-Fi."*

**Handoff**: *"Now, Sadia will present real-world applications, debugging solutions, and wrap up."*

---

### Part 3: Impact, Solutions & Conclusion (Speaker 3 — 1:50 to 2:45)

*(Slide 6: Real-World Impact, Debugging & Hardware Realities)*
> *"This system provides immense real-world value across Bangladesh:  
> During monsoon floods when mobile towers lose power, this battery-powered node broadcasts emergency maps and medical guides over local Wi-Fi.  
> In remote fields, it logs agricultural telemetry for engineers to retrieve wirelessly.  
> And in rural schools, it serves digital textbooks for 750 Taka with zero internet fees.  
> 
> During development, we solved critical engineering bugs: fixing the `esp:D5` silkscreen and `SCK` pin identifiers in Wokwi, and creating `setup_firewall.bat` to eliminate LAN timeouts.  
> For physical hardware deployment, we designed a 100 $\mu$F capacitor filter to absorb Wi-Fi current spikes and capped the SPI clock at 10 MHz to prevent wire capacitance errors."*

*(Slide 7: Conclusion & Demo Transition)*
> *"In conclusion, we have designed, simulated, and network-verified an autonomous, sub-1-Watt embedded NAS and web server for under 750 Taka.  
> We will now show you the live file server demo."*

---

## 5. Standalone Live File Server Demonstration Guide (1 to 2 Minutes)

### 5.1 Live Demo Sequence

> [!IMPORTANT]
> **Pre-Demo Preparation**: Have Chrome or Edge already open to `http://localhost:9080/` in the background with the simulation running, and have a test file (e.g. `test_program.asm` or a small image, < 500 KB) ready on the desktop.

```text
[Step 1: Dashboard Tour] ➔ [Step 2: Multipart Upload] ➔ [Step 3: Static Site] ➔ [Step 4: Download & Delete] ➔ [Step 5: Multi-Device Lab Share]
```

### 5.2 Demonstrator Narration Script

1. **Step 1: The Modern Dashboard (15 seconds)**:
   - *Action*: Switch to the browser tab showing `http://localhost:9080/`. Point to the top bar and file list.
   - *Narration*:
     > *"Here is the live dashboard served directly by the ESP32. Notice the live green status badge, the real-time FAT32 storage capacity bar showing used versus total bytes, and the file table."*

2. **Step 2: Live Multipart File Upload (25 seconds)**:
   - *Action*: Click **Choose File** (or drag and drop), select the test file, and click **Upload to NAS**.
   - *Narration*:
     > *"We select a file and click upload. The browser streams the payload to the ESP32, which flushes 2 KB chunks straight into MicroSD sectors. The page refreshes dynamically, our uploaded file appears in the table, and the storage bar recalculates instantly."*

3. **Step 3: Hosted Static Website Showcase (15 seconds)**:
   - *Action*: Click the **🌐 Static Site** button in the header (navigating to `http://localhost:9080/site`).
   - *Narration*:
     > *"Clicking Static Site loads `/site`. This complete HTML5 landing page is not on my PC disk—it is being streamed directly out of `/www/index.html` on the FAT32 SD card. The ESP32 is acting as a true standalone web host."*

4. **Step 4: File Download & Storage Reclamation (15 seconds)**:
   - *Action*: Return to `/`. Click **Download** on `lab_report.txt`, then click **Delete** on the newly uploaded file and confirm.
   - *Narration*:
     > *"Clicking Download streams the raw binary file with an octet-stream header. Clicking Delete invokes `SD.remove()`, instantly freeing FAT clusters and updating the storage meter."*

5. **Step 5: Multi-Device / Lab PC File Sharing (The LocalSend Web Model) (15 seconds)**:
   - *Action*: Point to the URL bar and mention the host IP address (e.g., `192.168.137.1:9080` or `10.100.x.x:9080`).
   - *Narration*:
     > *"Because our gateway binds to `0.0.0.0:9080`, this works exactly like LocalSend Web: any teacher or student in this lab can open our IP on their smartphone or laptop right now, without installing any software, to upload and download files directly from the ESP32."*
   - *Wrap*:
     > *"Thank you. We are now ready for your questions!"*

---

## 6. High-Yield Evaluator Q&A Defense Quick-Reference

| Question | Core Engineering Defense / Rebuttal | Key Technical Keywords |
| :--- | :--- | :--- |
| **Q1: Why use an ESP32 instead of a Raspberry Pi?** | A Raspberry Pi costs \$45–\$75, draws 3–7 Watts, and requires a full Linux OS with security patch cycles. The ESP32 costs \$4 (~400 BDT), consumes < 0.5 Watts, boots instantly (< 500 ms), and runs bare-metal FreeRTOS with zero OS vulnerabilities. | Cost, Sub-1W, FreeRTOS, Instant Boot |
| **Q2: What happens if an uploaded file exceeds the ESP32 RAM?** | It uploads safely without crashing. We never buffer the full file in memory. The firmware uses a streaming multipart parser that writes incoming 2 KB TCP packets directly to SD sectors before accepting the next packet. Heap overhead remains constant at ~2 KB. | Constant 2 KB Heap, `server.upload()`, Direct Flush |
| **Q3: Is the HTTP server running on the PC or inside the ESP32?** | It is 100% native to the ESP32 C++ firmware (`WebServer server(80)`). The PC runs no web server software (no Apache, Nginx, or Node.js). In simulation, `wokwigw.exe` is merely a transparent Layer 2/3 packet bridge forwarding host port 9080 to the virtual ESP32. | Native `WebServer.h`, Packet Bridge |
| **Q4: Why choose SPI mode over 4-bit SDMMC for the SD card?** | 4-bit SDMMC requires 6 pins, including GPIO 12 which is an internal strapping pin that can brick bootup if pulled high at power-on. SPI mode requires only 4 pins (`GPIO 5, 18, 19, 23`), avoids strapping pins, and is 100% supported by low-cost breakout modules. | Strapping Pin GPIO 12, 4-Pin VSPI |
| **Q5: How does this system operate in a disaster zone without a Wi-Fi router?** | Using native **SoftAP Mode** (`WiFi.softAP("ESP32-Edge-NAS")`). The ESP32 broadcasts its own Wi-Fi SSID and assigns client IPs via an internal DHCP server on `192.168.4.1`. Clients connect directly to the node without an external router or internet. | SoftAP Mode, DHCP, `192.168.4.1`, Air-Gapped |
| **Q6: How does the file server allow 2 computers in the lab to share files like LocalSend Web?** | LocalSend Web runs a temporary browser server on a PC. Our project does the same thing on an embedded microprocessor. Because `wokwigw` binds to `0.0.0.0:9080` and Windows Firewall port 9080 is open, any other PC or phone on the same lab network accesses the shared storage via browser without software installation. | Zero-Install, `0.0.0.0:9080`, Multi-Device LAN |
| **Q7: What if the campus network has Client/AP Isolation enabled?** | If campus Wi-Fi blocks inter-device communication, the host laptop turns on **Windows Mobile Hotspot**. Windows creates an independent Wi-Fi network assigning the host `192.168.137.1`. Client devices connect to this hotspot, completely bypassing campus isolation. | Mobile Hotspot, `192.168.137.1`, Bypass Isolation |
| **Q8: Why does the firmware clock the SPI bus at 4 MHz instead of 25 MHz?** | In simulation, 4 MHz prevents virtual SPI bus timing synchronization errors during sector writes. On physical breadboards, 4 to 10 MHz prevents bus errors caused by parasitic capacitance on jumper wires longer than 10 cm. | Timing Sync, Parasitic Capacitance |
