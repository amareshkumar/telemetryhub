#pragma once

#include <QMainWindow>
#include <memory>

class QLabel;
class QPushButton;
class QTimer;
class RestClient;

namespace telemetryhub::gateway { class GatewayCore; }

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
    QLabel* stateLabel_ = nullptr;
    QLabel* valueLabel_ = nullptr;
    QPushButton* startButton_ = nullptr;
    QPushButton* stopButton_ = nullptr;
    QTimer* refreshTimer_ = nullptr;
    RestClient* client_ = nullptr;

    // Later: either call REST or a thin client interface
};
