# 19. ESP32 NAS Presentation Bridge v2 and LaTeX Report v4

- **Conversation ID**: `d5bed0df-0603-464c-8086-fdb4c4e16cbc`
- **Timestamp**: `2026-11-14T17:02:14+06:00`
- **Model**: `Gemini 3.8 Flash`
- **Target Files & Artifacts**:
  - Presentation Guide: [`Project.MM/Presentation/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/PRESENTATION_GUIDE.md)
  - Legacy 10-Minute Bridge (v1): [`Project.MM/Presentation/v1_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v1_presentationBridge.md)
  - Rapid 3-Minute Bridge (v2): [`Project.MM/Presentation/v2_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v2_presentationBridge.md)
  - Final Report Source (v4): [`Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex)
  - Final Report Compiled PDF (v4): [`Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).pdf)
  - Final Report Clean Source: [`Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex)
  - Final Report Clean PDF: [`Project.MM/FinalReport/v4_MM_Lab_Final_Report.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report.pdf)
  - Project Overview: [`Project.MM/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/README.md)
  - Local Simulation Workspace: [`Project.MM/LocalConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md)
  - Operational Run Guide: [`Project.MM/LocalConfig/runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md)
  - Firmware Source: [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp)
  - Web Interfaces: [`Project.MM/LocalConfig/data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html) \& [`Project.MM/LocalConfig/data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html)

---

