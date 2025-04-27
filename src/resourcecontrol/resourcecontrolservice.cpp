#include "resourcecontrolservice.h"
#include <QVariantMap>

ResourceControlService::ResourceControlService(QObject* parent)
    : QObject { parent }
{
}

QVariantMap ResourceControlService::Register(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::acquire(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::advice(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::audio(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::grant(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::release(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::unregister(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::update(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}

QVariantMap ResourceControlService::video(const QVariantMap& send)
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO << send;
    return QVariantMap();
}
