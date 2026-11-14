# Presentation Bridge v2: Rapid 3-Minute Deck & Live Demo Guide (Project.MM)

> **Course**: CSE0611324 — Microprocessors, Microcontrollers and Assembly Language Lab  
> **Course Instructors / Evaluators**: Tahmina Yeasmin Lima Ma'am (Lecturer) & Abrar Mahbub Tanim Sir (Lecturer)  
> **Institution**: Department of Computer Science & Engineering, University of Information Technology and Sciences (UITS)  
> **Presentation Team**: Jannatul Ferdus (0432410005101058), Gaus Saraf Murady (0432410005101088), Sadia Islam (0432410005101096)  
> **Workspace**: [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig)  
> **Definitive Presentation Guide**: [`Project.MM/Presentation/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/PRESENTATION_GUIDE.md)  
> **Legacy 10-Minute Bridge (v1)**: [`Project.MM/Presentation/v1_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v1_presentationBridge.md)  
> **Slide Reference Deck (v3.0)**: [`Project.MM/Presentation/v3.0_ESP32 Embedded NAS & Static Web Node.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v3.0_ESP32%20Embedded%20NAS%20&%20Static%20Web%20Node.pdf)  
> **Time Budget**: **Under 3 Minutes Presentation (8 Slides)** + **1–2 Minutes Live File Server Demo** + Faculty Q&A

---

## Table of Contents
- [1. Presentation Strategy & Strict Time Allocation](#1-presentation-strategy--strict-time-allocation)
  - [1.1 The Golden 3-Minute Rule](#11-the-golden-3-minute-rule)
  - [1.2 Role & Time Distribution Matrix](#12-role--time-distribution-matrix)
- [2. Slide Deck Audit: Transition from v2.2 (10 Slides) to v3.0 (8 Slides)](#2-slide-deck-audit-transition-from-v22-10-slides-to-v30-8-slides)
  - [2.1 Audit of the Legacy 10-Slide Deck (`v2.2` PDF)](#21-audit-of-the-legacy-10-slide-deck-v22-pdf)
  - [2.2 Streamlined 8-Slide Production Deck Structure (`v3.0` PDF)](#22-streamlined-8-slide-production-deck-structure-v30-pdf)
- [3. Slide Contents & Visual Blueprints (v3.0 Deck)](#3-slide-contents--visual-blueprints-v30-deck)
  - [Slide 1: ESP32 Embedded NAS & Static Web Node](#slide-1-esp32-embedded-nas--static-web-node)
  - [Slide 2: The Scope & Simulator Choice](#slide-2-the-scope--simulator-choice)
  - [Slide 3: Hardware, Budget & Technical Feasibility](#slide-3-hardware-budget--technical-feasibility)
  - [Slide 4: Hardware Interface & Dual-Phase Firmware](#slide-4-hardware-interface--dual-phase-firmware)
  - [Slide 5: Simulation Setup & 4 Local Network Scenarios](#slide-5-simulation-setup--4-local-network-scenarios)
  - [Slide 6: Real-World Impact, Debugging & Hardware Realities](#slide-6-real-world-impact-debugging--hardware-realities)
  - [Slide 7: Physical Hardware Realities (Negated in Simulation)](#slide-7-physical-hardware-realities-negated-in-simulation)
  - [Slide 8: Conclusion](#slide-8-conclusion)
- [4. Rapid 3-Minute Spoken Script](#4-rapid-3-minute-spoken-script)
  - [Part 1: Hook, Scope & Hardware Feasibility (Speaker 1 — 0:00 to 0:50)](#part-1-hook-scope--hardware-feasibility-speaker-1--000-to-050)
  - [Part 2: Interface, Setup & Network Scenarios (Speaker 2 — 0:50 to 1:40)](#part-2-interface-setup--network-scenarios-speaker-2--050-to-140)
  - [Part 3: Silicon Realities & Conclusion (Speaker 3 — 1:40 to 2:25)](#part-3-silicon-realities--conclusion-speaker-3--140-to-225)
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
> - **Total Presentation Word Budget**: **~330–360 words** across the 8-slide deck.
> - **Live Demo Window**: **60 to 90 seconds** focused strictly on the web UI and live file transfer.
> - **Rule of Conduct**: Never read bullet points off slides. Point to the diagram, state the key takeaway, and advance.

### 1.2 Role & Time Distribution Matrix

| Segment | Speaker | Scope & Content | Target Time | Word Budget |
| :--- | :--- | :--- | :--- | :--- |
| **Part 1** | **Speaker 1** (Jannatul Ferdus) | **The Hook, Problem Scope & Feasibility (Slides 1–3)**<br>• Slide 1: 60W PC vs. <1W ESP32 Hook & Team Metadata<br>• Slide 2: Scope (Wireless NAS + Static Host) & Wokwi Choice<br>• Slide 3: Merged Budget (~750 BDT) & 2 KB RAM Streaming Guarantee | **0:00 – 0:50** (50s) | ~110 words |
| **Part 2** | **Speaker 2** (Gaus Saraf Murady) | **Architecture, Setup & Network Scenarios (Slides 4–6)**<br>• Slide 4: VSPI Pinout Mapping & Two-Phase Execution Flow<br>• Slide 5: 5 Rapid Setup Steps & 4 Validated Network Scenarios<br>• Slide 6: Real-World Impact (Floods, Agri-logging, Rural schools) | **0:50 – 1:40** (50s) | ~120 words |
| **Part 3** | **Speaker 3** (Sadia Islam) | **Hardware Realities & Conclusion (Slides 7–8)**<br>• Slide 7: Silicon Realities (Brownouts, 100 $\mu$F Cap, SPI Capping, Bus Scaling)<br>• Slide 8: Final Summary Quote & Direct Handoff to Live Demo | **1:40 – 2:25** (45s) | ~95 words |
| **Demo** | **Operator / Speaker 2** | **Live Interactive File Server Demonstration**<br>• Dashboard capacity & file table inspection<br>• Real-time file upload & sector commit<br>• Static site rendering (`/site`)<br>• Download & storage cluster reclaim<br>• Zero-install LocalSend Web 2-PC sharing | **2:25 – 3:45** (80s) | ~90 words |
| **Q&A** | **All Members** | **Faculty Oral Defense & Questions** | Buffer / As required | — |

---

## 2. Slide Deck Audit: Transition from v2.2 (10 Slides) to v3.0 (8 Slides)

### 2.1 Audit of the Legacy 10-Slide Deck (`v2.2` PDF)

| Original Slide in `v2.2` PDF | Status & Evaluation | Transformation into `v3.0` PDF |
| :--- | :--- | :--- |
| **Slide 1: Title & Hook** | **RETAINED & ENHANCED** | Kept the strong visual comparison (60W PC vs. <1W ESP32) and added faculty/group details directly onto the title card. |
| **Slide 2: Scope & Simulator Choice** | **CONDENSED** | Retitled to **"The Scope & Simulator Choice"**, streamlined into 3 visual bullet cards (Wireless NAS, Static Web Host, 100% Air-Gapped) plus Wokwi justification. |
| **Slide 3: Budget & Financial Feasibility** | **MERGED into Slide 3** | Combined component sourcing table with technical feasibility to avoid redundant explanations. |
| **Slide 4: Technical & Computational Feasibility** | **MERGED into Slide 3** | Merged with Slide 3 into **"Hardware, Budget & Technical Feasibility"** with the 750 BDT BOM table, dual-core callouts, and 2 KB streaming guarantees. |
| **Slide 5: Dual-Phase Implementation** | **STREAMLINED into Slide 4** | Retitled to **"Hardware Interface & Dual-Phase Firmware"** with hardware VSPI pinout table, Phase 1/Phase 2 execution boxes, and dark-theme UI screenshot. |
| **NEW REQUIREMENT**: Setup Steps & 4 Scenarios | **ADDED as Slide 5** | Authored **"Simulation Setup & 4 Local Network Scenarios"** directly integrating the 5 execution steps and 4-topology test matrix from [`runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md). |
| **Slide 6: Live Demonstration Sequence** | **CONVERTED** | Shifted live demo from a mid-presentation slide into an interactive hands-on demo immediately following the concluding slide. |
| **Slide 7: Real-Life Impact in Bangladesh** | **CONVERTED to Slide 6** | Retitled to **"Real-World Impact, Debugging & Hardware Realities"** featuring the 3 high-impact photos (Flood relief, Agri-logging, Rural schools). |
| **Slide 8 & 9: Issues Faced & Hardware Realities** | **MERGED into Slide 7** | Consolidated into **"Physical Hardware Realities (Negated in Simulation)"** covering brownout caps, wire capacitance / clock capping, CMD24 bus scaling, and power loss. |
| **Slide 10: Conclusion & Questions** | **REFINED into Slide 8** | Concluding slide with the 750 BDT summary quote and visual trigger: *"Now let’s observe a live demonstration..."* |