## Table of Contents
- [1. User Request Summary](#1-user-request-summary)
- [2. Code & Files Inspected / Modified](#2-code--files-inspected--modified)
- [3. Analysis & Key Insights](#3-analysis--key-insights)
  - [3.1 Presentation Time Constraint: Under 3 Minutes + 1--2 Minute Live Demo](#31-presentation-time-constraint-under-3-minutes--12-minute-live-demo)
  - [3.2 Slide Deck Optimization: Trimming, Merging & New Network Scenarios](#32-slide-deck-optimization-trimming-merging--new-network-scenarios)
  - [3.3 Comprehensive LaTeX Report v4 Architecture](#33-comprehensive-latex-report-v4-architecture)
  - [3.4 Layout Refinements: Column Containment, Line Wrapping & Diagonal Authors](#34-layout-refinements-column-containment-line-wrapping--diagonal-authors)
  - [3.5 Architecture Diagram Integration (Fig. 1)](#35-architecture-diagram-integration-fig-1)
  - [3.6 Download Speed Optimization & TCP Proxy Timeout Resolution](#36-download-speed-optimization--tcp-proxy-timeout-resolution)
  - [3.7 Academic Metadata, Faculty Details & Group Details Integration](#37-academic-metadata-faculty-details--group-details-integration)
- [4. Final Solution & Outcomes](#4-final-solution--outcomes)
  - [4.1 Path Updates for Moved Presentation Documents](#41-path-updates-for-moved-presentation-documents)
  - [4.2 Presentation Bridge v1 Rename & Presentation Bridge v2 Creation](#42-presentation-bridge-v1-rename--presentation-bridge-v2-creation)
  - [4.3 Authoring & Verified Compilation of Report v4](#43-authoring--verified-compilation-of-report-v4)
  - [4.4 Academic Cover Details & Faculty Title Integration in LaTeX & README](#44-academic-cover-details--faculty-title-integration-in-latex--readme)
  - [4.5 Verification & Artifact Deliverables](#45-verification--artifact-deliverables)

---

## 1. User Request Summary
The user requested four major updates across the `Project.MM` embedded NAS repository:
1. **Repository Link Updates**: The user moved `PRESENTATION_GUIDE.md` and `presentationBridge.md` into `Project.MM/Presentation/`. All repository references and cross-links pointing to the previous locations needed to be identified and updated.
2. **Presentation Bridge Versioning & Transformation**:
   - Rename `Project.MM/Presentation/presentationBridge.md` to `v1_presentationBridge.md`.
   - Author a new `v2_presentationBridge.md` specifically tailored for a presentation under 3 minutes, presenting a slide similar to [`temp/v2.2_ESP32 Embedded NAS & Static Web Node.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/temp/v2.2_ESP32%20Embedded%20NAS%20&%20Static%20Web%20Node.pdf) under the strict time constraint.
   - Include a standalone 1--2 minute live file server demonstration sequence to be conducted before faculty evaluators ask questions.
   - Incorporate the rapid simulation setup steps and the 4 validated network scenarios from [`Project.MM/LocalConfig/runGuide.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/runGuide.md) into the slide suggestions.
   - Provide concrete recommendations on which slides to remove, shorten, or merge (e.g., merging "Technical & Computational Feasibility" with "Budget & Financial Feasibility").
   - Include suggested slide contents alongside a simplified script that avoids over-explaining.
3. **Final Report v4 (`Project.MM/FinalReport/`)**:
   - Update [`Project.MM/FinalReport/v3_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v3_MM_Lab_Final_Report(PresentationAid).tex) with the latest project progress and create a new file with suffix `v4`: [`v4_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex).
   - Add the full source code for [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp) in an "Appendix" section at the very bottom.
   - Add truncated code snippets for [`data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html) and [`data/www/index.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/index.html) (truncating `<style>` sections with `/* ... */` while retaining complete `<body>` markup and frontend logic).
   - Integrate the latest visual and structural updates (dark-mode industrial UI, single-column table containment, line wrapping, diagonal author arrangement, file tree in Appendix C, and Wokwi gateway architecture diagram Fig. 1).
4. **Academic Metadata, Download Speed Diagnostics & Faculty Details**:
   - Resolve download speed degradation (< 1 KB/s) and `tcpproxy: context deadline exceeded` timeout errors.
   - Extract faculty instructors and group members from [`Project.MM/doc/research/v2_MM_Lab_Project_Proposal_88_96_58.docx.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/doc/research/v2_MM_Lab_Project_Proposal_88_96_58.docx.pdf).
   - Add faculty details and project group details to [`Project.MM/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/README.md) alongside the GitHub repository URL (`https://github.com/b1tranger/Microprocessor_Assembly_Lab/tree/main/Project.MM`).
   - Add faculty details to the very top header of the LaTeX report source (`v4_MM_Lab_Final_Report(PresentationAid).tex` and `v4_MM_Lab_Final_Report.tex`) and recompile to PDF.

---

## 2. Code & Files Inspected / Modified
- [`Project.MM/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/README.md): Updated relative paths pointing to presentation guides and added academic details table + GitHub repo link.
- [`Project.MM/LocalConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md): Synchronized presentation path links.
- [`Project.MM/Presentation/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/PRESENTATION_GUIDE.md): Synchronized internal bridge document links.
- [`Project.MM/Presentation/v1_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v1_presentationBridge.md): Renamed from `presentationBridge.md`.
- [`Project.MM/Presentation/v2_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v2_presentationBridge.md): Created comprehensive <3-minute rapid presentation bridge and live demo protocol.
- [`Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex): New v4 IEEE conference paper source.
- [`Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex): Canonical version without PresentationAid suffix.
- [`Project.MM/LocalConfig/src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp): Optimized `streamSDFile()` with 2048-byte buffer, `setNoDelay(true)`, and watchdog-safe non-blocking yield.
- [`Project.MM/LocalConfig/data/www/fileserver.html`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/data/www/fileserver.html): Added auto-sync deferral on download click to eliminate connection contention.
- [`Project.MM/LocalConfig/include/default_assets.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/default_assets.h): Regenerated Flash ROM PROGMEM asset arrays.

---

## 3. Analysis & Key Insights

### 3.1 Presentation Time Constraint: Under 3 Minutes + 1--2 Minute Live Demo
- Normal speaking rate in academic English is 120--140 words per minute.
- A 3-minute hard ceiling leaves at most 360--400 total words across the entire group.
- Traditional slide presentations attempt to recite all bullet points on screen, leading to immediate overrun. The presentation bridge was redesigned around the **"Look, Point, Explain"** principle:
  - The slides present high-density visual architectures and benchmark numbers.
  - The speakers speak only high-impact synthesis sentences, directing the faculty's eyes to the screen rather than reading paragraphs.
- A dedicated 1--2 minute live demo section was planned to be initiated immediately following the final slide and prior to open evaluator questioning, asserting control over the evaluation narrative.

### 3.2 Slide Deck Optimization: Trimming, Merging & New Network Scenarios
- Analyzing `temp/v2.2_ESP32 Embedded NAS & Static Web Node.pdf` revealed redundancies:
  1. *Slide 4 ("Technical & Computational Feasibility")* and *Slide 5 ("Budget & Financial Feasibility")* overlapped significantly. Merging them into a single high-impact slide ("Engineering & Budgetary Feasibility") preserved the core technical metrics ($4 cost, <0.5W power, 520 KB SRAM vs 2 KB streaming) while saving 30--40 critical seconds.
  2. *Slide 3 ("Current Market Alternatives vs. Project.MM")* spent too much time reciting competing vendor specifications. It was condensed into an 8-second verbal takeaway with a clear comparison matrix.
  3. Integrated the **Rapid 3-Step Setup** (`wokwigw.exe` $\rightarrow$ VS Code Wokwi Play $\rightarrow$ Browser access on `:9080`) and the **4 Validated Network Simulation Scenarios** (Home Hybrid, Campus Lab Switch 2-PC LocalSend, Mobile Hotspot AP Isolation Bypass, All-Wireless).

### 3.3 Comprehensive LaTeX Report v4 Architecture
- Transitioned from `v3` to `v4` IEEE format (`IEEEtran.cls`, `conference_101719.tex` styling).
- Incorporated all architectural decisions:
  - Decoupled FreeRTOS dual-core operation (Core 0 networking vs Core 1 storage & server).
  - Hardware VSPI bus pin mapping avoiding strapping pins (GPIO 12 MTDI avoidance).
  - CMD24 single-sector write decomposition resolving simulation write-abort bugs.
  - Zero-overhead chunked multipart streaming parser maintaining 2 KB RAM overhead.
  - Flash ROM PROGMEM template fallback saving >300 KB volatile SRAM.
  - Dual-Network Layer-2/3 gateway bridging via `wokwigw.exe`.
  - Tri-Platform Architectural Comparison Matrix (Wokwi Local vs Wokwi Cloud vs Physical Hardware).
  - Evaluator Q&A Defense Quick-Reference.
  - Complete source code listings in Appendices D, E, and F with style truncation in HTML headers.

### 3.4 Layout Refinements: Column Containment, Line Wrapping & Diagonal Authors
1. **Table I Single-Column Containment**: Converted Table I from multi-column `table*` to single-column `table` with condensed column padding (`\tabcolsep=2.5pt`) and font resizing (`\scriptsize`), ensuring it stays strictly within the left column width without overflowing into the right column.
2. **Appendix E Font Link Overflow**: In Appendix E (and D), external stylesheet links were broken across multiple lines and listing break rules adjusted (`breakatwhitespace=false`) to ensure clean within-column wrapping.
3. **Restoring Diagonal Author Placement**: In standard `IEEEtran.cls` conference mode, 3 authors separated by `\and` default to a 2-column layout. By inserting explicit line breaks and horizontal spacing (`\and[\linebreak\hfill]` and `\and[\hfill\linebreak]`), the original diagonal cascade was restored: Jannatul Ferdus (top right), Gaus Saraf Murady (center), and Sadia Islam (bottom left).

### 3.5 Architecture Diagram Integration (Fig. 1)
- Integrated [`Project.MM/FinalReport/Diagram/4.2 Networking Bridge Architecture (Wokwi Gateway).png`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/Diagram/4.2%20Networking%20Bridge%20Architecture%20(Wokwi%20Gateway).png) directly into Section III-B ("Working Method & Execution Flow").
- Added `\usepackage{grffile}` to support filenames with spaces and dots.
- Scaled the figure cleanly (`width=0.58\columnwidth`) with caption and cross-reference label (`\label{fig:network_bridge}`), illustrating the host-to-simulation path: Chrome/Firefox $\rightarrow$ `0.0.0.0:9080` $\rightarrow$ `wokwigw.exe` $\rightarrow$ `ws://localhost:9011` $\rightarrow$ Wokwi Simulator $\rightarrow$ ESP32 on `10.13.37.2:80`.

### 3.6 Download Speed Optimization & TCP Proxy Timeout Resolution
- **Problem Diagnosis**: During file downloads, transfer speed degraded below 1 KB/s accompanied by recurring `wokwigw.exe` errors: `tcpproxy: for incoming conn ..., error dialing "10.13.37.2:80": context deadline exceeded`.
- **Root Cause Analysis**:
  1. *Per-Chunk Sleep Latency*: In `streamSDFile()`, an unconditional `vTaskDelay(1)` was executed after every single 1024-byte read, translating to 50--200~ms of wall-clock time per chunk in Wokwi's instruction emulator.
  2. *Nagle's Algorithm & Delayed ACKs*: Without `client.setNoDelay(true)`, sub-MSS chunks caused lwIP to pause waiting for delayed client ACKs (200~ms TCP timer).
  3. *Synchronous WebServer Head-of-Line Blocking*: The ESP32 `WebServer` processes requests synchronously on Core 1. While locked in the slow download loop, `server.handleClient()` could not accept incoming connections. Parallel browser connections (e.g. background `/api/files` auto-sync) filled the tiny lwIP listen backlog until `wokwigw.exe`'s 2-second dial timeout expired.
- **Implemented Fix**:
  - Expanded the hardware streaming buffer to 2,048 bytes (`file.setBufferSize(2048)`).
  - Explicitly enabled `client.setNoDelay(true)` to bypass Nagle delays.
  - Replaced the per-chunk `vTaskDelay(1)` with non-blocking `taskYIELD()`, reserving `vTaskDelay(1)` for once every 8 chunks (16~KB) to feed the FreeRTOS Task Watchdog Timer.
  - Added download auto-sync deferral in `fileserver.html` to push back background `/api/files` polling by 20 seconds when `.btn-dl` is clicked.

### 3.7 Academic Metadata, Faculty Details & Group Details Integration
- **Cover Page Details Extracted**: Extracted from [`Project.MM/doc/research/v2_MM_Lab_Project_Proposal_88_96_58.docx.pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/doc/research/v2_MM_Lab_Project_Proposal_88_96_58.docx.pdf):
  - *Course*: `CSE0611324` -- Microprocessors, Microcontrollers and Assembly Language Lab
  - *Department & University*: Department of Computer Science & Engineering (CSE), University of Information Technology and Sciences (UITS)
  - *Course Instructors / Evaluators*: Tahmina Yeasmin Lima (Lecturer) and Abrar Mahbub Tanim (Lecturer)
  - *Submitted By*: Jannatul Ferdus (ID: `0432410005101058`), Gaus Saraf Murady (ID: `0432410005101088`), Sadia Islam (ID: `0432410005101096`), Autumn 2026.
- **Header Placement Strategy in IEEEtran**:
  Rather than crowding the author block or breaking the diagonal author layout, the faculty evaluators and department affiliation were cleanly embedded directly inside the `\title{...}` subtitle block using `{\footnotesize ...}` styling. This ensures the title block acts as the comprehensive academic header on Page 1 while preserving the diagonal cascade of student authors below it.

---

## 4. Final Solution & Outcomes

### 4.1 Path Updates for Moved Presentation Documents
All file links across the repository were audited and updated to reflect the new `Project.MM/Presentation/` directory:
- [`Project.MM/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/README.md) lines 25--35 and 150--155.
- [`Project.MM/LocalConfig/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/README.md) line 155.
- [`Project.MM/Presentation/PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/PRESENTATION_GUIDE.md) lines 4 and 1087.
- [`Project.MM/Presentation/v1_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v1_presentationBridge.md) line 7.

### 4.2 Presentation Bridge v1 Rename & Presentation Bridge v2 Creation
- `presentationBridge.md` was renamed to [`Project.MM/Presentation/v1_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v1_presentationBridge.md) to preserve the original 10-minute speech script.
- Created [`Project.MM/Presentation/v2_presentationBridge.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/v2_presentationBridge.md) featuring:
  - Exact time budget breakdown (< 3 minutes slide presentation + 1--2 minutes live file server demo).
  - Detailed Slide Deck Audit analyzing each slide from `v2.2_ESP32 Embedded NAS & Static Web Node.pdf`.
  - Slide-by-slide layout blueprints and copy for the streamlined 7-slide deck (featuring the updated **minimalist industrial dark-theme** UI design description matching `fileserver.html` and `index.html`).
  - Non-native English delivery strategy with short Subject + Verb + Object structures and "Look, Point, Explain" cues.
  - Complete, word-counted spoken scripts for Speaker 1 (0:00--0:50), Speaker 2 (0:50--1:50), and Speaker 3 (1:50--2:45).
  - Action-by-action 1--2 minute live demo script covering dashboard inspection, live file upload, static `/site` showcase, download, delete, and multi-device LAN file sharing (LocalSend Web model).
  - Evaluator Q&A defense table addressing top faculty grilling questions.

### 4.3 Authoring & Verified Compilation of Report v4
- Created [`Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex) and canonical [`Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex).
- Resolved table column overflow, code listing margins, and restored diagonal author placement.
- Added Appendix C ("Repository Architecture & Component Responsibilities") embedding the full directory tree from Section 2.1 of [`PRESENTATION_GUIDE.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/Presentation/PRESENTATION_GUIDE.md) with `literate` character support for tree symbols.
- Shifted subsequent appendices to Appendix D (`main.cpp`), Appendix E (`fileserver.html`), and Appendix F (`index.html`).
- Implemented literate sanitization mapping for Unicode symbols in HTML listings to guarantee 100\% cross-compiler compatibility.

### 4.4 Academic Cover Details & Faculty Title Integration in LaTeX & README
- Added Course Instructors table, Submitted By (Project Group) table, Course Code (`CSE0611324`), Institution (UITS), and direct GitHub repository link (`https://github.com/b1tranger/Microprocessor_Assembly_Lab/tree/main/Project.MM`) to [`Project.MM/README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/README.md).
- Integrated faculty instructors (`Tahmina Yeasmin Lima` and `Abrar Mahbub Tanim`) and institutional affiliation into the `\title{...}` subtitle block of `v4_MM_Lab_Final_Report(PresentationAid).tex` and `v4_MM_Lab_Final_Report.tex`.
- Compiled both LaTeX sources using MiKTeX `pdflatex`:
  ```cmd
  cd Project.MM\FinalReport
  pdflatex -interaction=nonstopmode "v4_MM_Lab_Final_Report(PresentationAid).tex"
  pdflatex -interaction=nonstopmode "v4_MM_Lab_Final_Report.tex"
  ```
- **Compilation Result**: Both PDFs compiled cleanly into 12 pages with zero overflow and pristine diagonal author layout.

### 4.5 Verification & Artifact Deliverables
All deliverables have been verified on disk and cross-linked with mandatory clickable Tables of Contents and GitHub repository links:
1. `doc/prompts/19. ESP32 NAS Presentation Bridge v2 and LaTeX Report v4/transcript_full.jsonl`
2. `doc/prompts/19. ESP32 NAS Presentation Bridge v2 and LaTeX Report v4/conversation.md`
3. `doc/prompts/19. ESP32 NAS Presentation Bridge v2 and LaTeX Report v4/summary.md`
4. `Project.MM/Presentation/v1_presentationBridge.md`
5. `Project.MM/Presentation/v2_presentationBridge.md`
6. `Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).tex`
7. `Project.MM/FinalReport/v4_MM_Lab_Final_Report(PresentationAid).pdf`
8. `Project.MM/FinalReport/v4_MM_Lab_Final_Report.tex`
9. `Project.MM/FinalReport/v4_MM_Lab_Final_Report.pdf`
10. `Project.MM/README.md`
