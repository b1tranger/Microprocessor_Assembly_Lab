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
   - [1. Destination & Naming](#1-destination--naming)
   - [2. Session Metadata Header](#2-session-metadata-header)
   - [3. Standard Archive Structure](#3-standard-archive-structure)
   - [4. Automatic Archiving Trigger](#4-automatic-archiving-trigger)

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

To preserve context, prompts, debugging transcripts, and reasoning paths across sessions, follow these archiving procedures:

### 1. Destination & Naming
* **Directory**: `doc/prompts/`
* **Naming Convention**: Numbered, topic-based markdown files (e.g., `1.Debugging Assembly Nibble Conversion.md`, `2.Control Flow and Character Classification.md`).
* Sequential conversations regarding related problems or files should be compiled under the same topic file as sequential `# Part N:` entries.

### 2. Session Metadata Header
Each archived session entry must begin with structured metadata:
```markdown
# Part N: <Topic Description> (<Target File>)

- **Conversation ID**: `<conversation-id>`
- **Timestamp**: `<YYYY-MM-DDTHH:MM:SS+Offset>`
- **Model**: `<Model Name>`
- **Target File**: [`<filename>`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/path/to/file)
```

### 3. Standard Archive Structure
Each entry must contain the following core sections:

1. **`## 1. User Request`**:
   - Exact user prompt quoted in a code block.
   - Metadata snippet (active document, cursor line).
2. **`## 2. Code Inspected / Modified`**:
   - The relevant code snippets or diff blocks from the assembly file under review.
3. **`## 3. Analysis & Key Insights`**:
   - Core explanation, register/flag mechanics, bug discovery, or theoretical breakdown.
4. **`## 4. Final Solution & Output`**:
   - Resulting assembly code, procedure updates, or verification notes.

### 4. Automatic Archiving Trigger
* When a debugging sequence, major code improvement, or multi-turn conceptual explanation concludes, archive the interaction into `doc/prompts/` following the above structure.

