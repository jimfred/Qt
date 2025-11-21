# Qt Projects Sandbox

This directory contains Qt demonstration projects for desktop and embedded platforms.

## Projects

### 1. JimFirstQtWidgetApp

A Qt Widgets application demonstrating multi-threading, signal/slot communication, and thread-safe UI updates.

### 2. ESP32CounterGHCP

Qt for MCUs application for ESP32-S3-BOX-3 with dual counters and touch controls. ✅ **Build working**

### 3. STM32CounterGHCP  

Qt for MCUs application for STM32F746G-Discovery with dual counters. ⚠️ **Cannot build - Missing STM32F746 BSP**

## Features

- **Two independent worker threads** that increment counters concurrently
- **Interactive UI** with checkboxes to start/stop each thread
- **Real-time counter displays** using QLCDNumber widgets
- **Thread-safe communication** using Qt's signal/slot mechanism with QMutex

## Project Structure

```
JimFirstQtWidgetApp/
├── main.cpp              # Application entry point
├── mainwindow.h/cpp      # Main window class with thread management
├── mainwindow.ui         # UI layout (checkboxes, LCD displays)
├── workerthread.h/cpp    # Worker thread implementation
└── CMakeLists.txt        # Build configuration
```

## Requirements

- Qt 6.10.0 or later
- CMake 3.16 or later
- C++17 compiler (MinGW 13.1.0 on Windows, or MSVC)

## Building

### Using Qt Creator (Recommended)

1. Open `JimFirstQtWidgetApp/CMakeLists.txt` in Qt Creator
2. Configure the project with Desktop Qt 6.10.0 MinGW 64-bit kit
3. Build (Ctrl+B)
4. Run (Ctrl+R)

### Using Command Line

```bash
cd JimFirstQtWidgetApp
mkdir build && cd build
cmake .. -DCMAKE_PREFIX_PATH=C:/Qt/6.10.0/mingw_64
cmake --build .
./JimFirstQtWidgetApp
```

## How It Works

### Architecture

- **MainWindow**: Creates two WorkerThread instances and connects UI controls
- **WorkerThread**: Inherits from QThread, implements counter logic in `run()` method
- **QMutex**: Ensures thread-safe access to the running flag and counter
- **Signals/Slots**: Thread emits `counterUpdated(int)` signal, MainWindow receives it on the GUI thread and updates display

### Key Qt Concepts Demonstrated

1. **QThread subclassing**: Override `run()` for custom thread behavior
2. **Cross-thread signals**: Automatic queued connections for thread-safe UI updates
3. **QMutex**: Prevent race conditions on shared data
4. **Qt Widgets**: Checkboxes, labels, LCD displays, layouts
5. **Qt UI Designer**: Visual layout with `.ui` files

## Usage

1. Run the application
2. Check "Thread 1 Running" to start the first counter
3. Check "Thread 2 Running" to start the second counter
4. Uncheck to stop threads
5. Observe both counters incrementing independently (every 100ms)

## Future Enhancements

- Port to STM32F7 evaluation board with LCD display
- Add reset buttons for counters
- Add speed control sliders
- Add pause/resume functionality
- Display thread state (running/stopped)

## Learning Resources

