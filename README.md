# Qt Multi-Threaded Counter Demo

A Qt Widgets application demonstrating multi-threading, signal/slot communication, and thread-safe UI updates.

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
