# Qt for MCUs - ESP32-S3-BOX-3 Build Script (Simplified)
# Builds Qt MCU examples for ESP32-S3-BOX-3

param(
    [switch]$Flash,
    [switch]$Clean,
    [string]$Example = "minimal",
    [string]$Port = "COM3"
)

$ErrorActionPreference = "Continue"

# Configuration
$QUL_ROOT = "C:\Qt\QtMCUs\2.11.1"
$ESP_IDF_ROOT = "C:\Espressif\frameworks\esp-idf-v5.5.1"
$PROJECT_ROOT = $PSScriptRoot
$BUILD_DIR = "$PROJECT_ROOT\build"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Qt for MCUs - ESP32-S3-BOX-3 Builder" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Example: $Example" -ForegroundColor Yellow
Write-Host ""

# Validate paths
if (-not (Test-Path $QUL_ROOT)) {
    Write-Host "[!] Qt for MCUs not found at $QUL_ROOT" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ESP_IDF_ROOT)) {
    Write-Host "[!] ESP-IDF not found at $ESP_IDF_ROOT" -ForegroundColor Red
    exit 1
}

# Example configurations
$EXAMPLES = @{
    "minimal" = "mcu_minimal.qmlproject"
    "multitask" = "mcu_multitask.qmlproject"
    "chess" = "mcu_chess.qmlproject"
    "instrument_cluster" = "mcu_instrument_cluster.qmlproject"
    "sprite_animations" = "mcu_sprite_animations.qmlproject"
    "layers" = "mcu_layers.qmlproject"
    "painteditem" = "mcu_painteditem.qmlproject"
    "listmodel" = "mcu_listmodel.qmlproject"
    "layouts" = "mcu_layouts.qmlproject"
    "shapes" = "mcu_shapes.qmlproject"
}

if (-not $EXAMPLES.ContainsKey($Example)) {
    Write-Host "[!] Unknown example: $Example" -ForegroundColor Red
    Write-Host "Available examples:" -ForegroundColor Yellow
    $EXAMPLES.Keys | Sort-Object | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
    exit 1
}

$QML_PROJECT = "$QUL_ROOT\examples\$Example\$($EXAMPLES[$Example])"

if (-not (Test-Path $QML_PROJECT)) {
    Write-Host "[!] QML project not found: $QML_PROJECT" -ForegroundColor Red
    exit 1
}

# Clean if requested (always clean when switching examples to avoid file conflicts)
$lastExampleFile = "$PROJECT_ROOT\.last_example"
$lastExample = if (Test-Path $lastExampleFile) { Get-Content $lastExampleFile } else { "" }

if (($Clean -or ($lastExample -ne $Example)) -and (Test-Path $BUILD_DIR)) {
    if ($lastExample -ne $Example -and $lastExample -ne "") {
        Write-Host "Switching from '$lastExample' to '$Example', cleaning build directory..." -ForegroundColor Yellow
    } else {
        Write-Host "Cleaning build directory..." -ForegroundColor Yellow
    }
    Remove-Item -Recurse -Force $BUILD_DIR
    Write-Host "OK Clean complete" -ForegroundColor Green
    Write-Host ""
}

# Remember which example we're building
Set-Content -Path $lastExampleFile -Value $Example

