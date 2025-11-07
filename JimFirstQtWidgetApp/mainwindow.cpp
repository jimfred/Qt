#include "mainwindow.h"
#include "./ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_thread1(nullptr)
    , m_thread2(nullptr)
{
    ui->setupUi(this);

    // Create worker threads
    m_thread1 = new WorkerThread(this);
    m_thread2 = new WorkerThread(this);

    // Connect checkbox signals to slots
    connect(ui->thread1Checkbox, &QCheckBox::toggled,
            this, &MainWindow::onThread1CheckboxToggled);
    connect(ui->thread2Checkbox, &QCheckBox::toggled,
            this, &MainWindow::onThread2CheckboxToggled);

    // Connect thread counter signals to UI update slots
    connect(m_thread1, &WorkerThread::counterUpdated,
            this, &MainWindow::onThread1CounterUpdated);
    connect(m_thread2, &WorkerThread::counterUpdated,
            this, &MainWindow::onThread2CounterUpdated);

    // Initialize counter displays
    ui->thread1Counter->display(0);
    ui->thread2Counter->display(0);
}

MainWindow::~MainWindow()
{
    // Stop threads before destruction
    if (m_thread1 && m_thread1->isRunning()) {
        m_thread1->stopThread();
        m_thread1->wait();
    }
    if (m_thread2 && m_thread2->isRunning()) {
        m_thread2->stopThread();
        m_thread2->wait();
    }

    delete ui;
}

void MainWindow::onThread1CheckboxToggled(bool checked)
{
    if (checked) {
        if (!m_thread1->isRunning()) {
            m_thread1->start();
        }
    } else {
        if (m_thread1->isRunning()) {
            m_thread1->stopThread();
        }
    }
}

void MainWindow::onThread2CheckboxToggled(bool checked)
{
    if (checked) {
        if (!m_thread2->isRunning()) {
            m_thread2->start();
        }
    } else {
        if (m_thread2->isRunning()) {
            m_thread2->stopThread();
        }
    }
}

void MainWindow::onThread1CounterUpdated(int value)
{
    ui->thread1Counter->display(value);
}

void MainWindow::onThread2CounterUpdated(int value)
{
    ui->thread2Counter->display(value);
}
