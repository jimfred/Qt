// Copyright (C) 2025 Jim Frangione
// Main entry point for ESP32 Counter application with IDF
#include <qul/qul.h>
#include <platforminterface/log.h>

#include <FreeRTOS.h>
#include <task.h>

#include <sdkconfig.h>
#include <bsp/esp-bsp.h>
#include <esp_system.h>

#include "../freertos/counter_threads.h"

TaskHandle_t QulTask = NULL;
TaskHandle_t Counter1Task = NULL;
TaskHandle_t Counter2Task = NULL;

extern "C" {
void app_start(void)
{
    Qul::initHardware();
    Qul::initPlatform();
    
    initCounterQueues();
    
    Qul::PlatformInterface::log("ESP32 Counter Application Starting...\r\n");
    
    xTaskCreate(Qul_Thread, "qul_thread", QUL_STACK_SIZE, NULL, QUL_FREERTOS_TASK_PRIORITY, &QulTask);
    xTaskCreate(Counter1_Thread, "counter1_thread", configMINIMAL_STACK_SIZE, NULL, QUL_FREERTOS_TASK_PRIORITY, &Counter1Task);
    xTaskCreate(Counter2_Thread, "counter2_thread", configMINIMAL_STACK_SIZE, NULL, QUL_FREERTOS_TASK_PRIORITY, &Counter2Task);
    
    // Allow higher priority Qul task to initialize fully to avoid synchronization issues
    taskYIELD();
    
    return;
}
}