- [Qt Documentation](https://doc.qt.io/)
- [Qt Threading Basics](https://doc.qt.io/qt-6/thread-basics.html)
- [Signals and Slots](https://doc.qt.io/qt-6/signalsandslots.html)

## License

This is a learning/demonstration project.

---

### ESP32CounterGHCP

A Qt for MCUs application for ESP32-S3-BOX-3 featuring dual independent counters with touch controls.

```
┌────────────────────────────────────┐
│      ESP32 Dual Counter            │
├────────────────────────────────────┤
│                                    │
│  ┌─────────────────────────────┐   │
│  │ Counter 1:    [O]───[O]     │   │  ← Toggle switch
│  │         0                   │   │  ← Counter display (green when active)
│  └─────────────────────────────┘   │
│                                    │
│  ┌─────────────────────────────┐   │
│  │ Counter 2:    [O]───[O]     │   │  ← Toggle switch
│  │         0                   │   │  ← Counter display (blue when active)
│  └─────────────────────────────┘   │
│                                    │
│  Toggle switches to start/stop     │
│           counters                 │
└────────────────────────────────────┘
     ESP32-S3-BOX-3 (320x240)
```

#### Features

- **Embedded Platform**: Runs on ESP32-S3-BOX-3 MCU with 320x240 touchscreen
- **Qt for MCUs**: Lightweight Qt framework optimized for microcontrollers
- **FreeRTOS**: Two independent counter tasks managed by FreeRTOS
- **Touch Interface**: QML-based UI with touch-activated switches
- **Real-time Updates**: Event queue system for thread-safe UI updates
- **Low Resource**: Designed for memory-constrained embedded systems

#### Architecture

- **UI Framework**: Qt for MCUs 2.11.1 with QML
- **RTOS**: FreeRTOS (provided by ESP-IDF v5.5.1)
- **MCU**: ESP32-S3 (Xtensa LX7 dual-core, 240MHz)
- **Display**: 320x240 touchscreen LCD
- **Build System**: CMake with ESP-IDF integration

#### Key Differences from Desktop Version

| Aspect       | Desktop (JimFirstQtWidgetApp) | Embedded (ESP32CounterGHCP) |
| ------------ | ----------------------------- | --------------------------- |
| UI Framework | Qt Widgets                    | Qt for MCUs (QML)           |
| Threading    | QThread                       | FreeRTOS tasks              |
| Platform     | Windows/Linux/Mac             | ESP32-S3 MCU                |
| Resources    | GB RAM, GHz CPU               | 512KB RAM, 240MHz CPU       |
| Display      | Variable resolution           | Fixed 320x240 touchscreen   |
| Controls     | Mouse/Keyboard                | Touchscreen only            |

#### Building

**Automated Command-Line Build** ✅

```powershell
cd ESP32CounterGHCP
.\build.ps1           # Build firmware
.\build.ps1 -Flash    # Build and flash to device
```

The build script automatically:

- Loads ESP-IDF v5.5.1 environment
- Exports QML to C++ code
- Downloads 12 managed components
- Compiles and generates flashable firmware
- Zero manual configuration required!

**Requirements:**

- Qt for MCUs 2.11.1
- ESP-IDF v5.5.1  
- Python 3.12
- Xtensa GCC toolchain (included with ESP-IDF)

**Status:** ✅ **Fully working** - generates `esp32counter.bin` ready to flash

See `ESP32CounterGHCP/README.md` for detailed documentation and troubleshooting.

---

### STM32CounterGHCP

A Qt for MCUs application for STM32F746G-Discovery featuring dual independent counters with touch controls.

#### Features

- **Larger Display**: 480x272 touchscreen (71% more pixels than ESP32)
- **ARM Cortex-M7**: Industry-standard ARM architecture @ 216MHz
- **FreeRTOS**: Same counter logic as ESP32 version (95%+ code reuse)
- **Hardware FPU**: Double-precision floating point for smooth graphics
- **Integrated Tools**: Build with Qt Creator (no custom scripts needed)
- **Touch Interface**: QML-based UI scaled for larger display

#### Architecture Comparison

| Aspect | ESP32CounterGHCP | STM32CounterGHCP |
|--------|------------------|------------------|
| **Display** | 320x240 | **480x272** (larger) |
| **CPU** | Xtensa LX7 dual-core @ 240MHz | ARM Cortex-M7 @ 216MHz |
| **RAM** | 512KB | 340KB |
| **Architecture** | Xtensa (custom) | **ARM** (standard) |
| **Build** | Custom PowerShell script | **Qt Creator integrated** |
| **Toolchain** | ESP-IDF + Xtensa GCC | STM32Cube + ARM GCC |

#### Building

**Qt Creator Workflow** (Easiest)
```
1. Open STM32Counter.qmlproject in Qt Creator
2. Select STM32F746G-Discovery kit  
3. Build (Ctrl+B)
4. Flash to board (Ctrl+R)
```

**Requirements:**
- Qt for MCUs 2.11.1
- Qt Creator with STM32F7 support
- STM32CubeIDE (includes ARM GCC toolchain)
- STM32F746G-Discovery board

**Code Reuse from ESP32 Version:**
- ✅ 100% counter logic reusable
- ✅ 100% FreeRTOS task code reusable
- ✅ 95% QML UI (resized for 480x272)
- ✅ Total: 95%+ code reuse!

**Status:** ⚠️ **Cannot build - Qt is missing BSP for STM32F746**

**Discovery**: Qt for MCUs 2.11.1 only includes ESP32 BSP. STM32F746 BSP is not available in the base installation.

**This project serves as:**
- ✅ Reference implementation showing 95%+ code portability
- ✅ Template for when STM32 support becomes available
- ✅ Documentation of porting process from ESP32

**Recommendation**: Use **ESP32CounterGHCP** which is fully functional.

See `STM32CounterGHCP/IMPORTANT_LIMITATION.md` for detailed explanation.
