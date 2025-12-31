#pragma once

#include <QMainWindow>
#include <memory>
#include <deque>

class QLabel;
class QPushButton;
class QTimer;
class RestClient;
class QChartView;
class QLineSeries;
class QValueAxis;

namespace telemetryhub::gateway { class GatewayCore; }

// UI skeleton for TelemetryHub GUI
class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() override;

private slots:
    void onStartClicked();
    void onStopClicked();
    void onRefresh();

private:
    void setupChart();
    void updateChart();

    QLabel* stateLabel_ = nullptr;
    QLabel* valueLabel_ = nullptr;
    QPushButton* startButton_ = nullptr;
    QPushButton* stopButton_ = nullptr;
    QTimer* refreshTimer_ = nullptr;
    RestClient* client_ = nullptr;

    // Real-time chart (Level 1 enhancement)
    QChartView* chartView_ = nullptr;
    QLineSeries* series_ = nullptr;
    QValueAxis* axisX_ = nullptr;
    QValueAxis* axisY_ = nullptr;
    std::deque<double> history_;  // Last 60 samples
    int sampleCount_ = 0;

    // Later: either call REST or a thin client interface
};
