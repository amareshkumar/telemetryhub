#pragma once

#include <QObject>
#include <QUrl>
#include <QJsonObject>
#include <functional>

class QNetworkAccessManager;
class QNetworkReply;

// Thin REST client for TelemetryHub API
class RestClient : public QObject {
    Q_OBJECT
public:
    explicit RestClient(const QUrl& baseUrl, QObject* parent = nullptr);

    // Callbacks receive (success payload, error string). For getStatus, success is JSON object.
    void getStatus(std::function<void(const QJsonObject&, const QString&)> onDone);
    void getMetrics(std::function<void(const QJsonObject&, const QString&)> onDone);
    void sendStart(std::function<void(bool, const QString&)> onDone);
    void sendStop(std::function<void(bool, const QString&)> onDone);

private:
    void doPost(const QString& path, std::function<void(bool, const QString&)> onDone);

    QUrl base_;
    QNetworkAccessManager* nam_;
};
