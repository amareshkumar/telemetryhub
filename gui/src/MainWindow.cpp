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
#include <QTableWidget>
#include <QHeaderView>

#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QChart>
#include <QtCharts/QValueAxis>
#include <algorithm>

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
    
    // Setup real-time chart (Level 1 enhancement)
    setupChart();
    v->addWidget(chartView_);
    
    // Setup metrics dashboard (Level 1 enhancement)
    setupMetricsTable();
    v->addWidget(metricsTable_);
    
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

void MainWindow::setupChart() {
    series_ = new QLineSeries(this);
    series_->setName("Telemetry Value");
    
    QChart* chart = new QChart();
    chart->addSeries(series_);
    chart->setTitle("Real-Time Telemetry (Last 60 Samples)");
    chart->setAnimationOptions(QChart::NoAnimation);  // Performance: no animations
    chart->legend()->setVisible(true);
    chart->legend()->setAlignment(Qt::AlignBottom);
    
    // X axis: Sample index
    axisX_ = new QValueAxis();
    axisX_->setTitleText("Sample #");
    axisX_->setRange(0, 60);
    axisX_->setLabelFormat("%d");
    
    // Y axis: Telemetry value (auto-scale)
    axisY_ = new QValueAxis();
    axisY_->setTitleText("Value (arb.units)");
    axisY_->setRange(40, 45);  // Initial range, will auto-scale
    axisY_->setLabelFormat("%.2f");
    
    chart->addAxis(axisX_, Qt::AlignBottom);
    chart->addAxis(axisY_, Qt::AlignLeft);
    series_->attachAxis(axisX_);
    series_->attachAxis(axisY_);
    
    chartView_ = new QChartView(chart, this);
    chartView_->setRenderHint(QPainter::Antialiasing);
    chartView_->setMinimumHeight(300);
}

void MainWindow::updateChart() {
    if (history_.empty()) return;
    
    // Clear and repopulate series
    series_->clear();
    
    const int startIdx = std::max(0, sampleCount_ - 60);
    for (size_t i = 0; i < history_.size(); ++i) {
        series_->append(startIdx + i, history_[i]);
    }
    
    // Auto-scale Y axis based on current data
    const auto [minIt, maxIt] = std::minmax_element(history_.begin(), history_.end());
    if (minIt != history_.end() && maxIt != history_.end()) {
        const double minVal = *minIt;
        const double maxVal = *maxIt;
        const double padding = (maxVal - minVal) * 0.1;  // 10% padding
        axisY_->setRange(minVal - padding, maxVal + padding);
    }
    
    // Update X axis range to show last 60 samples
    if (sampleCount_ > 60) {
        axisX_->setRange(sampleCount_ - 60, sampleCount_);
    } else {
        axisX_->setRange(0, 60);
    }
}

void MainWindow::setupMetricsTable() {
    metricsTable_ = new QTableWidget(7, 2, this);  // 7 rows, 2 columns
    metricsTable_->setHorizontalHeaderLabels({"Metric", "Value"});
    metricsTable_->verticalHeader()->setVisible(false);
    metricsTable_->horizontalHeader()->setStretchLastSection(true);
    metricsTable_->setEditTriggers(QAbstractItemView::NoEditTriggers);  // Read-only
    metricsTable_->setSelectionMode(QAbstractItemView::NoSelection);
    metricsTable_->setMinimumHeight(220);
    metricsTable_->setMaximumHeight(250);
    
    QStringList metrics = {
        "Samples Processed",
        "Samples Dropped",
        "Queue Depth",
        "Pool Jobs Processed",
        "Pool Avg Time (ms)",
        "Thread Pool Size",
        "Uptime"
    };
    
    for (int i = 0; i < metrics.size(); ++i) {
        metricsTable_->setItem(i, 0, new QTableWidgetItem(metrics[i]));
        metricsTable_->setItem(i, 1, new QTableWidgetItem("—"));
    }
    
    // Adjust column widths
    metricsTable_->setColumnWidth(0, 180);
}

void MainWindow::updateMetrics(const QJsonObject& metrics) {
    if (!metricsTable_) return;
    
    // Samples Processed
    if (metrics.contains("samples_processed")) {
        metricsTable_->item(0, 1)->setText(
            QString::number(metrics["samples_processed"].toInt()));
    }
    
    // Samples Dropped
    if (metrics.contains("samples_dropped")) {
        metricsTable_->item(1, 1)->setText(
            QString::number(metrics["samples_dropped"].toInt()));
    }
    
    // Queue Depth (current/max)
    if (metrics.contains("queue_depth") && metrics.contains("queue_capacity")) {
        const int depth = metrics["queue_depth"].toInt();
        const int capacity = metrics["queue_capacity"].toInt();
        metricsTable_->item(2, 1)->setText(
            QString("%1/%2").arg(depth).arg(capacity));
    }
    
    // Pool Jobs Processed
    if (metrics.contains("pool_jobs_processed")) {
        metricsTable_->item(3, 1)->setText(
            QString::number(metrics["pool_jobs_processed"].toInt()));
    }
    
    // Pool Avg Time
    if (metrics.contains("pool_avg_processing_ms")) {
        const double avgMs = metrics["pool_avg_processing_ms"].toDouble();
        metricsTable_->item(4, 1)->setText(
            QString::number(avgMs, 'f', 2));
    }
    
    // Thread Pool Size
    if (metrics.contains("pool_thread_count")) {
        metricsTable_->item(5, 1)->setText(
            QString::number(metrics["pool_thread_count"].toInt()));
    }
    
    // Uptime (convert seconds to HH:MM:SS)
    if (metrics.contains("uptime_seconds")) {
        const int totalSeconds = metrics["uptime_seconds"].toInt();
        const int hours = totalSeconds / 3600;
        const int minutes = (totalSeconds % 3600) / 60;
        const int seconds = totalSeconds % 60;
        metricsTable_->item(6, 1)->setText(
            QString("%1:%2:%3")
                .arg(hours, 2, 10, QChar('0'))
                .arg(minutes, 2, 10, QChar('0'))
                .arg(seconds, 2, 10, QChar('0')));
    }
}

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
            self->startButton_->setEnabled(true);
            self->onRefresh();
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
            const auto obj = latest.toObject();
            self->valueLabel_->setText(QString("Latest: ") + sampleToText(obj));
            
            // Update chart with new sample value
            const double value = obj.value("value").toDouble();
            self->history_.push_back(value);
            if (self->history_.size() > 60) {
                self->history_.pop_front();
            }
            self->sampleCount_++;
            self->updateChart();
        } else {
            self->valueLabel_->setText("Latest: (none)");
        }
    });
    
    // Fetch metrics (Level 1 enhancement)
    client_->getMetrics([self](const QJsonObject& metrics, const QString& err){
        if (!self) return;
        if (!err.isEmpty()) return;  // Silently fail (metrics are optional)
        self->updateMetrics(metrics);
    });
}
