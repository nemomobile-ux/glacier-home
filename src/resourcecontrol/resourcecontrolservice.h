#ifndef RESOURCECONTROLSERVICE_H
#define RESOURCECONTROLSERVICE_H

#include <QObject>

class ResourceControlService : public QObject {
    Q_OBJECT
public:
    explicit ResourceControlService(QObject* parent = nullptr);
    QVariantMap Register(const QVariantMap& send);
    QVariantMap acquire(const QVariantMap& send);
    QVariantMap advice(const QVariantMap& send);
    QVariantMap audio(const QVariantMap& send);
    QVariantMap grant(const QVariantMap& send);
    QVariantMap release(const QVariantMap& send);
    QVariantMap unregister(const QVariantMap& send);
    QVariantMap update(const QVariantMap& send);
    QVariantMap video(const QVariantMap& send);
};

#endif // RESOURCECONTROLSERVICE_H
