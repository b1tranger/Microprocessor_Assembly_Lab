# 18. LaTeX Workspace Setup and Realtime TeX Configuration

- **Conversation ID**: `67bebf5f-8513-4f90-a49e-42475fac2f74`
- **Timestamp**: `2026-11-14T11:33:02+06:00`
- **Model**: `Gemini 3.8 Flash`
- **Target Files & Repositories**:
  - Report: [`Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).tex)
  - Generated Report PDF: [`Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).pdf)
  - Workspace Settings: [`.vscode/settings.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/.vscode/settings.json)
  - One-Click Setup Suite: [`windows-miktex-installer/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer)

---

## Table of Contents
- [1. User Request Summary](#1-user-request-summary)
- [2. Inspected Artifacts & Environment Diagnostics](#2-inspected-artifacts--environment-diagnostics)
- [3. Analysis & Key Insights (Root Cause Investigation)](#3-analysis--key-insights-root-cause-investigation)
  - [3.1 The Architecture of `henryxiaoyang.realtime-tex` and `rtex`](#31-the-architecture-of-henryxiaoyangrealtime-tex-and-rtex)
  - [3.2 Verification via `rtex doctor`](#32-verification-via-rtex-doctor)
  - [3.3 The Missing System Component: LuaLaTeX](#33-the-missing-system-component-lualatex)
- [4. Implementation: Standalone `windows-miktex-installer` Repository](#4-implementation-standalone-windows-miktex-installer-repository)
  - [4.1 Architecture & Component Design](#41-architecture--component-design)
  - [4.2 Dual-Strategy Installation Logic (`winget` + CTAN Fallback)](#42-dual-strategy-installation-logic-winget--ctan-fallback)
  - [4.3 Zero-Prompt Package Configuration (`[MPM]AutoInstall=1`)](#43-zero-prompt-package-configuration-mpmautoinstall1)
- [5. Troubleshooting: Launcher Premature Exit & Stale Process PATH](#5-troubleshooting-launcher-premature-exit--stale-process-path)
  - [5.1 The Window Closing Issue in `install.bat`](#51-the-window-closing-issue-in-installbat)
  - [5.2 CMD Title Command Splitting (`&` character)](#52-cmd-title-command-splitting--character)
  - [5.3 Process Environment Inheritance & Stale PATH Resolution](#53-process-environment-inheritance--stale-path-resolution)
  - [5.4 Interactive vs. Redirected Console Stdin Handling](#54-interactive-vs-redirected-console-stdin-handling)
- [6. Resolving Editor Process Environment Stagnation (`realtimeTex.texliveBin`)](#6-resolving-editor-process-environment-stagnation-realtimetextexlivebin)
  - [6.1 The Active IDE Environment Gap](#61-the-active-ide-environment-gap)
  - [6.2 Explicit Configuration Injection](#62-explicit-configuration-injection)
  - [6.3 Installer Automation Enhancement](#63-installer-automation-enhancement)
- [7. Verification & End-to-End Report Compilation](#7-verification--end-to-end-report-compilation)
  - [7.1 Health Check Suite (`verify.bat` / `verify.ps1`)](#71-health-check-suite-verifybat--verifyps1)
  - [7.2 Realtime TeX Integration (`rtex doctor`)](#72-realtime-tex-integration-rtex-doctor)
  - [7.3 Final Report PDF Generation](#73-final-report-pdf-generation)

---

## 1. User Request Summary
1. **Initial Issue**: The user requested preparing LaTeX rendering in the workspace to edit and preview the project final report located at [`Project.MM/FinalReport/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport). When previewing with the extension `henryxiaoyang.realtime-tex`, the live preview crashed with `lualatex not found on PATH`.
2. **Setup Automation Request**: Implement a standalone one-click installer for **Option 2 (MiKTeX & LuaLaTeX automated system installation)** at the project root (`windows-miktex-installer/`).
3. **Execution Blocker**: The user reported that [`install.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/install.bat) closed immediately and [`verify.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/verify.bat) reported `LuaLaTeX Binary - Not found on PATH`.
4. **Editor Persistence Blocker**: After MiKTeX installed successfully, pressing `Ctrl + Alt + V` in the editor still showed:
   ```text
   The engine stopped
   LuaLaTeX was not found. Install TeX Live 2026 (or newer), or set "Realtime TeX: Texlive Bin" to the folder that contains lualatex.
   ```

---

## 2. Inspected Artifacts & Environment Diagnostics
1. **Target Report Directory**:
   - [`Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).tex)
   - [`Project.MM/FinalReport/conference_101719.tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/conference_101719.tex)
   - [`Project.MM/FinalReport/IEEEtran.cls`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/IEEEtran.cls)
   - [`Project.MM/FinalReport/fig1.png`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/fig1.png)
2. **IDE Extension State**:
   - `henryxiaoyang.realtime-tex-0.0.5-universal` installed in `C:\Users\gsmur\.antigravity-ide\extensions\`.
   - The compiled engine `rtex.exe` (v0.0.7) in `C:\Users\gsmur\AppData\Roaming\Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe`.
3. **Installed Compiler State**:
   - MiKTeX 25.12 installed at `C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64\`.
   - `lualatex.exe`, `pdflatex.exe`, `xelatex.exe`, `initexmf.exe` all active and verified.

---

## 3. Analysis & Key Insights (Root Cause Investigation)

### 3.1 The Architecture of `henryxiaoyang.realtime-tex` and `rtex`
`realtime-tex` (`rtex`) provides millisecond-level live LaTeX rendering by keeping a warm, persistent **LuaLaTeX** process alive in the background with the document preamble pre-loaded. When the author edits text, `rtex` does not recompile the entire document; instead, it re-typesets *only* the specific paragraph currently being edited in ~1 millisecond using LuaLaTeX callbacks.

However, **`rtex` is only an orchestration daemon and bridge**—it does not bundle the TeX compiler binaries, macro packages, or fonts itself. It strictly delegates all compilation passes to `lualatex`.

### 3.2 Verification via `rtex doctor`
Directly invoking the bundled diagnostic tool revealed the exact failure point:
```powershell
& "C:\Users\gsmur\AppData\Roaming\Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe" doctor
```
**Diagnostic Output:**
```text
rtex 0.0.7
support files: C:\Users\gsmur\AppData\Roaming\Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\share\rtex\tex
lualatex: missing (lualatex not found on PATH (source build/texlive.env or set RTEX_TEXLIVE_BIN))
```

### 3.3 The Missing System Component: LuaLaTeX
Because the host machine lacked a TeX distribution (TeX Live or MiKTeX), `rtex` failed to spawn the compiler process when initiating the live preview panel.

---

## 4. Implementation: Standalone `windows-miktex-installer` Repository

A self-contained repository was created under [`windows-miktex-installer/`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer).

### 4.1 Architecture & Component Design
- **[`install.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/install.bat)**: Double-clickable batch launcher for Windows Explorer. Handles elevation detection and passes execution to PowerShell with `-ExecutionPolicy Bypass`.
- **[`install.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/install.ps1)**: Core automation script featuring colored logging, idempotency checks, dual installation backends, binary path resolution, and editor integration testing.
- **[`verify.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/verify.bat)** & **[`verify.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/verify.ps1)**: Non-destructive health check tool verifying binary detection, on-the-fly download configuration, sample LaTeX compilation, and `rtex doctor` status.
- **[`test/sample.tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/test/sample.tex)**: Multi-package test document using `amsmath`, `listings`, and `booktabs` to validate automated package fetching.
- **[`README.md`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/README.md)**: Full GitHub documentation with architecture diagrams, parameters, usage guides, and troubleshooting tips.
- **[`LICENSE`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/LICENSE)**: Standard MIT License.
- **[`.gitignore`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/.gitignore)**: Clean ignore rules for temporary installer executables, logs, and LaTeX auxiliary files.

### 4.2 Dual-Strategy Installation Logic (`winget` + CTAN Fallback)
The installer implements an automatic fallback mechanism:
1. **Primary Backend (`winget`)**:
   ```powershell
   winget install --id MiKTeX.MiKTeX -e --accept-source-agreements --accept-package-agreements
   ```
2. **Fallback Backend (Direct CTAN Download)**:
   If `winget` is unavailable or restricted, the script downloads:
   `https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-25.12-x64.exe`
   And executes it silently:
   ```cmd
   basic-miktex-setup-x64.exe --unattended --auto-install=yes --paper-size=A4
   ```

### 4.3 Zero-Prompt Package Configuration (`[MPM]AutoInstall=1`)
To eliminate intrusive GUI popups during compilation:
1. Discovers the installed binary path (`C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64`).
2. Configures the MiKTeX Package Manager:
   ```cmd
   initexmf.exe --set-config-value [MPM]AutoInstall=1
   initexmf.exe --update-fndb
   ```
3. Injects the binary directory into the current process `$env:PATH` and permanently persists it to `[EnvironmentVariableTarget]::User`.

---

## 5. Troubleshooting: Launcher Premature Exit & Stale Process PATH

### 5.1 The Window Closing Issue in `install.bat`
`install.bat` originally lacked a trailing pause on successful exit code `0`, causing File Explorer to instantly close the window upon completion. Added a mandatory `pause`.

### 5.2 CMD Title Command Splitting (`&` character)
`title MiKTeX & LuaLaTeX...` caused cmd.exe to treat `&` as a command separator, throwing `'LuaLaTeX' is not recognized`. Replaced with `title MiKTeX and LuaLaTeX...`.

### 5.3 Process Environment Inheritance & Stale PATH Resolution
Windows processes inherit environment variables at creation time. Existing terminal windows retain their pre-installation `PATH`. `verify.ps1` was enhanced to dynamically read `User` and `Machine` PATH from the Windows registry.

### 5.4 Interactive vs. Redirected Console Stdin Handling
`[Console]::ReadKey($true)` was guarded with `try { ... } catch {}` to prevent `InvalidOperationException` in non-interactive pipes.

---

## 6. Resolving Editor Process Environment Stagnation (`realtimeTex.texliveBin`)

### 6.1 The Active IDE Environment Gap
Because Antigravity IDE was open while MiKTeX was installed, its internal Node.js extension host process retained the original, pre-installation `process.env.PATH`. Therefore, pressing `Ctrl + Alt + V` spawned `rtex.exe` with the old PATH, causing `lualatex not found`.

### 6.2 Explicit Configuration Injection
Rather than requiring a full system reboot or IDE restart, the extension explicitly supports overriding the binary search via the setting:
`"realtimeTex.texliveBin": "C:\\Users\\gsmur\\AppData\\Local\\Programs\\MiKTeX\\miktex\\bin\\x64"`

This was configured directly in:
1. **User Settings**: `C:\Users\gsmur\AppData\Roaming\Antigravity IDE\User\settings.json`
2. **Workspace Settings**: [`.vscode/settings.json`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/.vscode/settings.json)

### 6.3 Installer Automation Enhancement
[`windows-miktex-installer/install.ps1`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/install.ps1) was enhanced to automatically inject `realtimeTex.texliveBin` into both `%APPDATA%\Antigravity IDE\User\settings.json` and `%APPDATA%\Code\User\settings.json` upon installation completion.

---

## 7. Verification & End-to-End Report Compilation

### 7.1 Health Check Suite (`verify.bat` / `verify.ps1`)
Running [`verify.bat`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/windows-miktex-installer/verify.bat) yields 100% green checks across all components:
```text
==========================================================
      MiKTeX & LuaLaTeX Environment Diagnostic Check       
==========================================================

 [PASS] LuaLaTeX Binary (C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64\lualatex.exe)
 [PASS] pdfLaTeX Binary (C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64\pdflatex.exe)
 [PASS] XeLaTeX Binary (C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe)
 [PASS] MiKTeX Maintenance Utility (initexmf) (C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64\initexmf.exe)
 [PASS] On-the-fly package download enabled (Value: 1)

--> Testing LuaLaTeX Document Compilation...
 [PASS] LuaLaTeX Sample Compilation (test.tex -> test.pdf) (PDF generated successfully)

--> Testing Realtime TeX (rtex) Engine...
 [PASS] rtex doctor status (Engine at: C:\Users\gsmur\AppData\Roaming\Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\bin\rtex.exe)

==========================================================
 System is ready for LaTeX authoring and real-time preview!
==========================================================
```

### 7.2 Realtime TeX Integration (`rtex doctor`)
The `rtex` engine binds to LuaLaTeX:
```text
rtex 0.0.7
support files: C:\Users\gsmur\AppData\Roaming\Antigravity IDE\User\globalStorage\henryxiaoyang.realtime-tex\rtex-release\v0.0.7\share\rtex\tex
lualatex: C:\Users\gsmur\AppData\Local\Programs\MiKTeX\miktex\bin\x64\lualatex.exe (This is LuaHBTeX, Version 1.24.0 (MiKTeX 25.12))
```

### 7.3 Final Report PDF Generation
The complete course project final report was compiled from source:
- **Source**: [`Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).tex`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).tex)
- **Output Artifact**: [`Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).pdf`](https://github.com/b1tranger/Microprocessor_Assembly_Lab/blob/main/Project.MM/FinalReport/v2_MM_Lab_Final_Report(PresentationAid).pdf) (3 pages, 109,276 bytes, formatted per IEEEtran specifications).
