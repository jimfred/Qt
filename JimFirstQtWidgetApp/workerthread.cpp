#include "workerthread.h"
#include <QThread>

WorkerThread::WorkerThread(QObject *parent)
    : QThread(parent)
    , m_running(false)
    , m_counter(0)
{
}

WorkerThread::~WorkerThread()
{
    stopThread();
    wait(); // Wait for thread to finish
}

void WorkerThread::stopThread()
{
    QMutexLocker locker(&m_mutex);
    m_running = false;
}

void WorkerThread::run()
{
    {
        QMutexLocker locker(&m_mutex);
        m_running = true;
        m_counter = 0;
    }

    while (true) {
        {
            QMutexLocker locker(&m_mutex);
            if (!m_running) {
                break;
            }
            m_counter++;
            emit counterUpdated(m_counter);
        }

        // Sleep for 100ms to make counting visible
        msleep(100);
    }
}