### 2.2 Streamlined 8-Slide Production Deck Structure (`v3.0` PDF)

```
Slide 1: ESP32 Embedded NAS & Static Web Node (Power Comparison Hook & Evaluator Card)
    │
    ▼
Slide 2: The Scope & Simulator Choice (Wireless NAS, Static Host, 100% Air-Gapped)
    │
    ▼
Slide 3: Hardware, Budget & Technical Feasibility (~750 BDT BOM + Dual-Core FreeRTOS + 2 KB Streaming)
    │
    ▼
Slide 4: Hardware Interface & Dual-Phase Firmware (VSPI Pinout Table + Dual-Phase Execution Flow)
    │
    ▼
Slide 5: Simulation Setup & 4 Local Network Scenarios (5-Step Setup + 4 Real-World Topologies)
    │
    ▼
Slide 6: Real-World Impact, Debugging & Hardware Realities (Flood Relief, Agri-logging, Rural Schools)
    │
    ▼
Slide 7: Physical Hardware Realities (Negated in Simulation) (Decoupling Caps, Clock Capping, Bus Scaling)
    │
    ▼
Slide 8: Conclusion (Sub-1W / 750 BDT Summary Quote ➔ Handoff to Live Demo)
```

---

## 3. Slide Contents & Visual Blueprints (v3.0 Deck)

