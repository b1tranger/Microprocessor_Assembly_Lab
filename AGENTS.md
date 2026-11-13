# Agent Guidelines: Microprocessor & Assembly Theory Documentation

## Table of Contents
1. [Purpose](#purpose)
2. [Theory Note Generation & Update Rules](#theory-note-generation--update-rules)
   - [1. Lab Code Theory Notes (`LabCodes/Learning/`)](#1-lab-code-theory-notes-labcodeslearning)
   - [2. Conceptual & Topic Notes (`doc/note/`)](#2-conceptual--topic-notes-docnote)
   - [3. Automatic Updates](#3-automatic-updates)
   - [4. Mandatory Table of Contents (TOC)](#4-mandatory-table-of-contents-toc)
   - [5. GitHub Repository Link Prefix for File References](#5-github-repository-link-prefix-for-file-references)
3. [Content & Formatting Standards](#content--formatting-standards)
4. [Conversation & Prompt Archiving Guidelines (`doc/prompts/`)](#4-conversation--prompt-archiving-guidelines-docprompts)
   - [1. Destination & Serial Folder Naming](#1-destination--serial-folder-naming)
   - [2. Required Files Inside Each Session Folder](#2-required-files-inside-each-session-folder)
   - [3. Summary Markdown Format (`summary.md`)](#3-summary-markdown-format-summarymd)
   - [4. Update Cadence (Keeping the Archive Current)](#4-update-cadence-keeping-the-archive-current)
5. [Embedded Systems & Project.MM (ESP32 NAS / Web Node) Guidelines](#5-embedded-systems--projectmm-esp32-nas--web-node-guidelines)
   - [1. Role & Engineering Persona](#1-role--engineering-persona)
   - [2. Hardware & Simulation Architecture](#2-hardware--simulation-architecture)
   - [3. Firmware & Memory Management Constraints](#3-firmware--memory-management-constraints)
   - [4. Dual-Network Local Gateway & Routing Standards](#4-dual-network-local-gateway--routing-standards)

---

## Purpose
This document provides instructions for automatically documenting assembly theory notes and archiving chat/prompt interactions whenever code files in this repository are discussed, debugged, or analyzed.

---

## Theory Note Generation & Update Rules

### 1. Lab Code Theory Notes (`LabCodes/Learning/`)
* **Target Directory**: `LabCodes/Learning/`
* **Naming Convention**: Use the base name of the assembly file being discussed, followed by `-theory.md`.
  - Example: `5.1.asm` $\rightarrow$ `LabCodes/Learning/5.1-theory.md`
  - Example: `A4.asm` $\rightarrow$ `LabCodes/Learning/A4-theory.md`
  - Example: `6.asm` $\rightarrow$ `LabCodes/Learning/6-theory.md`

### 2. Conceptual & Topic Notes (`doc/note/`)
* **Target Directory**: `doc/note/`
* **Modular Single-Topic Structure**: Instead of bundling multiple unrelated topics into a single monolithic document (such as the legacy `sample.md`), each concept must have its own dedicated markdown file.
* **Sequential Numbering & Descriptive Naming**: Files must be named according to their contents summarized in a few words, prefixed with a sequence number reflecting the logical learning progression:
  - Format: `<SequenceNumber>.<Topic Name Summarized in a Few Words>.md`
  - Example: `1.The Foundation CPU Execution and Decoupled FLAGS Model.md`
  - Example: `2.Variables and Assignment.md`
  - Example: `8.Loops While Do-While and For.md`
  - Example: `12.Complete 8086 Jump Instructions Reference.md`
* **Dynamic File Name Updates**: File names must be kept synchronized with their content and updated whenever the scope or topics covered in the file evolve.
* **High-Yield Reference (`0.mustKnows.md`)**: A dedicated cheat sheet, `doc/note/0.mustKnows.md`, must be maintained to aggregate critical traps, hardware constraints (e.g. shift counts requiring `CL`, ALU instructions not needing `INT 21h`), register hygiene (`mov al, 0`), program termination (`mov ah, 4ch`), and ASCII representation modes (`'0'` / `48` / `30h`).

### 3. Automatic Updates
* Whenever new concepts, questions, clarifications, or code improvements regarding a specific assembly file are discussed in the chat, immediately create or update its corresponding `<filename>-theory.md` file.
* Ensure existing content is preserved while integrating new explanations, diagrams, and code snippets.

### 4. Mandatory Table of Contents (TOC)
* **Every theory and documentation file added or modified** (e.g. `doc/note/*.md`, `LabCodes/Learning/<file>-theory.md`, `doc/prompts/*.md`) **MUST include a clickable Table of Contents at the top**, positioned immediately after the introductory summary block.
* The Table of Contents must:
  - List all primary (`##`) and secondary (`###`) sections using GitHub Flavored Markdown anchor links (e.g. `[Title](#anchor-link)`).
  - Be kept in sync and automatically updated whenever new sections are added or revised.

### 5. GitHub Repository Link Prefix for File References
* **Repository-Relative Web URLs**: All repository file references, source code links, and cross-file links in documentation and theory notes (`.md` files) must use absolute GitHub repository URLs rather than local paths (`./path` or `file:///...`).
* **Base URL Format**: `https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/<path-from-repo-root>`
  - Example: [`1.1.asm`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/lab-1/1.1.asm)
  - Example with line numbers: [`shl_Semim.asm#L74-L81`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/LabCodes/Labtest/prep/shl_Semim.asm#L74-L81)

---

## Content & Formatting Standards

Follow the format, depth, and presentation demonstrated in `doc/note/0.mustKnows.md`, `LabCodes/Learning/A4-theory.md`, and `LabCodes/Learning/6-theory.md`:

1. **Clear Architectural & Hardware Explanations**:
   - Explain what the 8086 CPU and registers (`AX`, `BX`, `CX`, `DX`, `SP`, `BP`, `SI`, `DI`, `IP`, `FLAGS`) are doing under the hood.
   - Clarify the stack operations (`PUSH`, `POP`, `CALL`, `RET`) and memory segmentation.

2. **Procedures, Control Flow & Directives**:
   - Differentiate between assembler directives (`PROC`, `ENDP`, `.MODEL`, `.DATA`, `.CODE`) and CPU machine instructions.
   - Clarify jumps (`JMP`, conditional jumps like `JE`, `JNE`, `JB`, `JBE`, `JA`, `JAE`) vs. subroutine calls (`CALL` / `RET`).

3. **Comparative Analysis & Visuals**:
   - Include comparison tables (e.g., `CALL` vs `JMP`, register aliasing mappings, Jump summary tables).
   - Use ASCII register/stack diagrams where helpful.
   - Provide equivalent High-Level Language (C/C++) snippets to bridge understanding.

4. **Step-by-Step Code Traces & Mathematics**:
   - Detail numerical conversions (e.g., ASCII/Hex conversion math `+48` vs `+7`, BCD, bitwise shifts/masks).
   - Trace register states line by line for complex logic.

5. **Pitfalls & Best Practices**:
   - Highlight common bugs (e.g., uninitialized `AH` before `DIV`, missing `RET`, stack imbalance, flag clobbering).

---

## 4. Conversation & Prompt Archiving Guidelines (`doc/prompts/`)

To preserve context, prompts, debugging transcripts, and internal reasoning verbatim across sessions, follow these archiving procedures:

### 1. Destination & Serial Folder Naming
* **Directory**: `doc/prompts/`
* **Serial Session Folder Convention**: `doc/prompts/<N>. <Session Title>/`
  - Example: `doc/prompts/14. Debugging Assembly Nibble Conversion/`
* **Determining `<N>`**: Inspect `doc/prompts/` to find the highest existing major integer prefix across both existing session folders and legacy flat `<N>. ...md` files, and assign `N = N_max + 1` for a new conversation session.
* **Session Continuity**: Always update **the same session folder** across turns or when resuming an existing conversation; do NOT create a new major folder per turn.

### 2. Required Files Inside Each Session Folder
Inside `doc/prompts/<N>. <Session Title>/`:
1. **`transcript_full.jsonl`**: An exact, unmodified UTF-8 copy of `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript_full.jsonl`. Never truncate, edit, or reformat lines in `transcript_full.jsonl`.
2. **`conversation.md`**: A verbatim Markdown rendering generated directly from `transcript_full.jsonl`, including **every step exactly** without summarizing or omitting content: metadata (`Conversation ID`, `Session Folder`, `Continued From` if applicable), all `USER_INPUT.content`, all `PLANNER_RESPONSE.thinking` verbatim, all `PLANNER_RESPONSE.tool_calls` and tool/system outputs (`GENERIC` / `SYSTEM_MESSAGE`), and all `PLANNER_RESPONSE.content` verbatim.
3. **`summary.md` (Conversation Summary Markdown)**: Maintained alongside `transcript_full.jsonl` and `conversation.md` in the same folder (including a clickable Table of Contents at the top and GitHub repository blob links per Section 5 above).
4. **Companion Plans & Walkthroughs (Optional, Fractional Suffixes)**: Stored in the same folder as `<N>.1 Implementation Plan - <Plan Title>.md` and `<N>.2 Walkthrough - <Title>.md` if generated.

### 3. Summary Markdown Format (`summary.md`)
Include a clickable Table of Contents, session metadata, and concise structured sections:
```markdown
# <N>. <Session Title>

- **Conversation ID**: `<conversation-id>`
- **Timestamp**: `<YYYY-MM-DDTHH:MM:SS+Offset>`
- **Model**: `<Model Name>`
- **Target File**: [`<filename>`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/path/to/file)

## 1. User Request Summary
## 2. Code Inspected / Modified
## 3. Analysis & Key Insights
## 4. Final Solution & Outcomes
```

### 4. Update Cadence (Keeping the Archive Current)
Because the runtime writes a turn's final `PLANNER_RESPONSE` (final `thinking` and `content`) to `transcript_full.jsonl` after the turn finishes:
1. **At the start of each turn (or when continuing from a prior `<conversation-id>`):** Copy `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript_full.jsonl` to `doc/prompts/<N>. <Session Title>/transcript_full.jsonl` and regenerate `conversation.md` so the previous turn's finalized `thinking` and `content` are captured verbatim (and sync the prior conversation's folder if continuing).
2. **Before sending each new final response:** Re-copy `transcript_full.jsonl`, regenerate `conversation.md` to capture all completed steps of the current turn, append the exact final response under `## Pending Final Response (Pre-Commit)` (noting it will be replaced verbatim from `transcript_full.jsonl` on the next sync), and create or update `summary.md` in the same folder.

---

## 5. Embedded Systems & Project.MM (ESP32 NAS / Web Node) Guidelines

### 1. Role & Engineering Persona
When collaborating on [`Project.MM`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM) and [`Project.MM/LocalConfig`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig), act as an expert embedded systems and full-stack IoT engineer for "Project.MM", an ESP32-based Embedded Network Attached Storage (NAS) and Static Web Hosting Node designed for microprocessor laboratory evaluations (`CSE0611324`).

### 2. Hardware & Simulation Architecture
* **Target Hardware**: Classic ESP32 DevKit V1 (Xtensa Dual-Core LX6 @ 240 MHz).
* **Storage Interface**: Hardware VSPI bus mapped to a MicroSD card module formatted with FAT32:
  - `GPIO 5`: Chip Select (`CS`)
  - `GPIO 18`: Serial Clock (`SCK`)
  - `GPIO 23`: Master Out Slave In (`MOSI` / `DI`)
  - `GPIO 19`: Master In Slave Out (`MISO` / `DO`)
* **Simulation Environment**: Local execution via PlatformIO and Wokwi extension in VS Code.

### 3. Firmware & Memory Management Constraints
* **Framework**: Native Arduino ESP32 core (`WebServer.h`, `SD.h`, `SPI.h`, `WiFi.h`).
* **Modular Structure**: Split cleanly into [`include/html_templates.h`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/include/html_templates.h) (glassmorphic dark UI, CSS gradients, landing page templates stored in Flash ROM via `PROGMEM` and streamed via `FPSTR`) and [`src/main.cpp`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/LocalConfig/src/main.cpp).
* **Streaming Memory Budget**: Streaming multipart upload parser (`server.upload()`) and chunked file downloads (`server.streamFile()`) must ensure a fixed ~2 KB RAM overhead regardless of file size.
* **Dual-Core FreeRTOS Separation**:
  - `Core 0`: Dedicated to networking and lwIP protocol stack handling.
  - `Core 1`: Dedicated to application loop, background tasks, and diagnostic tests via `xTaskCreatePinnedToCore`.

### 4. Dual-Network Local Gateway & Routing Standards
* **Gateway Binary**: Uses local open-source gateway `wokwigw.exe --forward 9080:10.13.37.2:80`.
* **Multi-Interface Access**: The gateway binds to `0.0.0.0:9080`, simultaneously supporting:
  - Wired Ethernet LAN devices (lab PCs on the campus network).
  - Wireless Windows Mobile Hotspot devices (smartphones, tablets, external laptops).
* **Engineering Principles**: Maintain strict adherence to modular C++ practices, low memory overhead, and robust embedded engineering principles.