# Create build directory
if (-not (Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
}

# Step 1: Export QML project
Write-Host "[1/4] Exporting QML project..." -ForegroundColor Yellow

# Build export arguments (multitask example provides its own main.cpp)
$exportArgs = @(
    $QML_PROJECT,
    "--boarddefaults=$QUL_ROOT\platform\boards\espressif\esp32s3-box3-idf\cmake\BoardDefaults_16bpp.qmlprojectconfig",
    "--toolchain", "GNU",
    "--platform", "esp32s3-box3-idf",
    "--outdir", $BUILD_DIR,
    "--project-type", "esp-idf",
    "--platform-metadata", "$QUL_ROOT\platform\boards\espressif\esp32s3-box3-idf\esp32s3-box3-idf_16bpp_Windows_xtensagcc-metadata.json"
)

# Only generate entrypoint for examples that don't provide their own
if ($Example -ne "multitask") {
    $exportArgs += "--generate-entrypoint"
}

& "$QUL_ROOT\bin\qmlprojectexporter.exe" @exportArgs 2>&1 | Write-Host

# Check if export actually produced output (license warnings can be ignored)
if (Test-Path "$BUILD_DIR\CMakeLists.txt") {
    Write-Host "OK Project exported successfully" -ForegroundColor Green
} else {
    Write-Host "[!] Export failed - no CMakeLists.txt generated" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 1.5: Add platform-specific source files for certain examples
if ($Example -eq "multitask") {
    Write-Host "[1.5/4] Adding platform-specific sources for multitask..." -ForegroundColor Yellow

    $QulComponentDir = "$BUILD_DIR\components\Qul"
    $ExampleSrcDir = "$QUL_ROOT\examples\multitask"

    # Create board_utils directory structure
    $BoardUtilsDir = "$QulComponentDir\board_utils"
    if (-not (Test-Path $BoardUtilsDir)) {
        New-Item -ItemType Directory -Path $BoardUtilsDir | Out-Null
    }

    # Copy FreeRTOS implementation
    $SourceFiles = @(
        @{Src = "$ExampleSrcDir\src\freertos\hardwarecontrol.cpp"; Dest = "$QulComponentDir\hardwarecontrol.cpp"},
        @{Src = "$ExampleSrcDir\src\freertos\threads\fan_thread.cpp"; Dest = "$QulComponentDir\fan_thread.cpp"},
        @{Src = "$ExampleSrcDir\src\freertos\threads\fan_thread.h"; Dest = "$QulComponentDir\fan_thread.h"},
        @{Src = "$ExampleSrcDir\src\freertos\threads\led_thread.cpp"; Dest = "$QulComponentDir\led_thread.cpp"},
        @{Src = "$ExampleSrcDir\src\freertos\threads\led_thread.h"; Dest = "$QulComponentDir\led_thread.h"},
        @{Src = "$ExampleSrcDir\src\freertos\threads\qul_thread.cpp"; Dest = "$QulComponentDir\qul_thread.cpp"},
        @{Src = "$ExampleSrcDir\src\freertos\threads\qul_thread.h"; Dest = "$QulComponentDir\qul_thread.h"},
        @{Src = "$ExampleSrcDir\board_utils\src\esp32s3box3\led.cpp"; Dest = "$QulComponentDir\led.cpp"},
        @{Src = "$ExampleSrcDir\board_utils\include\board_utils\led.h"; Dest = "$BoardUtilsDir\led.h"},
        @{Src = "$ExampleSrcDir\src\idf\main.cpp"; Dest = "$QulComponentDir\main.cpp"}
    )

    foreach ($file in $SourceFiles) {
        if (Test-Path $file.Src) {
            Copy-Item -Path $file.Src -Destination $file.Dest -Force
            Write-Host "  Copied $(Split-Path $file.Src -Leaf)" -ForegroundColor Gray
        }
    }

    # Update CMakeLists.txt to include the new sources and include directories
    $CMakeFile = "$QulComponentDir\CMakeLists.txt"
    $cmakeContent = Get-Content $CMakeFile -Raw

    # Replace dummy.c with all our source files
    $newSources = "main.cpp hardwarecontrol.cpp fan_thread.cpp led_thread.cpp qul_thread.cpp led.cpp dummy.c"
    $cmakeContent = $cmakeContent -replace 'idf_component_register\(SRCS dummy\.c', "idf_component_register(SRCS $newSources"

    # Add board_utils to the include directories (add it after the "." include)
    if ($cmakeContent -match 'INCLUDE_DIRS "\."') {
        $cmakeContent = $cmakeContent -replace '(INCLUDE_DIRS "\."\s)', '$1INCLUDE_DIRS "board_utils"'
    }

    Set-Content -Path $CMakeFile -Value $cmakeContent

    # Update idf_component.yml to use correct component version
    $ComponentYml = "$QulComponentDir\idf_component.yml"
    $ymlContent = @"
## IDF Component Manager Manifest File
dependencies:
  espressif/esp_lcd_touch: "^1.0.0"
  espressif/esp-box-3_noglib: "^3.0.1"
  idf:
    version: ">=5.0.0"
"@
    Set-Content -Path $ComponentYml -Value $ymlContent

    Write-Host "OK Platform-specific sources added" -ForegroundColor Green
    Write-Host ""
}

# Step 2: Load ESP-IDF environment
Write-Host "[2/4] Loading ESP-IDF environment..." -ForegroundColor Yellow

# Set Python environment to avoid 3.14 issues
if (Test-Path "C:\Espressif\python_env\idf5.5_py3.12_env") {
    $env:IDF_PYTHON_ENV_PATH = "C:\Espressif\python_env\idf5.5_py3.12_env"
    Write-Host "  Using Python 3.12 environment" -ForegroundColor Gray
}

$ESPIDFExport = "$ESP_IDF_ROOT\export.ps1"
if (-not (Test-Path $ESPIDFExport)) {
    Write-Host "[!] ESP-IDF export script not found" -ForegroundColor Red
    exit 1
}

try {
    Push-Location $ESP_IDF_ROOT
    . $ESPIDFExport
    Pop-Location

    $IDFPy = Get-Command idf.py -ErrorAction SilentlyContinue
    if (-not $IDFPy) {
        Write-Host "[!] idf.py not found after loading environment" -ForegroundColor Red
        exit 1
    }
    Write-Host "OK ESP-IDF environment loaded" -ForegroundColor Green
} catch {
    Pop-Location
    Write-Host "[!] Failed to load ESP-IDF: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Build
Write-Host "[3/4] Building with ESP-IDF..." -ForegroundColor Yellow

Push-Location $BUILD_DIR
try {
    # Set target if needed
    if (-not (Test-Path "sdkconfig")) {
        Write-Host "  Setting target to ESP32-S3..." -ForegroundColor Gray
        & idf.py set-target esp32s3 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!] Failed to set target" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }

    # Build
    Write-Host "  Running build..." -ForegroundColor Gray
    & idf.py build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] Build failed" -ForegroundColor Red
        Pop-Location
        exit 1
    }

    Write-Host "OK Build complete" -ForegroundColor Green
} catch {
    Pop-Location
    Write-Host "[!] Build error: $_" -ForegroundColor Red
    exit 1
}
Pop-Location

Write-Host ""

# Step 4: Flash if requested
if ($Flash) {
    Write-Host "[4/4] Flashing to ESP32-S3-BOX-3..." -ForegroundColor Yellow

    Push-Location $BUILD_DIR
    try {
        & idf.py -p $Port flash
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[!] Flash failed" -ForegroundColor Red
            Pop-Location
            exit 1
        }
        Write-Host "OK Flash complete" -ForegroundColor Green
    } catch {
        Pop-Location
        Write-Host "[!] Flash error: $_" -ForegroundColor Red
        exit 1
    }
    Pop-Location
} else {
    Write-Host "[4/4] Skipping flash (use -Flash to flash)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "SUCCESS!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host "Build output: $BUILD_DIR\build" -ForegroundColor Cyan
Write-Host ""
Write-Host "To flash:" -ForegroundColor Cyan
Write-Host "  .\build.ps1 -Flash -Port COM<X>" -ForegroundColor White
Write-Host ""
Write-Host "To build different example:" -ForegroundColor Cyan
Write-Host "  .\build.ps1 -Example chess" -ForegroundColor White
Write-Host ""
