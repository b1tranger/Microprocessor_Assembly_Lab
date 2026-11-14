# Windows MiKTeX & LuaLaTeX One-Click Automated Setup

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20(x64)-blue.svg)](#)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%7C%207+-darkblue.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Engine](https://img.shields.io/badge/LaTeX-LuaLaTeX%20%7C%20pdfLaTeX%20%7C%20XeLaTeX-purple.svg)](#)

A zero-touch, automated one-click installer and environment configurator for **MiKTeX**, **LuaLaTeX**, and **pdfLaTeX** on Windows. 

Designed specifically to bootstrap LaTeX rendering for **Antigravity IDE**, **Visual Studio Code** (including [Realtime TeX (`henryxiaoyang.realtime-tex`)](https://github.com/HenryXiaoYang/realtime-tex) and [LaTeX Workshop (`James-Yu.latex-workshop`)](https://github.com/James-Yu/LaTeX-Workshop)), and standalone command-line LaTeX authoring.

---

## Table of Contents
- [The Problem Solved](#the-problem-solved)
- [Key Features](#key-features)
- [Directory Structure](#directory-structure)
- [Quick Start](#quick-start)
- [CLI Usage & Parameters](#cli-usage--parameters)
- [Environment Verification](#environment-verification)
- [How It Works Under the Hood](#how-it-works-under-the-hood)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [License](#license)

---

## The Problem Solved

Modern VS Code extensions such as **Realtime TeX (`rtex`)** provide sub-millisecond, incremental LaTeX previewing as you type, but they depend on an unmodified system `lualatex` binary. When developers open LaTeX files without a pre-installed TeX distribution, they encounter the classic blocker:

```text
Error: lualatex not found on PATH (source build/texlive.env or set RTEX_TEXLIVE_BIN)
Caused by:
    lualatex not found
```

Manual installation often requires navigating installer wizards, configuring environment variables, and dealing with missing package errors when compiling documents that use `amsmath`, `listings`, or `IEEEtran`.

This repository provides an automated, idempotent one-click installer that sets up MiKTeX silently, enables automatic on-the-fly package fetching, updates your environment variables, and verifies that `rtex` and your editors detect the engine immediately.

---

## Key Features

- **One-Click Execution**: Simply double-click `install.bat` from File Explorer—no manual prompts required.
- **Dual Installation Strategy**:
  1. **Primary**: Fast installation using Windows Package Manager (`winget`).
  2. **Automated Fallback**: Direct high-speed download of the official Basic MiKTeX installer from CTAN mirrors with resume logic if `winget` is unavailable or restricted.
- **On-the-Fly Package Installation Preconfigured**: Enables `[MPM]AutoInstall=1` and refreshes the filename database (`fndb`), meaning any missing CTAN package (`IEEEtran`, `listings`, `booktabs`, `xcolor`, etc.) is downloaded automatically during compilation without popup dialogs.
- **Persistent User PATH Injection**: Detects the installation directory (`AppData\Local\Programs\MiKTeX\miktex\bin\x64` or `Program Files\MiKTeX\miktex\bin\x64`), updates the active session, and injects it permanently into the Windows User Environment variables.
- **Realtime TeX (`rtex`) & IDE Detection**: Automatically checks for local `rtex` daemon storage in Antigravity IDE and VS Code, executes `rtex doctor`, and writes `"realtimeTex.texliveBin"` directly into your editor `settings.json` so you don't even have to wait for environment variables to refresh.
- **Comprehensive Diagnostic Suite**: Includes `verify.bat` and `verify.ps1` with an automated end-to-end sample compilation check.

---

## Directory Structure

```text
windows-miktex-installer/
├── install.bat          # Double-clickable Windows Explorer launcher
├── install.ps1          # Robust PowerShell automation script
├── verify.bat           # Quick verification launcher
├── verify.ps1           # Environment diagnostic and sample compiler test
├── test/
│   └── sample.tex       # Multi-package test document (amsmath, listings, booktabs)
├── .gitignore           # Git ignore rules for TeX build artifacts and installers
├── LICENSE              # MIT License
└── README.md            # Repository documentation
```

---

## Quick Start

### Option A: Double-Click (GUI)
1. Navigate into the `windows-miktex-installer` folder.
2. Double-click **`install.bat`**.
3. Allow the installer to complete (typically 1–3 minutes).
4. Restart your editor or open terminal windows so the updated `PATH` is loaded.

### Option B: PowerShell Terminal
```powershell
# Run from repository root
cd windows-miktex-installer
.\install.ps1
```

For automated CI/CD or non-interactive setups:
```powershell
.\install.ps1 -NonInteractive
```

---

## CLI Usage & Parameters

`install.ps1` supports flexible parameters:

```powershell
.\install.ps1 [-Method <Auto | Winget | DirectDownload>] [-NonInteractive]
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `-Method` | String | `Auto` | Selects installation backend: `Auto` (tries `winget` then CTAN fallback), `Winget` (winget only), or `DirectDownload` (downloads basic-miktex installer directly from CTAN). |
| `-NonInteractive` | Switch | `False` | Suppresses interactive pauses ("Press any key to exit"), ideal for scripts and batch jobs. |

---

## Environment Verification

To verify that your installation is healthy at any time:

```powershell
.\verify.ps1
```
Or double-click **`verify.bat`**.

**Expected Diagnostic Output:**
```text
==========================================================
      MiKTeX & LuaLaTeX Environment Diagnostic Check       
==========================================================

 [PASS] LuaLaTeX Binary (C:\Users\...\AppData\Local\Programs\MiKTeX\miktex\bin\x64\lualatex.exe)
 [PASS] pdfLaTeX Binary (C:\Users\...\AppData\Local\Programs\MiKTeX\miktex\bin\x64\pdflatex.exe)
 [PASS] XeLaTeX Binary (C:\Users\...\AppData\Local\Programs\MiKTeX\miktex\bin\x64\xelatex.exe)
 [PASS] MiKTeX Maintenance Utility (initexmf) (C:\...\initexmf.exe)
 [PASS] On-the-fly package download enabled (Value: 1)

--> Testing LuaLaTeX Document Compilation...
 [PASS] LuaLaTeX Sample Compilation (test.tex -> test.pdf) (PDF generated successfully)

--> Testing Realtime TeX (rtex) Engine...
 [PASS] rtex doctor status (Engine at: C:\Users\...\rtex.exe)

==========================================================
 System is ready for LaTeX authoring and real-time preview!
==========================================================
```

---

## How It Works Under the Hood

1. **Detection**: Queries `Get-Command lualatex.exe` and `pdflatex.exe` across the existing `PATH`.
2. **Installation Strategy**:
   - Tries `winget install --id MiKTeX.MiKTeX -e --accept-source-agreements --accept-package-agreements`.
   - If `winget` is missing or fails, fetches the official 64-bit Basic MiKTeX setup executable from CTAN (`basic-miktex-*-x64.exe`) with progress reporting.
   - Executes the installer with non-interactive flags:
     ```cmd
     basic-miktex-setup-x64.exe --unattended --auto-install=yes --paper-size=A4
     ```
3. **Configuration**:
   - Queries `[EnvironmentVariableTarget]::User` and appends the binary directory to ensure future command prompts and IDE sessions find the binaries.
   - Executes `initexmf --set-config-value [MPM]AutoInstall=1` to guarantee silent, on-demand package downloading.
   - Runs `initexmf --update-fndb` to build the TeX font and filename directory indexes.
4. **Editor Validation**:
   - Inspects `%APPDATA%\Antigravity IDE` and `%APPDATA%\Code` for the `henryxiaoyang.realtime-tex` engine.
   - Runs `rtex doctor` to assert that `lualatex: ok` is returned.

---

## Troubleshooting & FAQ

#### 1. "lualatex not found" persists in VS Code after installation
Windows environment variable changes do not automatically propagate to running applications. 
- The installer automatically writes `"realtimeTex.texliveBin": "C:\\Users\\...\\miktex\\bin\\x64"` into your editor's `settings.json`.
- Press `Ctrl + Shift + P` and run **`Developer: Reload Window`** (or restart the IDE) so the extension reloads its configuration.

#### 2. Antivirus or Windows SmartScreen warnings
Because the script executes an installer in unattended mode, Windows Defender or third-party antivirus suites may occasionally prompt for confirmation. Select "More info" $\rightarrow$ "Run anyway" if prompted.

#### 3. Compiling an IEEEtran conference paper fails on first run
When compiling a document with new packages for the first time, MiKTeX will download the packages in the background. Ensure you have an active internet connection on the first compile. Subsequent runs use the cached packages from local disk and compile instantly.

---

## License

This project is licensed under the [MIT License](LICENSE).
