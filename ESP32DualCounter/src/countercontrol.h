// Copyright (C) 2025 Jim Frangione
// Counter Control Interface
#pragma once

#include <qul/singleton.h>
#include <qul/property.h>
#include <qul/eventqueue.h>

enum class CounterEventId { Counter1Update, Counter2Update };

struct CounterEvent
{
    CounterEventId id;
    int value;
};

class CounterControl : public Qul::Singleton<CounterControl>
{
public:
    CounterControl();
    Qul::Property<int> counter1Value;
    Qul::Property<int> counter2Value;
    
    void setCounter1Running(bool running);
    void setCounter2Running(bool running);
};

class CounterEventQueue : public Qul::EventQueue<CounterEvent>
{
    void onEvent(const CounterEvent &event) override;
};

// FreeRTOS queue functions
void initCounterQueues();
CounterEventQueue *getCounterEventQueue();
