// Copyright (C) 2025 Jim Frangione
// Counter Threads Implementation
#include "counter_threads.h"
#include "../countercontrol.h"

#include <qul/qul.h>
#include <qul/application.h>

#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

void Counter1_Thread(void *argument)
{
    (void) argument;
    
    int counter = 0;
    bool isRunning = false;
    QueueHandle_t queue = getCounter1Queue();
    CounterEventQueue *eventQueue = getCounterEventQueue();
    
    while (true) {
        if (xQueueReceive(queue, &isRunning, 0) == pdTRUE) {
            if (!isRunning) {
                counter = 0;
                CounterEvent event = {CounterEventId::Counter1Update, counter};
                eventQueue->postEvent(event);
            }
        }
        
        if (isRunning) {
            counter++;
            CounterEvent event = {CounterEventId::Counter1Update, counter};
            eventQueue->postEvent(event);
            vTaskDelay(pdMS_TO_TICKS(100));
        } else {
            vTaskDelay(pdMS_TO_TICKS(50));
        }
    }
}

void Counter2_Thread(void *argument)
{
    (void) argument;
    
    int counter = 0;
    bool isRunning = false;
    QueueHandle_t queue = getCounter2Queue();
    CounterEventQueue *eventQueue = getCounterEventQueue();
    
    while (true) {
        if (xQueueReceive(queue, &isRunning, 0) == pdTRUE) {
            if (!isRunning) {
                counter = 0;
                CounterEvent event = {CounterEventId::Counter2Update, counter};
                eventQueue->postEvent(event);
            }
        }
        
        if (isRunning) {
            counter++;
            CounterEvent event = {CounterEventId::Counter2Update, counter};
            eventQueue->postEvent(event);
            vTaskDelay(pdMS_TO_TICKS(100));
        } else {
            vTaskDelay(pdMS_TO_TICKS(50));
        }
    }
}

void Qul_Thread(void *argument)
{
    (void) argument;
    
    Qul::Application app;
    static counter item;
    app.setRootItem(&item);
    app.exec();
}
