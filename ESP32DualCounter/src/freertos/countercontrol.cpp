// Copyright (C) 2025 Jim Frangione
// Counter Control Implementation for FreeRTOS
#include "countercontrol.h"
#include "counter_threads.h"

#include <FreeRTOS.h>
#include <queue.h>

static CounterEventQueue counterEventQueue;
static QueueHandle_t counter1Queue = NULL;
static QueueHandle_t counter2Queue = NULL;

void initCounterQueues()
{
    counter1Queue = xQueueCreate(1, sizeof(bool));
    counter2Queue = xQueueCreate(1, sizeof(bool));
}

QueueHandle_t getCounter1Queue()
{
    return counter1Queue;
}

QueueHandle_t getCounter2Queue()
{
    return counter2Queue;
}

CounterEventQueue *getCounterEventQueue()
{
    return &counterEventQueue;
}

CounterControl::CounterControl()
    : counter1Value(0)
    , counter2Value(0)
{
}

void CounterControl::setCounter1Running(bool running)
{
    if (counter1Queue != NULL) {
        xQueueOverwrite(counter1Queue, &running);
    }
}

void CounterControl::setCounter2Running(bool running)
{
    if (counter2Queue != NULL) {
        xQueueOverwrite(counter2Queue, &running);
    }
}

void CounterEventQueue::onEvent(const CounterEvent &event)
{
    switch (event.id) {
    case CounterEventId::Counter1Update:
        CounterControl::instance().counter1Value.setValue(event.value);
        break;
    case CounterEventId::Counter2Update:
        CounterControl::instance().counter2Value.setValue(event.value);
        break;
    }
}
