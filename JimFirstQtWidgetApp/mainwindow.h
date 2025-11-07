#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "workerthread.h"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onThread1CheckboxToggled(bool checked);
    void onThread2CheckboxToggled(bool checked);
    void onThread1CounterUpdated(int value);
    void onThread2CounterUpdated(int value);

private:
    Ui::MainWindow *ui;
    WorkerThread *m_thread1;
    WorkerThread *m_thread2;
};
#endif // MAINWINDOW_H
