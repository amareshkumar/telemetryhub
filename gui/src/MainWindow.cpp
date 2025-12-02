#include "MainWindow.h"
#include "RestClient.h"

#include <QApplication>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QTimer>
#include <QStatusBar>
#include <QMessageBox>
#include <QJsonObject>
#include <QJsonValue>
#include <QPointer>

static QUrl defaultApiBase() {
    const auto env = qEnvironmentVariable("THUB_API_BASE");
    if (!env.isEmpty()) return QUrl(env);
    return QUrl(QStringLiteral("http://127.0.0.1:8080"));
}

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
{
    auto* central = new QWidget(this);
    auto* v = new QVBoxLayout(central);

    auto* stateRow = new QHBoxLayout();
    stateLabel_ = new QLabel("State: (unknown)", central);
    stateRow->addWidget(stateLabel_);

    auto* valueRow = new QHBoxLayout();
    valueLabel_ = new QLabel("Latest: (none)", central);
    valueRow->addWidget(valueLabel_);

    auto* buttons = new QHBoxLayout();
    startButton_ = new QPushButton("Start", central);
    stopButton_  = new QPushButton("Stop", central);
    auto* refreshButton = new QPushButton("Refresh", central);
    buttons->addWidget(startButton_);
    buttons->addWidget(stopButton_);
    buttons->addWidget(refreshButton);

    v->addLayout(stateRow);
    v->addLayout(valueRow);
    v->addLayout(buttons);
    v->addStretch(1);

    setCentralWidget(central);
    setWindowTitle("TelemetryHub - GUI");

    client_ = new RestClient(defaultApiBase(), this);

    connect(startButton_, &QPushButton::clicked, this, &MainWindow::onStartClicked);
    connect(stopButton_,  &QPushButton::clicked, this, &MainWindow::onStopClicked);
    connect(refreshButton, &QPushButton::clicked, this, &MainWindow::onRefresh);

    refreshTimer_ = new QTimer(this);
    refreshTimer_->setInterval(1000);
    connect(refreshTimer_, &QTimer::timeout, this, &MainWindow::onRefresh);
    refreshTimer_->start();

    statusBar()->showMessage("Ready");
    onRefresh();
}

MainWindow::~MainWindow() = default;

void MainWindow::onStartClicked() {
    startButton_->setEnabled(false);
    QPointer<MainWindow> self = this;
    client_->sendStart([self](bool ok, const QString& err){
        if (!self) return; // MainWindow was destroyed
        if (!ok) {
            self->startButton_->setEnabled(true);
            self->statusBar()->showMessage(QStringLiteral("Start failed: ") + err, 3000);
            QMessageBox::warning(self, "Start", err);
        } else {
            self->statusBar()->showMessage("Start sent", 1500);
            // Optimistically reflect expected state until next refresh
            self->startButton_->setEnabled(false);
            self->stopButton_->setEnabled(true);
            self->onRefresh();
        }
    });
}

void MainWindow::onStopClicked() {
    stopButton_->setEnabled(false);
    QPointer<MainWindow> self = this;
    client_->sendStop([self](bool ok, const QString& err){
        if (!self) return; // MainWindow was destroyed
        if (!ok) {
            self->stopButton_->setEnabled(true);
            self->statusBar()->showMessage(QStringLiteral("Stop failed: ") + err, 3000);
            QMessageBox::warning(self, "Stop", err);
        } else {
            self->statusBar()->showMessage("Stop sent", 1500);
            // Optimistically reflect expected state until next refresh
            startButton_->setEnabled(true);
            onRefresh();
        }
    });
}

static QString sampleToText(const QJsonObject& obj) {
    if (obj.isEmpty()) return QStringLiteral("(none)");
    const auto seq = obj.value("seq").toInt();
    const auto val = obj.value("value").toDouble();
    const auto unit = obj.value("unit").toString();
    return QString("#%1  %2 %3").arg(seq).arg(val).arg(unit);
}

void MainWindow::onRefresh() {
    QPointer<MainWindow> self = this;
    client_->getStatus([self](const QJsonObject& json, const QString& err){
        if (!self) return; // MainWindow was destroyed
        if (!err.isEmpty()) {
            self->statusBar()->showMessage(QStringLiteral("Refresh failed: ") + err, 3000);
            return;
        }
        const auto state = json.value("state").toString("unknown");
        self->stateLabel_->setText(QString("State: ") + state);
        // Enable/disable buttons based on device state
        // Idle: can Start; Measuring: can Stop; Error/SafeState: neither action
        const QString s = state.toLower();
        if (s == "idle") {
            self->startButton_->setEnabled(true);
            self->stopButton_->setEnabled(false);
        } else if (s == "measuring") {
            self->startButton_->setEnabled(false);
            self->stopButton_->setEnabled(true);
        } else {
            self->startButton_->setEnabled(false);
            self->stopButton_->setEnabled(false);
        }
        const auto latest = json.value("latest_sample");
        if (latest.isObject()) {
            self->valueLabel_->setText(QString("Latest: ") + sampleToText(latest.toObject()));
        } else {
            self->valueLabel_->setText("Latest: (none)");
        }
    });
}
