// Copyright (C) 2025 Jim Frangione
// Main entry point for ESP32 Counter application
#include <qul/qul.h>
#include <platforminterface/log.h>

#include <FreeRTOS.h>
#include <task.h>

#include "counter_threads.h"

#ifndef QUL_STACK_SIZE
#error QUL_STACK_SIZE must be defined.
#endif

TaskHandle_t QulTask = NULL;
TaskHandle_t Counter1Task = NULL;
TaskHandle_t Counter2Task = NULL;

int main()
{
    Qul::initHardware();
    Qul::initPlatform();
    
    initCounterQueues();
    
    Qul::PlatformInterface::log("ESP32 Counter Application Starting...\r\n");
    
    if (xTaskCreate(Qul_Thread, "QulExec", QUL_STACK_SIZE, 0, 4, &QulTask) != pdPASS) {
        Qul::PlatformInterface::log("QUL task creation failed!\r\n");
        configASSERT(false);
    }
    
    if (xTaskCreate(Counter1_Thread, "Counter1", configMINIMAL_STACK_SIZE, 0, 3, &Counter1Task) != pdPASS) {
        Qul::PlatformInterface::log("Counter1 task creation failed!\r\n");
        configASSERT(false);
    }
    
    if (xTaskCreate(Counter2_Thread, "Counter2", configMINIMAL_STACK_SIZE, 0, 3, &Counter2Task) != pdPASS) {
        Qul::PlatformInterface::log("Counter2 task creation failed!\r\n");
        configASSERT(false);
    }
    
    Qul::PlatformInterface::log("Starting FreeRTOS scheduler...\r\n");
    vTaskStartScheduler();
    
    // Should not reach this point
    return 1;
}
