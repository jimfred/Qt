// Copyright (C) 2025 Jim Frangione
// Qul Thread Implementation

#include "qul_thread.h"
#include "countercontrol.h"

#include <qul/application.h>
#include <qul/qul.h>

#include <FreeRTOS.h>
#include <task.h>
#include <queue.h>

// Generated QML file
#include <counter.h>

// Post events to UI thread (called from counter threads)
void postCounterEventsToUI(CounterEvent &event)
{
    CounterEventQueue *queue = getCounterEventQueue();
    queue->postEvent(event);
}

void Qul_Thread(void *argument)
{
    (void) argument;
    Qul::Application app;
    static counter item;
    app.setRootItem(&item);
    app.exec();
}
