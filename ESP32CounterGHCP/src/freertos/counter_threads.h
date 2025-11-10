// Copyright (C) 2025 Jim Frangione
// Counter Threads for FreeRTOS
#pragma once

#include <FreeRTOS.h>
#include <queue.h>
#include "../countercontrol.h"

void initCounterQueues();
QueueHandle_t getCounter1Queue();
QueueHandle_t getCounter2Queue();
CounterEventQueue *getCounterEventQueue();

void Counter1_Thread(void *argument);
void Counter2_Thread(void *argument);
void Qul_Thread(void *argument);
