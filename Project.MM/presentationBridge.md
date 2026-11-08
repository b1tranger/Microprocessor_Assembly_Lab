# Presentation Bridge: Strategy, Roles & Execution Plan (Project.MM)

> **Course**: CSE0611324 — Microprocessors, Microcontrollers and Assembly Language Lab  
> **Course Lecturers**: Tahmina Yeasmin Lima Ma'am & Abrar Mahbub Tanim Sir  
> **Presentation Team**: Jannatul Ferdus, Gaus Saraf Murady, Sadia Islam  
> **Local Workspace**: [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig)  
> **Definitive Presentation Guide**: [`Project.MM/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/PRESENTATION_GUIDE.md)  
> **Total Time Budget**: Exactly 10 Minutes (9 Minutes Presentation + 1 Minute Defense/Buffer)

---

## Table of Contents
- [1. Delivery Strategy for Non-Native English Speakers](#1-delivery-strategy-for-non-native-english-speakers)
- [2. Time Budget & Role Division (10 Minutes Total)](#2-time-budget--role-division-10-minutes-total)
- [3. Step-by-Step Presentation Flow & Conduct Guide](#3-step-by-step-presentation-flow--conduct-guide)
  - [Part 1: Introduction, Scope & Simulation Platform Selection (Speaker 1 — 2.5 Minutes)](#part-1-introduction-scope--simulation-platform-selection-speaker-1--25-minutes)
    - [1.1 The Presentation Hook](#11-the-presentation-hook)
    - [1.2 Project & Team Identity](#12-project--team-identity)
    - [1.3 Project Scope & Real-World Objectives](#13-project-scope--real-world-objectives)
    - [1.4 Selection of Simulation Platform (Why Wokwi over Proteus/Tinkercad)](#14-selection-of-simulation-platform-why-wokwi-over-proteustinkercad)
  - [Part 2: Budget, Architecture & Live Demonstration (Speaker 2 — 4.0 Minutes)](#part-2-budget-architecture--live-demonstration-speaker-2--40-minutes)
    - [2.1 Financial Feasibility (Bill of Materials under 900 BDT)](#21-financial-feasibility-bill-of-materials-under-900-bdt)
    - [2.2 Technical & Computational Feasibility](#22-technical--computational-feasibility)
    - [2.3 Dual-Phase Implementation Architecture](#23-dual-phase-implementation-architecture)
    - [2.4 The Live Interactive Demonstration (LocalSend Web Model)](#24-the-live-interactive-demonstration-localsend-web-model)
  - [Part 3: Real-World Impact, Challenges, Hardware Realities & Conclusion (Speaker 3 — 2.5 Minutes)](#part-3-real-world-impact-challenges-hardware-realities--conclusion-speaker-3--25-minutes)
    - [3.1 Real-Life Problems Solved & Market Demand (Bangladesh Context)](#31-real-life-problems-solved--market-demand-bangladesh-context)
    - [3.2 Key Debugging Challenges & Engineering Solutions](#32-key-debugging-challenges--engineering-solutions)
    - [3.3 Simulation vs. Physical Hardware Realities](#33-simulation-vs-physical-hardware-realities)
    - [3.4 Future Roadmap & Final Conclusion](#34-future-roadmap--final-conclusion)
- [4. Evaluator Q&A Defense Quick-Reference](#4-evaluator-qa-defense-quick-reference)
  - [Q1: Why use an ESP32 instead of a Raspberry Pi? (Speaker 1)](#q1-why-use-an-esp32-instead-of-a-raspberry-pi-speaker-1)
  - [Q2: What happens if an uploaded file exceeds the ESP32 RAM? (Speaker 2)](#q2-what-happens-if-an-uploaded-file-exceeds-the-esp32-ram-speaker-2)
  - [Q3: Is the HTTP server running on the PC or inside the ESP32? (Speaker 2)](#q3-is-the-http-server-running-on-the-pc-or-inside-the-esp32-speaker-2)
  - [Q4: Why choose SPI mode over 4-bit SDMMC for the SD card? (Speaker 3)](#q4-why-choose-spi-mode-over-4-bit-sdmmc-for-the-sd-card-speaker-3)
  - [Q5: How does this system operate in a disaster zone without a Wi-Fi router? (Speaker 3)](#q5-how-does-this-system-operate-in-a-disaster-zone-without-a-wi-fi-router-speaker-3)
  - [Q6: How does the file server allow 2 computers in the lab to share files like LocalSend Web? (Speaker 2)](#q6-how-does-the-file-server-allow-2-computers-in-the-lab-to-share-files-like-localsend-web-speaker-2)
  - [Q7: What if the campus network has Client/AP Isolation enabled? (Speaker 1)](#q7-what-if-the-campus-network-has-clientap-isolation-enabled-speaker-1)
  - [Q8: Why does wokwigw work across LAN, and why was setup_firewall.bat created? (Speaker 3)](#q8-why-does-wokwigw-work-across-lan-and-why-was-setup_firewallbat-created-speaker-3)
- [5. Pre-Presentation Rehearsal Checklist](#5-pre-presentation-rehearsal-checklist)

---

## 1. Delivery Strategy for Non-Native English Speakers

* **Keep Sentences Short (Subject + Verb + Object)**: Avoid dense compound clauses. Instead of saying *"Considering the severe computational and volatile memory limitations imposed by the Xtensa architecture, we utilized a chunked streaming transfer mechanism,"* say:
  > *"The ESP32 has small memory. So, our firmware streams incoming files in small 2 KB chunks directly into the SD card."*
* **The "Look, Point, Explain" Rule**: When presenting slides or demonstrating the live software, do not look down at paper scripts. Point directly to the diagram, button, storage meter, or serial log on the screen, state what it is, and explain its hardware role in one clear sentence.
* **Active Laptop Operator Coordination**:
  * The designated speaker focuses 100% on oral delivery and maintaining eye contact with the evaluators.
  * A second team member operates the laptop, advancing slides and executing demo actions (clicking **Choose File**, **Upload**, **Download**, **Delete**, and switching browser tabs) without the speaker needing to turn around or lose momentum.
* **Pacing & Breathing**: Non-native speakers often speak rapidly when nervous. Maintain an intentional speaking cadence of **110–120 words per minute**. Take a full 1-to-2 second pause between slide transitions to allow evaluators to read the visual headers.
* **Mutual Fallback Protocol**: If a speaker forgets a specific technical keyword (such as *"PROGMEM"*, *"VSPI"*, or *"multipart chunk"*), the operating partner calmly mentions the keyword to keep the rhythm unbroken.

---

## 2. Time Budget & Role Division (10 Minutes Total)

| Speaker | Section / Agenda Items | Key Focus & Narrative Arc | Target Time |
| :--- | :--- | :--- | :--- |
| **Speaker 1** | **Introduction, Scope & Platform Selection**<br>• Presentation Hook (50W PC vs. <1W ESP32)<br>• Course, Group & Faculty Details<br>• Scope & Core Objectives<br>• Simulation Framework Selection (Why Wokwi over Proteus/Tinkercad) | Hook attention, emphasize autonomous operation, justify why Wokwi was selected over inferior simulators. | **2.5 min** |
| **Speaker 2** | **Budget, Feasibility, Architecture & Live Demo**<br>• Financial Feasibility (BOM under 900 BDT)<br>• Technical & Computational Feasibility (Dual-Core & SRAM)<br>• Dual-Phase Architecture (Phase 1 Storage & Phase 2 Web Server)<br>• Live Interactive Demonstration (Upload, Download, Static Site, LocalSend Web 2-PC Sharing) | Prove hardware practicality, explain FreeRTOS task separation, execute live dashboard and multi-device sharing interactions. | **4.0 min** |
| **Speaker 3** | **Real-World Impact, Challenges, Hardware Realities & Future**<br>• Real-Life Problems & Market Demand (Bangladesh context)<br>• Debugging Nuances Faced & Solved (`D5` silkscreen, `SCK` naming, Wokwi paywall bypass, Windows firewall)<br>• Simulation vs. Physical Hardware Realities (Capacitors, 10 MHz SPI cap)<br>• Future Roadmap (SoftAP mode, ESP32-S3 USB Host) & Conclusion | Connect to local rural/off-grid needs, demonstrate deep engineering debugging, explain transition to physical silicon, conclude strongly. | **2.5 min** |
| **All Members** | **Evaluator Q&A Defense** | Answer questions using the defense guide. | **1.0 min buffer** |

---

## 3. Step-by-Step Presentation Flow & Conduct Guide

### Part 1: Introduction, Scope & Simulation Platform Selection (Speaker 1 — 2.5 Minutes)

#### 1.1 The Presentation Hook
* **Conduct**: Begin with an energetic contrast. Point to an image of a bulky, expensive commercial NAS unit, a desktop router, or an x86 server.
* **Spoken Narrative**:
  > *"Good morning, respected teachers and peers. Traditional Network Attached Storage (NAS) units and web servers consume 15 to 60 Watts of continuous power and cost thousands of takas. Today, our team proves that an ultra-low-cost, 4-dollar ESP32 microprocessor can autonomously act as an air-gapped, zero-cloud local file storage node and static website host, consuming less than 1 Watt of power."*

#### 1.2 Project & Team Identity
* **Conduct**: Transition to the formal academic slide. Introduce your course code, course title, faculty advisors, and team members clearly.
* **Spoken Narrative**:
  > *"This project is submitted for CSE0611324: Microprocessors, Microcontrollers and Assembly Language Lab under the guidance of our honorable lecturers, Tahmina Yeasmin Lima ma'am and Abrar Mahbub Tanim sir. Our team members are Jannatul Ferdus, Gaus Saraf Murady, and Sadia Islam."*

#### 1.3 Project Scope & Real-World Objectives
* **Conduct**: Point out the dual-purpose nature of the system.
* **Spoken Narrative**:
  > *"Our scope is twofold:*
  > * *First, create a localized, wireless Network Attached Storage (NAS) node that handles file uploads, chunked downloads, and directory management without any external computer software.*
  > * *Second, serve static HTML5 web assets directly from raw block storage, acting as an offline documentation server.*
  > * *Most importantly, this system operates entirely air-gapped—requiring zero cloud connections, zero external subscriptions, and zero maintenance."*

#### 1.4 Selection of Simulation Platform (Why Wokwi over Proteus/Tinkercad)
* **Conduct**: Address simulation feasibility directly to preempt common evaluator questions.
* **Spoken Narrative**:
  > *"To validate our design, we evaluated multiple simulators. Tinkercad cannot simulate 32-bit microcontrollers or Wi-Fi. Proteus can simulate an SD card over SPI, but it completely lacks the ESP32 Wi-Fi and TCP/IP protocol stack. We chose Wokwi because it uses WebAssembly to execute raw compiled machine instructions, accurately models hardware SPI peripheral lines, and simulates the complete LwIP networking stack."*
* **Handoff**: *"Now, my teammate will explain our budget, prove technical feasibility, and demonstrate the working live system."*

---

### Part 2: Budget, Architecture & Live Demonstration (Speaker 2 — 4.0 Minutes)

#### 2.1 Financial Feasibility (Bill of Materials under 900 BDT)
* **Conduct**: Present the component sourcing table. Highlight that every part is standard, low-cost, and readily available in local electronics markets.
* **Spoken Narrative**:
  > *"When designing embedded systems, cost is paramount. As shown on our Bill of Materials, the physical deployment requires only four items:*
  > * *An ESP32 DevKit V1 board: approximately 400 Taka.*
  > * *A MicroSD SPI breakout adapter: around 80 Taka.*
  > * *A Class 10 MicroSD card: around 250 Taka.*
  > * *A set of short Dupont jumper wires: 20 Taka.*
  > * *The total hardware budget is under 900 Bangladeshi Taka—roughly 7 US dollars."*

#### 2.2 Technical & Computational Feasibility
* **Conduct**: Explain why a 400-Taka chip can handle high-throughput file transfers without crashing.
* **Spoken Narrative**:
  > *"Is a 4-dollar chip computationally feasible for this role? Yes, due to three architectural engineering decisions:*
  > * *1. Symmetric Dual-Core Partitioning: The ESP32 has two independent 240 MHz Xtensa CPU cores. Using FreeRTOS, Core 0 runs the LwIP Wi-Fi stack, while Core 1 handles SPI storage read and write operations. Because disk latency never blocks network interrupts, web connections never drop.*
  > * *2. Streaming Memory Guarantee: The ESP32 has roughly 300 KB of usable heap. To prevent out-of-memory kernel panics, we never buffer entire files in RAM. Instead, our multipart upload and download routines stream incoming network packets directly into SD card blocks in 2 KB buffers. Whether a file is 10 KB or 100 MB, RAM consumption remains fixed at just 2 KB.*
  > * *3. Flash Memory Optimization: Our glassmorphic HTML and CSS layouts are placed into 4 MB Flash ROM using the `PROGMEM` keyword and streamed via `FPSTR()`. This keeps RAM completely clear for network operations."*

#### 2.3 Dual-Phase Implementation Architecture
* **Conduct**: Point to the two-phase sequence diagram.
* **Spoken Narrative**:
  > *"Our implementation is organized into two distinct phases:*
  > * *Phase 1 (Storage): Maps hardware VSPI lines on GPIO 5, 18, 19, and 23, mounts the FAT32 filesystem, and seeds default web assets (`/www/index.html`) and documents (`/lab_report.txt`) dynamically at boot.*
  > * *Phase 2 (Networking): Connects to the network, initializes the native HTTP WebServer on port 80, binds REST endpoints (`/`, `/site`, `/get`, `/upload`, `/delete`), and spawns background telemetry."*

#### 2.4 The Live Interactive Demonstration (LocalSend Web Model)
* **Conduct**: The laptop operator switches to the active browser tab (`http://localhost:9080/`). Speaker 2 narrates while pointing directly at the actions on screen.
* **Demonstration Actions**:
  1. **Show the Dashboard**: Point out the dynamic Online badge, the real-time calculated storage meter (used vs. total capacity), and the seeded file list.
     > *"This modern dashboard is generated dynamically by the ESP32 firmware. It reads the FAT32 allocation tables directly over the SPI bus."*
  2. **Live File Upload**: Click **Choose File**, select a local document/image, and click **Upload to NAS**.
     > *"We select a file and click upload. The ESP32 streams the data directly into MicroSD card sectors. The page reloads, the file appears in the table, and the storage meter re-adjusts."*
  3. **Live File Download**: Click **Download** next to `lab_report.txt`.
     > *"Clicking download streams raw binary blocks with an octet-stream header directly to our desktop."*
  4. **Static Web Host Showcase**: Click **🌐 Static Site**.
     > *"Visiting `/site` serves an entire HTML landing page stored inside `/www/index.html` on the SD card. The ESP32 acts as a true standalone web host."*
  5. **File Deletion**: Return to `/`, click **Delete** on the uploaded file, and confirm.
     > *"Deleting the file invokes `SD.remove()`, unlinking the FAT clusters and reclaiming storage space immediately."*
  6. **Multi-Device / Lab PC File Sharing (The LocalSend Web Model)**:
     > *"Notice that our project functions exactly like LocalSend Web ('Share via Browser'). Because our gateway binds to `0.0.0.0:9080` and Windows Firewall port 9080 is opened, any other computer or smartphone in this lab room can navigate to our host IP in their browser—without installing any apps—and immediately upload or download files to share with us."*
* **Handoff**: *"Now, my teammate will explain the real-world applications in Bangladesh, the debugging challenges we solved, and our future plans."*

---

### Part 3: Real-World Impact, Challenges, Hardware Realities & Conclusion (Speaker 3 — 2.5 Minutes)

#### 3.1 Real-Life Problems Solved & Market Demand (Bangladesh Context)
* **Conduct**: Speak with conviction about local, practical use cases.
* **Spoken Narrative**:
  > *"Where does this system create real-world value?*
  > * *Disaster & Flood Relief: During monsoon floods in rural Bangladesh, cellular towers often lose power or become congested. This battery-operated node can broadcast emergency evacuation maps, medical guides, and shelter information locally over Wi-Fi.*
  > * *Air-Gapped Field Data Logging: In remote agricultural stations or industrial plants, microcontrollers can log environmental sensors to the SD card; engineers can walk up, connect locally, and download logs without needing internet cables.*
  > * *Rural Education & Clinics: Commercial cloud storage (AWS, Google Drive) requires foreign currency and continuous high-speed broadband. A 900-Taka node can store digitized textbooks, offline encyclopedias, and local clinic records for an entire village classroom."*

#### 3.2 Key Debugging Challenges & Engineering Solutions
* **Conduct**: Highlight how the team identified and resolved low-level simulation bugs. Evaluators value these specific engineering problem-solving details.
* **Spoken Narrative**:
  > *"During development, we encountered and resolved four major technical bottlenecks:*
  > * *1. The Wokwi D-Pin Silkscreen Bug: In `diagram.json`, declaring `esp:5` caused silent SPI connection failures because Wokwi's pin model requires the physical silkscreen label `esp:D5`. Correcting this restored the SPI bus connection.*
  > * *2. The SPI Clock Schema Mismatch: Standard breakout boards label the clock line as `CLK`, but Wokwi's part schema strictly requires `SCK`. Aligning this ensured proper bus synchronization.*
  > * *3. Library Version Deprecation: Newer ESP32 Arduino Cores removed legacy `mbedtls` MD5 functions, breaking older async libraries. We transitioned to the native, lightweight `WebServer.h` library, eliminating external dependencies completely.*
  > * *4. Multi-Interface Firewall & Gateway Bridging: To allow external lab computers and smartphones to access the node without connection timeouts, we authored `setup_firewall.bat` with auto-elevation to open inbound TCP 9080, and configured `wokwigw.exe` to bridge `0.0.0.0:9080` into virtual IP `10.13.37.2:80`."*

#### 3.3 Simulation vs. Physical Hardware Realities
* **Conduct**: Explain what must be taken into account when moving from the virtual canvas to real physical hardware.
* **Spoken Narrative**:
  > *"A simulation assumes ideal electrical conditions. To transition this code to physical silicon, we designed for two physical constraints:*
  > * *Power Rail Brownouts: Wi-Fi data bursts draw sudden current spikes over 300 mA, which can trip the ESP32's internal brownout detector. We mitigate this on breadboards by placing a 10 to 100 µF decoupling capacitor across the 3.3V rail.*
  > * *Bus Parasitic Capacitance: In simulation, wires have zero resistance. On physical breadboards, loose jumper wires cause signal degradation; we mitigate this by capping the SPI bus clock frequency at 10 MHz and keeping wires under 15 cm."*

#### 3.4 Future Roadmap & Final Conclusion
* **Conduct**: End on a forward-looking, confident note.
* **Spoken Narrative**:
  > *"For future work, we plan to implement:*
  > * *SoftAP Mode (`192.168.4.1`): Enabling the ESP32 to broadcast its own independent Wi-Fi access point, eliminating the need for an external Wi-Fi router entirely.*
  > * *ESP32-S3 USB Host Integration: Evaluating the ESP32-S3 microcontroller to interface standard USB thumb drives and external hard drives directly.*
  > * *Battery Management: Powering the node via an 18650 power bank enclosure for over 20 hours of continuous off-grid operation.*
  > 
  > *In conclusion, we have designed, simulated, and validated a complete, energy-efficient micro-NAS and web node for under 900 Taka. Thank you for your time and attention. We are now ready to answer your questions."*

---

## 4. Evaluator Q&A Defense Quick-Reference

Have this reference sheet open during evaluator questions. Each team member should be prepared to handle their designated technical domain.

### Q1: Why use an ESP32 instead of a Raspberry Pi? (Speaker 1)
* **Rebuttal**: Cost and power. A Raspberry Pi costs $45–$75 and draws 3 to 7 Watts of power. The ESP32 costs $4, draws less than 0.5 Watts, boots in under 500 milliseconds, and has no complex Linux OS vulnerabilities or patch cycles to manage.

### Q2: What happens if an uploaded file exceeds the ESP32 RAM? (Speaker 2)
* **Rebuttal**: It uploads safely without crashing. The firmware never buffers the whole file in RAM. It uses a streaming multipart parser that receives 1.4 KB TCP packets and flushes them immediately across the SPI bus into SD card blocks before accepting the next packet. RAM usage remains constant at 2 KB.

### Q3: Is the HTTP server running on the PC or inside the ESP32? (Speaker 2)
* **Rebuttal**: It is 100% internal and native to the ESP32 C++ firmware (`WebServer server(80)`). The PC is not running Apache or Nginx. In simulation, `wokwigw.exe` is only a transparent Layer-2/3 packet forwarder bridging host ports to the virtual MAC address.

### Q4: Why choose SPI mode over 4-bit SDMMC for the SD card? (Speaker 3)
* **Rebuttal**: Pin safety and hardware compatibility. 4-bit SDMMC requires 6 pins, including GPIO 12, which is an internal strapping pin that can brick bootup if pulled high at power-on. SPI mode requires only 4 pins, has universal support across cheap breakout boards, and matches our approved proposal pinout table (`GPIO 5, 18, 19, 23`).

### Q5: How does this system operate in a disaster zone without a Wi-Fi router? (Speaker 3)
* **Rebuttal**: Using native SoftAP mode (`WiFi.softAP("ESP32-Edge-NAS", "12345678")`). The ESP32 broadcasts its own Wi-Fi SSID and assigns IP addresses via an internal DHCP server. Anyone can connect directly to `http://192.168.4.1/` without an external router or internet connection.

### Q6: How does the file server allow 2 computers in the lab to share files like LocalSend Web? (Speaker 2)
* **Rebuttal**: LocalSend Web starts a temporary web server on one PC so other machines can visit it in a browser to upload or download files without installing an app. Our ESP32 NAS operates on the exact same zero-install browser principle. However, instead of running as a desktop app on PC hardware, our system is an independent embedded hardware appliance: files are committed directly to MicroSD FAT32 blocks via VSPI, and both computers are equal clients to the ESP32 node.

### Q7: What if the campus network has Client/AP Isolation enabled? (Speaker 1)
* **Rebuttal**: If the university router blocks PC-to-PC communication, the host machine turns on **Windows Mobile Hotspot** (`Settings > Mobile hotspot`). Windows creates a local wireless network assigning the host `192.168.137.1`. The second computer connects to this hotspot and accesses `http://192.168.137.1:9080/`, completely bypassing campus network isolation.

### Q8: Why does wokwigw work across LAN, and why was setup_firewall.bat created? (Speaker 3)
* **Rebuttal**: When `wokwigw.exe` is started with `--forward 9080:10.13.37.2:80`, it binds to socket `0.0.0.0:9080` (`INADDR_ANY`), listening on all network adapters (Ethernet, Wi-Fi, Hotspot). Because Windows Defender Firewall blocks unsolicited inbound TCP traffic by default, we created `setup_firewall.bat` with auto-UAC elevation to open inbound port 9080 across all profiles, ensuring peer computers can connect without timeouts.

---

## 5. Pre-Presentation Rehearsal Checklist

1. **Firewall Rule Enabled**: Run [`setup_firewall.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/setup_firewall.bat) as Administrator once on your presentation laptop.
2. **Local Bridge Running in Background**: Open PowerShell in [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig) and launch the gateway prior to stepping to the podium:
   ```powershell
   .\wokwigw.exe --forward 9080:10.13.37.2:80
   ```
3. **Pre-Compile Firmware**: Build the PlatformIO project beforehand (`Ctrl + Alt + B`) so you do not wait for cross-compilation during the 10-minute presentation window.
4. **Browser Tab Ready**: Have Chrome or Edge pre-opened to `http://localhost:9080/`.
5. **Test Payload Prepared**: Have a small, clean PDF, `.asm` file, or image file (under 2 MB) ready on the desktop for the live upload demonstration.
6. **Mobile Hotspot Verified (Optional Backup)**: Enable Windows Mobile Hotspot so you can demonstrate mobile access at `http://192.168.137.1:9080/` if Wi-Fi in the lab room is unstable.

