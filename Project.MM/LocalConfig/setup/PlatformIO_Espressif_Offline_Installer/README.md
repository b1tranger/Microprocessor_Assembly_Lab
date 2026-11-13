# PlatformIO C++ Espressif 32 Cross-Compiler Toolchain (Offline Installer)

A fully localized, self-contained automation toolkit providing **PlatformIO Core CLI**, pre-downloaded **Python Wheels**, and the complete **Espressif 32 (ESP32) Cross-Compilation Toolchains** (`toolchain-xtensa-esp-elf`, `toolchain-riscv32-esp`, `framework-arduinoespressif32`, `tool-esptool`, and `espressif32` platform) for 100% offline, air-gapped workstations.

---

## Table of Contents
- [1. Overview & Architecture](#1-overview--architecture)
- [2. Contents & Directory Structure](#2-contents--directory-structure)
- [3. How to Use on an Offline PC](#3-how-to-use-on-an-offline-pc)
  - [Step 1: Install Offline](#step-1-install-offline)
  - [Step 2: Verify & Build](#step-2-verify--build)
  - [Optional: Global Profile Mode](#optional-global-profile-mode)
- [4. Re-syncing Dependencies (Online PC Only)](#4-re-syncing-dependencies-online-pc-only)
- [5. What is Included in the Localized Toolchain](#5-what-is-included-in-the-toolchain)
- [6. License & Credits](#6-license--credits)

---

## 1. Overview & Architecture

Embedded development often requires working in restricted lab environments, competitive programming rooms, or field machines with zero internet connectivity. Normally, PlatformIO downloads over **4GB of C++ toolchains and Python wheels** during its first build.

This toolkit localizes all dependencies directly inside this folder:
1. **Python Wheels (`wheels/`)**: All 22 required PlatformIO Core pip wheels are pre-downloaded for zero-network installation (`--no-index`).
2. **Espressif 32 Toolchains (`.platformio/`)**: The complete Xtensa & RISC-V GCC cross-compilers, Arduino ESP32 core, ESP-IDF HAL, and SCons build system are pre-installed.
3. **Environment Localization (`PLATFORMIO_CORE_DIR`)**: Binds PlatformIO Core directly to the local `.platformio/` directory, allowing compilers to run directly in-place without scattering files into user profile directories.
4. **Wokwi IoT Gateway (`wokwigw.exe`)**: Pre-packaged network bridge for local ESP32 simulation in VS Code Wokwi.

---

## 2. Contents & Directory Structure

```text
PlatformIO_Espressif_Offline_Installer/
│
├── wheels/                      # 22 pre-downloaded Python wheels for PlatformIO Core
├── wokwigw.exe                  # Local Wokwi IoT Gateway binary
├── platformio_cache.zip         # (Download from GitHub Releases) ~600MB toolchain archive
│
├── install_offline.bat          # 1-Click offline installer launcher
├── install_offline.ps1          # Installs wheels (--no-index) & sets PLATFORMIO_CORE_DIR
│
├── export_offline_bundle.bat    # Optional: re-download wheels & sync toolchains (online PC)
├── export_offline_bundle.ps1    # Sync automation script
│
├── README.md                    # Standalone repository documentation
└── .gitignore                   # Excludes heavy binaries from Git tracking
```

---

## 3. How to Use on an Offline PC

### Step 0: Download the Offline Toolchains Archive (GitHub Releases)
Because the Espressif 32 toolchains are ~600MB compressed (~4.1 GB uncompressed), download `platformio_cache.zip` from:
* **Release Page**: **[b1tranger/wokwi_env_setup_script Releases](https://github.com/b1tranger/wokwi_env_setup_script/releases/tag/platformio_cache.zip)**
* **Direct Download**: [platformio_cache.zip](https://github.com/b1tranger/wokwi_env_setup_script/releases/download/platformio_cache.zip/platformio_cache.zip)

Place `platformio_cache.zip` directly into this folder (`PlatformIO_Espressif_Offline_Installer/`).

### Step 1: Install Offline
1. Copy this folder (with `platformio_cache.zip`) to your offline workstation (via USB drive or network share).
2. Ensure Python 3.10+ is installed on the machine.
3. Double-click:
   ```cmd
   .\install_offline.bat
   ```
   *(Or in PowerShell: `powershell -ExecutionPolicy Bypass -File .\install_offline.ps1`)*

**What happens automatically:**
* PlatformIO CLI is installed globally using `--no-index --find-links=wheels/`.
* `PLATFORMIO_CORE_DIR` is registered to point directly to the localized `.platformio/` folder.
* `wokwigw.exe` is copied to the simulation environment if `LocalConfig/` is found.
* A live validation compilation is run to guarantee 100% functionality.

### Step 2: Verify & Build
Once installed, open any terminal or VS Code and compile without internet:
```powershell
pio pkg list -g
pio run
```

### Optional: Global Profile Mode
If you prefer extracting toolchains into standard Windows user home (`C:\Users\<Username>\.platformio\`) rather than keeping them localized:
```powershell
powershell -ExecutionPolicy Bypass -File .\install_offline.ps1 -GlobalProfile
```

---

## 4. Re-syncing Dependencies (Online PC Only)

If you ever need to refresh or update the localized dependencies from an online workstation:
```cmd
.\export_offline_bundle.bat
```

---

## 5. What is Included in the Localized Toolchain

| Package | Local Size | Purpose |
| :--- | :--- | :--- |
| **`wheels/`** | ~4 MB (22 files) | Complete pip wheels for PlatformIO Core, Click, Requests, Starlette, Uvicorn, etc. |
| **`toolchain-xtensa-esp-elf`** | ~1.35 GB | GCC 14.2 / G++ cross-compiler for standard ESP32 (Xtensa LX6 dual-core). |
| **`toolchain-riscv32-esp`** | ~2.38 GB | GCC 14.2 cross-compiler for ESP32-C3 / ESP32-C6 (RISC-V architecture). |
| **`framework-arduinoespressif32`** | ~240 MB | Arduino ESP32 core, ESP-IDF HAL, FreeRTOS kernel, and Wi-Fi/SPI/SD drivers. |
| **`platform-espressif32`** | ~1 MB | PlatformIO board descriptors, memory map rules, and partition managers. |
| **`tool-esptool` & `tool-scons`** | ~70 MB | ESP32 flash binary packager, partition table generator, and SCons engine. |
| **`wokwigw.exe`** | ~6 MB | Local TCP/IP socket bridge for Wokwi VS Code extension simulation. |

---

## 6. License & Credits
- **PlatformIO**: Apache-2.0 License.
- **Espressif Toolchains**: GCC GPL-3.0 / Apache-2.0.
- **Wokwi Gateway**: Wokwi.

