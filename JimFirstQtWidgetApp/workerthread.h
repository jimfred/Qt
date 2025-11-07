#ifndef WORKERTHREAD_H
#define WORKERTHREAD_H

#include <QThread>
#include <QMutex>

class WorkerThread : public QThread
{
    Q_OBJECT

public:
    explicit WorkerThread(QObject *parent = nullptr);
    ~WorkerThread();

    void stopThread();

signals:
    void counterUpdated(int value);

protected:
    void run() override;

private:
    QMutex m_mutex;
    bool m_running;
    int m_counter;
};

#endif // WORKERTHREAD_H
