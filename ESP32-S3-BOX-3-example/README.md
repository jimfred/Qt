# Qt for MCUs - ESP32-S3-BOX-3 Example Builder

This directory contains a build script for creating Qt for MCUs applications for the **ESP32-S3-BOX-3** development board.

## What's Included

The build script (`build.ps1`) can build any of the Qt for MCUs example projects that come with your Qt installation, including:

- **minimal** - Simple Hello World example (best for testing)
- **multitask** - FreeRTOS multi-threading demo
- **chess** - Interactive chess game with touch screen
- Plus 28 other examples from `C:\Qt\QtMCUs\2.11.1\examples\`

## Prerequisites

1. **Qt for MCUs 2.11.1** installed at `C:\Qt\QtMCUs\2.11.1`
2. **ESP-IDF v5.5.1** installed at `C:\Espressif\frameworks\esp-idf-v5.5.1`
3. **ESP32-S3-BOX-3** hardware board

## Quick Start

### IMPORTANT: Run from PowerShell, NOT Git Bash or WSL

The ESP-IDF toolchain requires a native Windows environment and will fail if run from Git Bash, WSL, or similar Unix-like shells. You **must** use native Windows PowerShell.

### How to Build

1. **Open PowerShell** (Windows PowerShell or PowerShell 7)
   - Press `Win + X` and select "Windows PowerShell" or "Terminal"
   - Or search for "PowerShell" in the Start menu

2. **Navigate to this directory:**
   ```powershell
   cd C:\Users\jimfr\sandbox\qt\ESP32-S3-BOX-3-example
   ```

3. **Run the build script:**
   ```powershell
   .\build.ps1
   ```

   This will build the default "minimal" example.

### First Build

The first time you build, the script will:
1. Export the QML project to ESP-IDF format (you may see license warnings - these are safe to ignore)
2. Load the ESP-IDF environment
3. Set the target to ESP32-S3
4. Build the firmware

The build takes several minutes on the first run.

## Usage Examples

### Build the minimal example (default)
```powershell
.\build.ps1
```

### Build the chess example
```powershell
.\build.ps1 -Example chess
```

### Build the multitask example
```powershell
.\build.ps1 -Example multitask
```

### Clean and rebuild
```powershell
.\build.ps1 -Clean
```

### Build and flash to board
```powershell
.\build.ps1 -Flash -Port COM3
```

Replace `COM3` with your board's serial port.

### Build different example and flash
```powershell
.\build.ps1 -Example chess -Flash -Port COM4
```

## Available Examples

The build script currently supports these examples:

| Example | Description |
|---------|-------------|
| minimal | Basic Hello World (default) |
| multitask | FreeRTOS threading demo |
| chess | Touch-screen chess game |
| instrument_cluster | Dashboard UI demo |
| sprite_animations | Animated sprites |
| layers | Graphics layers demo |
| painteditem | Custom painting demo |
| listmodel | List view with model |
| layouts | Layout management demo |
| shapes | Vector shapes demo |

More examples are available in `C:\Qt\QtMCUs\2.11.1\examples\` - you can add them to the build script's `$EXAMPLES` dictionary if needed.

## Output

After a successful build, you'll find:
- **Firmware binary:** `build\build\<example>.bin`
- **ELF file:** `build\build\<example>.elf`
- **Other build artifacts:** `build\build\`

## Flashing to ESP32-S3-BOX-3

### Find your COM port
1. Connect the ESP32-S3-BOX-3 to your computer via USB
2. Open Device Manager (Win + X → Device Manager)
3. Expand "Ports (COM & LPT)"
4. Look for "USB Serial Port (COM#)" or similar

### Flash the firmware
```powershell
.\build.ps1 -Flash -Port COM<X>
```

Replace `<X>` with your port number (e.g., COM3, COM4).

## Troubleshooting

### License warnings
You may see Qt license warnings during export:
```
warning: License rejected/revoked
```
These can be safely ignored if the build continues and produces output.

### MSys/Mingw not supported
If you see this error, you're running from Git Bash or similar. **You must use native PowerShell.**

### Python errors
The script automatically selects Python 3.12. If you have issues:
1. Check that `C:\Espressif\python_env\idf5.5_py3.12_env` exists
2. Try reinstalling ESP-IDF

### Build fails
1. Make sure ESP-IDF is properly installed
2. Try running a clean build: `.\build.ps1 -Clean`
3. Check that you have at least 5GB of free disk space

## Manual Building (Advanced)

If you need more control, you can build manually:

1. **Load ESP-IDF environment:**
   ```powershell
   cd C:\Espressif\frameworks\esp-idf-v5.5.1
   .\export.ps1
   ```

2. **Navigate to build directory:**
   ```powershell
   cd C:\Users\jimfr\sandbox\qt\ESP32-S3-BOX-3-example\build
   ```

3. **Build:**
   ```powershell
   idf.py build
   ```

4. **Flash:**
   ```powershell
   idf.py -p COM3 flash
   ```

## Support

- **Qt for MCUs Documentation:** https://doc.qt.io/QtForMCUs/
- **ESP32-S3-BOX-3 Board Info:** https://doc.qt.io/QtForMCUs/qtul-instructions-esp32s3-box3.html
- **ESP-IDF Documentation:** https://docs.espressif.com/projects/esp-idf/

## License

The Qt for MCUs examples are provided by Qt Company.
The ESP32-S3-BOX-3 board is from Espressif Systems.
