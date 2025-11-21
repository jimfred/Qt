# ESP32 Dual Counter

A Qt for MCUs application demonstrating multi-threaded programming on ESP32-S3-BOX-3 with two independent counters running in separate FreeRTOS tasks.

## Features

- **Dual Independent Counters**: Two counters that can run simultaneously
- **FreeRTOS Threading**: Each counter runs in its own FreeRTOS task
- **Touch UI**: Toggle switches to start/stop each counter
- **Thread-Safe Communication**: Uses FreeRTOS queues and event queues for safe inter-thread communication
- **Modern UI**: Professional-looking interface with color-coded counters

## Hardware Requirements

- **ESP32-S3-BOX-3** development board
- USB-C cable for programming and power

## Software Requirements

- Qt for MCUs 2.11.1 (installed at `C:\Qt\QtMCUs\2.11.1`)
- ESP-IDF v5.5.1 (installed at `C:\Espressif\frameworks\esp-idf-v5.5.1`)
- Windows PowerShell

## Project Structure

```
ESP32DualCounter/
├── counter.qml                    # Main QML UI file
├── mcu_dualcounter.qmlproject     # Qt MCUs project file
├── build.ps1                      # Build script
├── src/
│   ├── countercontrol.h           # Counter control interface
│   ├── freertos/
│   │   ├── countercontrol.cpp     # FreeRTOS counter implementation
│   │   └── threads/
│   │       ├── counter_threads.cpp # Counter thread implementations
│   │       ├── counter_threads.h
│   │       ├── qul_thread.cpp     # Qt UI thread
│   │       └── qul_thread.h
│   └── idf/
│       └── main.cpp               # ESP-IDF entry point
└── build/                         # Build output (generated)
```

## Building

### IMPORTANT: Run from Native PowerShell

The build script **must** be run from native Windows PowerShell (not Git Bash, WSL, or similar), as ESP-IDF requires a native Windows environment.

### Build Commands

**First time build:**
```powershell
.\build.ps1
```

**Clean and rebuild:**
```powershell
.\build.ps1 -Clean
```

**Build and flash:**
```powershell
.\build.ps1 -Flash -Port COM4
```

Replace `COM4` with your board's serial port.

## How It Works

### Architecture

1. **QML UI Thread** (`qul_thread.cpp`)
   - Runs the Qt Quick Ultralite application
   - Updates the display based on counter values
   - Handles touch input

2. **Counter 1 Thread** (`counter_threads.cpp`)
   - Increments counter1 value when running
   - Controlled via FreeRTOS queue
   - Updates UI via event queue

3. **Counter 2 Thread** (`counter_threads.cpp`)
   - Increments counter2 value when running
   - Independent from Counter 1
   - Also uses queues for thread-safe communication

### Thread Communication

- **FreeRTOS Queues**: Used to send start/stop commands to counter threads
- **Event Queue**: Used to send counter updates from threads to the QML UI
- **Singleton Pattern**: `CounterControl` object accessible from both QML and C++

## Usage

1. **Flash the application** to your ESP32-S3-BOX-3
2. **Touch the toggle switches** on screen to start/stop each counter
3. **Watch the counters** increment independently
4. Counter 1 is **green** when active
5. Counter 2 is **blue** when active

## Troubleshooting

### Build Errors

**License warnings during export:**
```
warning: License rejected/revoked
```
These can be safely ignored if the build continues.

**MSys/Mingw not supported:**
You're running from Git Bash. Use native PowerShell instead.

**Component not found:**
Run a clean build: `.\build.ps1 -Clean`

### Runtime Issues

**Display shows nothing:**
- Check USB connection
- Verify the board is powered on
- Try reflashing

**Counters don't increment:**
- Check that you're tapping the toggle switches
- The switches should change color when active

## Technical Details

### FreeRTOS Task Priorities

All tasks run at the same priority (`QUL_FREERTOS_TASK_PRIORITY`), allowing cooperative multitasking.

### Memory Usage

- **QUL Task**: `QUL_STACK_SIZE` (configured in platform)
- **Counter Tasks**: `configMINIMAL_STACK_SIZE` each

### Counter Speed

Each counter increments approximately once per second (1000ms delay).

## Credits

Based on the Qt for MCUs multitask example, adapted for a dual counter demonstration.

