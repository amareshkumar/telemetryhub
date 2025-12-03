#include "RestClient.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <stdexcept>

RestClient::RestClient(const QUrl& baseUrl, QObject* parent)
    : QObject(parent), base_(baseUrl), nam_(new QNetworkAccessManager(this)) {
    if (base_.isEmpty() || !base_.isValid()) {
        throw std::invalid_argument("RestClient: baseUrl must be a valid, non-empty URL");
    }
    if (base_.scheme().isEmpty() || (base_.scheme() != QStringLiteral("http") && base_.scheme() != QStringLiteral("https"))) {
        throw std::invalid_argument("RestClient: baseUrl must use http or https scheme");
    }
}

void RestClient::getStatus(std::function<void(const QJsonObject&, const QString&)> onDone) {
    QUrl url = base_.resolved(QUrl("/status"));
    QNetworkRequest req(url);
    auto* reply = nam_->get(req);

    QObject::connect(reply, &QNetworkReply::finished, reply, [reply, onDone]() {
        const auto status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (reply->error() != QNetworkReply::NoError) {
            onDone(QJsonObject{}, QString::fromUtf8("HTTP error %1: %2").arg(status).arg(reply->errorString()));
        } else {
            const auto data = reply->readAll();
            auto doc = QJsonDocument::fromJson(data);
            if (!doc.isObject()) {
                onDone(QJsonObject{}, QStringLiteral("Malformed JSON in /status"));
            } else {
                onDone(doc.object(), QString());
            }
        }
        reply->deleteLater();
    });
}

void RestClient::sendStart(std::function<void(bool, const QString&)> onDone) {
    doPost("/start", std::move(onDone));
}

void RestClient::sendStop(std::function<void(bool, const QString&)> onDone) {
    doPost("/stop", std::move(onDone));
}

void RestClient::doPost(const QString& path, std::function<void(bool, const QString&)> onDone) {
    QUrl url = base_.resolved(QUrl(path));
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    auto* reply = nam_->post(req, QByteArray("{}"));

    QObject::connect(reply, &QNetworkReply::finished, reply, [reply, onDone]() {
        const auto status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const auto data = reply->readAll();
        if (reply->error() != QNetworkReply::NoError) {
            onDone(false, QString::fromUtf8("HTTP error %1: %2").arg(status).arg(reply->errorString()));
        } else if (status < 200 || status >= 300) {
            onDone(false, QString::fromUtf8("Unexpected HTTP status %1").arg(status));
        } else {
            auto doc = QJsonDocument::fromJson(data);
            if (!doc.isObject()) {
                onDone(false, QStringLiteral("Malformed JSON in response"));
            } else {
                QJsonObject obj = doc.object();
                if (obj.value("ok").toBool(false)) {
                    onDone(true, QString());
                } else {
                    onDone(false, QStringLiteral("Operation failed: missing or false 'ok' field"));
                }
            }
        }
        reply->deleteLater();
    });
}
