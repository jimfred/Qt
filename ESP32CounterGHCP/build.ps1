# ESP32 Counter - Complete Command-Line Build Script
# This script builds the project without Qt Creator

param(
    [switch]$Clean,
    [switch]$Flash,
    [string]$Port = "COM3"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$QtMCUPath = "C:\Qt\QtMCUs\2.11.1"
$ESPIDFPath = "C:\Espressif\frameworks\esp-idf-v5.5.1"
$ExportDir = Join-Path $ProjectRoot "build\export"
$IDFProjectDir = Join-Path $ProjectRoot "build\idf-project"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESP32 Counter - Command-Line Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Export QML project to ESP-IDF structure
Write-Host "[1/3] Exporting Qt MCU project..." -ForegroundColor Yellow

if ($Clean -and (Test-Path $ExportDir)) {
    Write-Host "  Cleaning export directory..." -ForegroundColor Gray
    Remove-Item -Path $ExportDir -Recurse -Force
}

$MetadataFile = Join-Path $QtMCUPath "platform\boards\espressif\esp32s3-box3-idf\esp32s3-box3-idf_16bpp_Windows_xtensagcc-metadata.json"
$QMLProjectExporter = Join-Path $QtMCUPath "bin\qmlprojectexporter.exe"
$QMLProject = Join-Path $ProjectRoot "mcu_counter.qmlproject"

$ExportArgs = @(
    "--platform-metadata", $MetadataFile,
    "--outdir", $ExportDir,
    "--project-type", "cmake",
    "--project-outdir", $IDFProjectDir,
    "--generate-entrypoint",
    "--platform-boards-sources-dir", (Join-Path $QtMCUPath "platform\boards"),
    $QMLProject
)

Write-Host "  Running qmlprojectexporter..." -ForegroundColor Gray
try {
    $ExportOutput = & $QMLProjectExporter @ExportArgs 2>&1
    $ExportExitCode = $LASTEXITCODE
    
    if ($ExportExitCode -ne 0) {
        Write-Host "  Export output:" -ForegroundColor Gray
        $ExportOutput | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        Write-Host "  [!] Project export failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "  OK Project exported successfully" -ForegroundColor Green
} catch {
    Write-Host "  [!] Export failed: $_" -ForegroundColor Red
    exit 1
}

# Step 2: Create top-level CMakeLists.txt if it doesn't exist
$TopCMake = Join-Path $ExportDir "CMakeLists.txt"
if (-not (Test-Path $TopCMake)) {
    Write-Host "  Creating ESP-IDF CMakeLists.txt..." -ForegroundColor Gray
    @"
# ESP32 Counter - ESP-IDF Project
# Generated from Qt MCUs project

cmake_minimum_required(VERSION 3.16)

# Set QUL_DIR before including IDF
set(QUL_DIR "$($QtMCUPath.Replace('\', '/'))")

# Include ESP-IDF CMake
include(`$ENV{IDF_PATH}/tools/cmake/project.cmake)

project(esp32counter)
"@ | Out-File -FilePath $TopCMake -Encoding UTF8
    Write-Host "  OK CMakeLists.txt created" -ForegroundColor Green
}

# Create component dependencies and required files for ESP32-S3-BOX-3
$QulComponentDir = Join-Path $ExportDir "components\Qul"
$QulComponentYml = Join-Path $QulComponentDir "idf_component.yml"

if (-not (Test-Path $QulComponentYml)) {
    Write-Host "  Adding ESP32-S3-BOX-3 component dependencies..." -ForegroundColor Gray
    $ComponentManifest = @"
## IDF Component Manager Manifest File
dependencies:
  espressif/esp_lcd_touch: "^1.0.0"
  espressif/esp-box-3: "==1.1.0"
"@
    Set-Content -Path $QulComponentYml -Value $ComponentManifest
    Write-Host "  OK Component dependencies configured" -ForegroundColor Green
}

# Create dummy.c with app_start stub
$QulDummyC = Join-Path $QulComponentDir "dummy.c"
$DummyContent = @"
// Dummy file for ESP-IDF component registration
// Qt MCU sources are added separately via CMake
// Stub to satisfy linker - real initialization done in platform code
void app_start(void) {
    // Platform initialization is handled by Qt MCU platform layer
    // This function exists to satisfy the ESP-IDF main.c call
}
"@
Set-Content -Path $QulDummyC -Value $DummyContent

# Create linker.lf file for ESP-IDF linker script generation
$QulLinkerLf = Join-Path $QulComponentDir "linker.lf"
$LinkerContent = @"
[mapping:qul]
archive: libQul.a
entries:
    * (default)
"@
Set-Content -Path $QulLinkerLf -Value $LinkerContent -NoNewline

# Fix QulExport path in CMakeLists.txt
$QulCMake = Join-Path $QulComponentDir "CMakeLists.txt"
if (Test-Path $QulCMake) {
    $cmakeContent = Get-Content $QulCMake -Raw
    if ($cmakeContent -match 'esp-box-3_noglib') {
        Write-Host "  Fixing component references..." -ForegroundColor Gray
        $cmakeContent = $cmakeContent -replace 'esp-box-3_noglib', 'esp-box-3'
        $cmakeContent = $cmakeContent -replace 'find_package\(QulExport REQUIRED PATHS ".*?" NO_DEFAULT_PATH\)', 'find_package(QulExport REQUIRED PATHS "C:/Users/jimfr/sandbox/qt/ESP32CounterGHCP/build/idf-project" NO_DEFAULT_PATH)'
        Set-Content -Path $QulCMake -Value $cmakeContent
        Write-Host "  OK Component references fixed" -ForegroundColor Green
    }
}

Write-Host ""

# Step 3: Set up ESP-IDF environment
Write-Host "[2/4] Setting up ESP-IDF environment..." -ForegroundColor Yellow

# Check if Python virtual environment exists (prefer 3.12, then 3.11, skip 3.14)
$PythonVenv = "C:\Espressif\python_env\idf5.5_py3.12_env\Scripts\python.exe"
if (-not (Test-Path $PythonVenv)) {
    $PythonVenv = "C:\Espressif\python_env\idf5.5_py3.11_env\Scripts\python.exe"
}

if (-not (Test-Path $PythonVenv)) {
    Write-Host "  Python 3.12 or 3.11 environment not found" -ForegroundColor Yellow
    Write-Host "  Python virtual environment not found" -ForegroundColor Yellow
    Write-Host "  Installing ESP-IDF tools..." -ForegroundColor Gray
    
    Push-Location $ESPIDFPath
    try {
        # Run install script
        & "$ESPIDFPath\install.ps1" all
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [!] ESP-IDF installation failed" -ForegroundColor Red
            Pop-Location
            exit 1
        }
        Write-Host "  OK ESP-IDF tools installed" -ForegroundColor Green
    } catch {
        Write-Host "  [!] Installation failed: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
}

# Check if ESP-IDF environment is already loaded
$IDFPy = Get-Command idf.py -ErrorAction SilentlyContinue
if (-not $IDFPy) {
    Write-Host "  ESP-IDF environment not detected, loading now..." -ForegroundColor Yellow
    
    $ESPIDFExport = Join-Path $ESPIDFPath "export.ps1"
    
    if (-not (Test-Path $ESPIDFExport)) {
        Write-Host "  [!] ESP-IDF export script not found at: $ESPIDFExport" -ForegroundColor Red
        exit 1
    }
    
    # Force use of Python 3.12 environment (prefer over 3.11)
    if (Test-Path "C:\Espressif\python_env\idf5.5_py3.12_env") {
        $env:IDF_PYTHON_ENV_PATH = "C:\Espressif\python_env\idf5.5_py3.12_env"
        Write-Host "  Using Python 3.12 environment..." -ForegroundColor Gray
    } elseif (Test-Path "C:\Espressif\python_env\idf5.5_py3.11_env") {
        $env:IDF_PYTHON_ENV_PATH = "C:\Espressif\python_env\idf5.5_py3.11_env"
        Write-Host "  Using Python 3.11 environment..." -ForegroundColor Gray
    }
    
    Write-Host "  Running ESP-IDF export script..." -ForegroundColor Gray
    
    # Execute the export script in the current session
    # This modifies the environment variables
    try {
        Push-Location $ESPIDFPath
        . $ESPIDFExport
        Pop-Location
        
        # Verify it worked
        $IDFPy = Get-Command idf.py -ErrorAction SilentlyContinue
        if ($IDFPy) {
            Write-Host "  OK ESP-IDF environment loaded successfully" -ForegroundColor Green
        } else {
            Write-Host "  [!] ESP-IDF export completed but idf.py not found in PATH" -ForegroundColor Red
            Write-Host "  This may indicate a problem with the ESP-IDF installation." -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "  [!] Failed to load ESP-IDF environment: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  OK ESP-IDF environment already loaded" -ForegroundColor Green
}



Write-Host ""

# Step 4: Build with ESP-IDF
Write-Host "[3/4] Building with ESP-IDF..." -ForegroundColor Yellow
Write-Host "  Running idf.py build..." -ForegroundColor Gray
Write-Host ""

Push-Location $ExportDir
try {
    # Check if target is already set
    $SdkConfigExists = Test-Path "sdkconfig"
    
    if ($Clean -or (-not $SdkConfigExists)) {
        if ($Clean) {
            Write-Host "  Cleaning previous build..." -ForegroundColor Gray
            & idf.py fullclean 2>&1 | Out-Null
        }
        
        # Set target to ESP32-S3 (required for first build or after clean)
        Write-Host "  Setting target to ESP32-S3..." -ForegroundColor Gray
        & idf.py set-target esp32s3
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [!] Failed to set target" -ForegroundColor Red
            $BuildExitCode = $LASTEXITCODE
            return
        }
    }
    
    & idf.py build
    $BuildExitCode = $LASTEXITCODE
    
    if ($BuildExitCode -eq 0) {
        Write-Host ""
        Write-Host "  OK Build successful!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "  [!] Build failed with exit code: $BuildExitCode" -ForegroundColor Red
        Pop-Location
        exit $BuildExitCode
    }
} catch {
    Write-Host "  [!] Build failed: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host ""

# Step 5: Verify and show build artifacts
Write-Host "[4/4] Verifying build output..." -ForegroundColor Yellow

$BuildDir = Join-Path $ExportDir "build"
$MainBinary = Join-Path $BuildDir "esp32counter.bin"

# Check for the main flashable binary
if (Test-Path $MainBinary) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "OK FLASHABLE FIRMWARE GENERATED" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    # Show all build artifacts
    $BinFiles = Get-ChildItem -Path $BuildDir -Filter "*.bin" -Recurse | Select-Object -First 10
    $ElfFiles = Get-ChildItem -Path $BuildDir -Filter "*.elf" -Recurse | Select-Object -First 5
    
    Write-Host "Build artifacts:" -ForegroundColor Cyan
    
    if ($ElfFiles) {
        foreach ($file in $ElfFiles) {
            $size = [math]::Round($file.Length / 1KB, 2)
            Write-Host "  $($file.Name) ($size KB)" -ForegroundColor White
        }
    }
    
    if ($BinFiles) {
        foreach ($file in $BinFiles) {
            $size = [math]::Round($file.Length / 1KB, 2)
            $icon = if ($file.Name -eq "esp32counter.bin") { "→" } else { " " }
            Write-Host "  $icon $($file.Name) ($size KB)" -ForegroundColor White
        }
    }
    
    Write-Host ""
    Write-Host "Main flashable file:" -ForegroundColor Cyan
    Write-Host "  $MainBinary" -ForegroundColor Green
    
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "[!] ERROR: FLASHABLE FIRMWARE NOT GENERATED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Expected file not found:" -ForegroundColor Yellow
    Write-Host "  $MainBinary" -ForegroundColor White
    Write-Host ""
    Write-Host "The build may have completed with errors." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Cyan
    Write-Host "  1. Check if ESP-IDF environment is properly set up" -ForegroundColor White
    Write-Host "  2. Run: C:\Espressif\frameworks\esp-idf-v5.5.1\export.ps1" -ForegroundColor White
    Write-Host "  3. Then try building again with: .\build.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Or build manually:" -ForegroundColor Cyan
    Write-Host "  cd build\export" -ForegroundColor White
    Write-Host "  idf.py build" -ForegroundColor White
    Write-Host ""
    
    exit 1
}

# Step 6: Flash if requested
if ($Flash) {
    Write-Host ""
    Write-Host "Flashing to $Port..." -ForegroundColor Yellow
    Push-Location $ExportDir
    try {
        & idf.py -p $Port flash monitor
    } catch {
        Write-Host "Flash failed: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-Host "To flash the firmware, run:" -ForegroundColor Cyan
    Write-Host "  .\build.ps1 -Flash -Port COM<X>" -ForegroundColor White
    Write-Host ""
    Write-Host "Or manually:" -ForegroundColor Cyan
    Write-Host "  cd build\export" -ForegroundColor White
    Write-Host "  idf.py -p COM<X> flash monitor" -ForegroundColor White
}

Write-Host ""
Write-Host "Build output directory: $ExportDir\build" -ForegroundColor Cyan
Write-Host ""