### Slide 1: ESP32 Embedded NAS & Static Web Node
* **Slide Header**: `UITS Logo | CSE0611324 • MICROPROCESSOR LAB | Autumn 2026`
* **Main Title**: **ESP32 Embedded NAS & Static Web Node**
* **Left Card — Power & Platform Comparison Diagram**:
  - Horizontal bar graph:
    - **Traditional PC NAS**: `60 Watts` (Solid Red bar)
    - **ESP32 Edge NAS Node**: `< 1 Watt (0.5W)` (Solid Blue bar)
  - Platform comparison:
    - `Tinkercad / Proteus`: *No ESP32 Wi-Fi stack.*
    - `Wokwi (Selected)`: *Full WASM + SPI + LwIP.*
* **Right Card — Academic & Group Metadata**:
  - **SUBMITTED TO (FACULTY)**:
    - Tahmina Yeasmin Lima (Lecturer)
    - Abrar Mahbub Tanim (Lecturer)
  - **SUBMITTED BY (GROUP MEMBERS)**:
    - Jannatul Ferdus • `0432410005101058`
    - Gaus Saraf Murady • `0432410005101088`
    - Sadia Islam • `0432410005101096`
* **Footer**: `Department of CSE • Autumn 2026 | Page 01 / 10`

---

### Slide 2: The Scope & Simulator Choice
* **Slide Title**: **The Scope & Simulator Choice**
* **Left Graphic**: Realistic office workspace photo with commercial NAS beside laptop displaying file server dashboard.
* **Right Column — Core Scope Deliverables**:
  - 🗄️ **Wireless NAS**: Native uploads, downloads, and file delete.
  - 🌐 **Static Web Host**: Streams HTML5 directly from SD card.
  - 🛡️ **100% Air-Gapped**: Zero cloud fees or PC server software.
* **Simulator Justification Callout (Bottom Banner & Footer Context)**:
  - *Footer Inscription*: `Scope & Simulation Justification | Page 02 / 10`
  - *Core Justification*: **Why Wokwi?** Unlike Tinkercad or Proteus (which lack an ESP32 802.11 Wi-Fi radio stack and real-time network emulation), Wokwi executes compiled Xtensa binary code in WebAssembly with cycle-accurate SPI bus signaling and the complete LwIP TCP/IP stack.
  - *Visual Bridge*: Resolves the platform comparison introduced in Slide 1's bottom card (`Tinkercad / Proteus: No ESP32 Wi-Fi stack` vs. `Wokwi (Selected): Full WASM + SPI + LwIP`), providing the team with an airtight defense on why standard university circuit simulators were bypassed for microprocessor network storage.
* **Footer**: `Scope & Simulation Justification | Page 02 / 10`

---

