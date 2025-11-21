// Copyright (C) 2025 Jim Frangione
// ESP32 Dual Counter - Main Entry Point

#include <platforminterface/log.h>
#include <climits>

#include <FreeRTOS.h>
#include <task.h>

#include <sdkconfig.h>
#include <bsp/esp-bsp.h>
#include <esp_system.h>

#include "qul_thread.h"
#include "counter_threads.h"

TaskHandle_t QulTask = NULL, Counter1Task = NULL, Counter2Task = NULL;

extern "C" {
void app_start(void)
{
    Qul::initHardware();
    Qul::initPlatform();

    initCounterQueues();

    xTaskCreate(Qul_Thread, "qul_thread", QUL_STACK_SIZE, NULL, QUL_FREERTOS_TASK_PRIORITY, &QulTask);
    xTaskCreate(Counter1_Thread, "counter1_thread", configMINIMAL_STACK_SIZE, NULL, QUL_FREERTOS_TASK_PRIORITY, &Counter1Task);
    xTaskCreate(Counter2_Thread,
                "counter2_thread",
                configMINIMAL_STACK_SIZE,
                NULL,
                QUL_FREERTOS_TASK_PRIORITY,
                &Counter2Task);

    // Allow higher priority Qul task to initialize fully to avoid synchronization issues
    taskYIELD();

    return;
}
}
