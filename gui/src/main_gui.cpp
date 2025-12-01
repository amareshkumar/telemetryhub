#include "MainWindow.h"

#include <QApplication>

// Entry point for TelemetryHub GUI application
int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    MainWindow w;
    w.resize(480, 200);
    w.show();
    return app.exec();
}