### Slide 3: Hardware, Budget & Technical Feasibility
* **Slide Title**: **Hardware, Budget & Technical Feasibility**
* **Left Column — Bill of Materials (< 750 BDT)**:
  | Component | Specification | Local Cost |
  | :--- | :--- | :--- |
  | **ESP32 DevKit V1** | 240 MHz Dual-Core + Wi-Fi | ~400 BDT |
  | **MicroSD SPI Module** | 3.3V Level Shifter Socket | ~80 BDT |
  | **MicroSD Card** | Class 10 (8–32 GB FAT32) | ~250 BDT |
  | **Dupont Jumpers** | 6 Wires (< 15 cm length) | ~20 BDT |
  - **Total Cost Banner**: **`~750 BDT`** (Large bold red callout)
* **Right Column — Computational Feasibility Badges**:
  - **XTENSA CORE 0**: `LwIP Wi-Fi & TCP Stack` (Handles wireless radio interrupts uninterrupted.)
  - **XTENSA CORE 1**: `FAT32 SPI & WebServer` (Executes SD card reads/writes without blocking Wi-Fi.)
  - **Constant 2 KB RAM Stream**: 10 MB uploads flush in 1.4 KB chunks straight to SD sectors.
  - **4 MB Flash PROGMEM**: Minimalist UI stored in ROM via `FPSTR()` saves 300 KB SRAM.
* **Bottom Graphic**: Photos of ESP32 DevKit, 32 GB SanDisk MicroSD, MicroSD breakout with labeled pins, and Dupont jumper wires.
* **Footer**: `Page 03 / 10`

---

### Slide 4: Hardware Interface & Dual-Phase Firmware
* **Slide Title**: **Hardware Interface & Dual-Phase Firmware**
* **Left Column — Pinout & Execution Flow**:
  - **Top: Hardware VSPI Pin Mapping**:
    - `[GPIO 5] (esp:D5)` $\rightarrow$ `[CS] (sd1:CS)`
    - `[GPIO 18] (esp:D18)` $\rightarrow$ `[SCK] (sd1:SCK)`
    - `[GPIO 23] (esp:D23)` $\rightarrow$ `[MOSI] (sd1:DI)`
    - `[GPIO 19] (esp:D19)` $\leftarrow$ `[MISO] (sd1:DO)`
    - `[3V3] (esp:3V3)` $\rightarrow$ `[VCC] (sd1:VCC)`
    - `[GND] (esp:GND.1)` $\rightarrow$ `[GND] (sd1:GND)`
  - **Bottom: Two-Phase Execution Flow**:
    - **Phase 1: Storage Subsystem Initialization (Red Box)**: Mounts FAT32 over hardware VSPI, verifies `/default`, `/www`, and `/uploads`, seeds default assets from Flash ROM if missing.
    - **Phase 2: Network & REST Service (Blue Box)**: Connects to Wi-Fi, binds port 80 endpoints (`/`, `/site`, `/get`, `/upload`, `/delete`), and spawns FreeRTOS loopback diagnostics.
* **Right Column**: Live high-resolution screenshot of the dark-mode web UI ("ESP32 Storage NAS Node", "Hardware VSPI FAT32 MicroSD Storage Engine").
* **Footer**: `Page 04 / 10`

---

### Slide 5: Simulation Setup & 4 Local Network Scenarios
* **Slide Title**: **Simulation Setup & 4 Local Network Scenarios**
* **Left Column — Rapid Setup Pipeline & Power Architecture**:
  - Vertical pipeline flow:
    ```text
    [Step 0: Install Dependencies]
          │
    [Step 1: Build Firmware]
          │
    [Step 2: Open Port 9080 Firewall]
          │
    [Step 3: Launch wokwigw]
          │
    [Step 4: Start Wokwi]
    ```
  - Graphic: Power bank connected via USB to ESP32 emitting Wi-Fi waves with brownout dip curve.
* **Right Column — The 4 Validated Network Topologies**:
  | Scenario | Network Topology | Host & Client Connection | Key Advantage |
  | :--- | :--- | :--- | :--- |
  | **1. Home Hybrid** | Router Wi-Fi + Ethernet | Host PC on Ethernet (`192.168.0.x`), Phone on Wi-Fi | Zero interference, maximum upload stability |
  | **2. Lab Workstation** | Campus Lab Ethernet Switch | PC 1 (Host) and PC 2 (Peer) on wired lab switch | **LocalSend Web model**: Instant 2-PC file sharing without software |
  | **3. Showcase Hotspot** | Windows Mobile Hotspot | Laptop Hotspot (`192.168.137.1`), Mobile clients connect | **Deterministic IP presentation safeguard**; defeats campus Wi-Fi isolation |
  | **4. All-Wireless** | Single Wi-Fi SSID | Both Host laptop and phones connect to same router | Standard dorm/home wireless convenience |
* **Footer**: `Page 05 / 10`

---

### Slide 6: Real-World Impact, Debugging & Hardware Realities
* **Top Header**: `PART 2 • SPEAKER 2 (LIVE DEMO)`
* **Slide Title**: **Real-World Impact, Debugging & Hardware Realities**
* **Visual Layout — 3 Socio-Economic Deployments in Bangladesh**:
  1. 🌊 **Monsoon Flood Relief** (Top Left, photo of rugged phone showing offline evacuation map):
     - *"Broadcasts offline evacuation maps and medical guides when cellular towers fail."*
  2. 🌾 **Agri-Sensor Logging** (Top Center, photo of breadboard sensor rig & solar field mast):
     - *"Collects remote field telemetry on SD card for wireless engineer retrieval."*
  3. 🏫 **Rural Schools & Clinics** (Bottom Center, illustration of rural classroom with girl viewing tablet connected to ESP32):
     - *"Hosts digital textbooks and clinic records for 900 BDT with zero USD cloud fees."*
* **Footer**: `Interactive Browser & Mobile LAN Verification | Page 06 / 10`

---

### Slide 7: Physical Hardware Realities (Negated in Simulation)
* **Top Header**: `PART 3 • SPEAKER 3`
* **Slide Title**: **Physical Hardware Realities (Negated in Simulation)**
* **4 Engineering Realities Surrounding Hardware Photos**:
  - ⚡ **Power Brownout Spikes (Orange Box, Top-Left)**:
    - *Physical Reality*: Wi-Fi TX (>300 mA) + SD writes (200 mA) sag 3.3V rails below 2.8V.
    - *Fix*: Place 100 $\mu$F + 0.1 $\mu$F decoupling capacitors across VCC/GND.
  - 📏 **Wire Capacitance & Levels (Green Box, Bottom-Left)**:
    - *Physical Reality*: Jumpers (>15 cm) distort clock edges; resistor dividers fail at high speed.
    - *Fix*: Cap SPI clock at 4–10 MHz and use active IC level shifters (74LVC125A).
  - 🗃️ **Bus & Capacity Scaling (Red Box, Top-Right)**:
    - *Simulation*: Wokwi caps storage at 256 MB and forces sequential CMD24 writes.
    - *Silicon*: Scales to 32 GB+ cards, native CMD25 pipelines, and 4-bit SDMMC (20–40 MB/s).
  - ⚠️ **Power-Loss & Flash Erasure (Blue Box, Bottom-Right)**:
    - *Physical Reality*: Sudden outages corrupt FAT32 chains (needs supercap/LittleFS), and `SD.remove()` permanently wipes flash blocks.
* **Center Graphic**: High-resolution photos of MicroSD breakout board and 1000 $\mu$F 16V decoupling capacitor.
* **Footer**: `Hardware Transition & Next-Gen Scalability | Page 09 / 10`

---

### Slide 8: Conclusion
* **Slide Title**: **Conclusion**
* **Center Core Takeaway**:
  > *"We have successfully engineered, simulated, and network-bridged an autonomous, sub-1W embedded NAS and static web host for under 750 BDT."*
* **Call to Action**:
  - **`Now let’s observe a live demonstration...`**
* **Footer**: `Socio-Economic Value in Rural Bangladesh | Page 07 / 10`

---

## 4. Rapid 3-Minute Spoken Script

> [!TIP]
> Keep speech crisp, confident, and punchy. Point directly to diagrams and tables rather than reading words off the screen.

```text
0:00 ──[ Speaker 1: Hook, Scope & Feasibility (Slides 1–3) ]──> 0:50
0:50 ──[ Speaker 2: Interface, Setup & Impact (Slides 4–6) ]──> 1:40
1:40 ──[ Speaker 3: Hardware Realities & Conclusion (Slides 7–8) ]──> 2:25
2:25 ──[ Operator / Team: Live 1–2 Min File Server Demo ]──> 3:45
```

---

### Part 1: Hook, Scope & Hardware Feasibility (Speaker 1 — 0:00 to 0:50)

*(Slide 1: ESP32 Embedded NAS & Static Web Node)*
> *"Respected course instructors Tahmina Ma'am and Tanim Sir, and fellow classmates: traditional NAS servers draw 15 to 60 Watts and cost thousands of takas.  
> Today, our team demonstrates that an ultra-low-cost, 400-Taka ESP32 microcontroller can autonomously operate as a local wireless NAS and static web server, consuming under 1 Watt of power."*

*(Slide 2: The Scope & Simulator Choice)*
> *"Our project delivers three capabilities:  
> First, a wireless file server supporting browser uploads, downloads, and file deletion.  
> Second, a static web host streaming HTML5 landing pages directly from MicroSD storage.  
> And third, 100% air-gapped operation with zero cloud dependencies or monthly fees.  
> We selected Wokwi because it executes compiled Xtensa binaries with cycle-accurate SPI signaling and the full LwIP network stack."*

*(Slide 3: Hardware, Budget & Technical Feasibility)*
> *"As seen in our Bill of Materials, the entire physical hardware costs under 750 Taka.  
> To prevent memory exhaustion on a chip with only 520 KB of RAM, we engineered two critical solutions:  
> First, FreeRTOS isolates networking on Core 0 and storage writes on Core 1, preventing packet dropouts.  
> Second, our firmware streams data in 2 KB chunks straight to SD sectors, locking RAM consumption at a flat 2 KB regardless of file size."*

**Handoff**: *"Now, Gaus will explain our hardware wiring, setup steps, and network scenarios."*

---

### Part 2: Interface, Setup & Network Scenarios (Speaker 2 — 0:50 to 1:40)

*(Slide 4: Hardware Interface & Dual-Phase Firmware)*
> *"Our circuit connects the MicroSD card module to the ESP32 hardware VSPI bus on GPIO 5, 18, 19, and 23.  
> At boot, Phase 1 mounts FAT32 and auto-seeds default web assets from Flash memory.  
> Phase 2 connects to Wi-Fi and launches the web daemon on port 80."*

*(Slide 5: Simulation Setup & 4 Local Network Scenarios)*
> *"To run the simulation, we execute five rapid automated steps: installing dependencies, building firmware, opening firewall port 9080, launching `wokwigw`, and starting Wokwi.  
> By binding `wokwigw` to port 9080, our simulated server operates across four real-world topologies:  
> 1. Home Hybrid, connecting Ethernet PC to Wi-Fi phones.  
> 2. Lab Workstations, enabling two campus PCs to share files like LocalSend Web with zero software installation.  
> 3. Windows Mobile Hotspot, providing a deterministic IP of `192.168.137.1` that guarantees access even if campus Wi-Fi has client isolation enabled.  
> And 4. All-Wireless, connecting all devices to standard Wi-Fi."*

*(Slide 6: Real-World Impact, Debugging & Hardware Realities)*
> *"This system provides immense real-world value across Bangladesh:  
> During monsoon floods when cellular towers lose power, it broadcasts emergency evacuation maps and medical guides over local Wi-Fi.  
> In coastal districts, it logs agricultural telemetry for field engineers to retrieve wirelessly.  
> And in rural schools, it delivers digital textbooks for under 750 Taka with zero internet costs."*

**Handoff**: *"Now, Sadia will explain our physical hardware transitions and conclude."*

---

### Part 3: Silicon Realities & Conclusion (Speaker 3 — 1:40 to 2:25)

*(Slide 7: Physical Hardware Realities (Negated in Simulation))*
> *"Transitioning from simulation to physical silicon reveals real-world hardware challenges:  
> First, Wi-Fi radio bursts draw over 300 mA, causing voltage brownouts; we resolve this by placing a 100 $\mu$F electrolytic capacitor across the power rails.  
> Second, breadboard jumper capacitance distorts high-speed signals; we cap the SPI clock at 4 to 10 MHz to preserve square wave integrity.  
> Third, while Wokwi limits virtual storage to 256 MB and requires sequential CMD24 writes, physical hardware scales to 32 GB cards with high-speed 4-bit SDMMC.  
> And finally, sudden power losses can corrupt FAT32 chains, which we protect against through atomic sector flushes."*

*(Slide 8: Conclusion)*
> *"In conclusion, we have designed, simulated, and network-bridged an autonomous, sub-1-Watt embedded NAS and web host for under 750 BDT.  
> We will now demonstrate the live system running in real-time."*

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
   - *Action*: Click **Choose File** (or drag and drop), select the test file, and click **Upload to Storage**.
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
