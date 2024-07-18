#include "audiorouteservice.h"
#include <QDebug>
#include <QVariantMap>

AudioRouteService::AudioRouteService(QObject* parent)
    : QObject(parent)
{
}

QString AudioRouteService::ActiveRoutes(uint& output_device_type, QString& input_device, uint& input_device_type)
{
    qDebug() << output_device_type;
    qDebug() << input_device;
    qDebug() << input_device_type;

    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return "";
}

QString AudioRouteService::GetAll(uint& output_device_type, QString& input_device, uint& input_device_type, QVariantMap& features)
{
    qDebug() << output_device_type;
    qDebug() << input_device;
    qDebug() << input_device_type;
    qDebug() << features;

    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return "";
}

void AudioRouteService::Disable(const QString& feature)
{
    qDebug() << feature;
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
}

void AudioRouteService::Enable(const QString& feature)
{
    qDebug() << feature;
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
}

void AudioRouteService::Prefer(const QString& device)
{
    qDebug() << device;
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
}

QStringList AudioRouteService::Features()
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    QStringList features = QStringList() << "bluetooth_override"
                                         << "speaker"
                                         << "voicecallrecord"
                                         << "fmradioloopback"
                                         << "fmradio"
                                         << "emergencycall";

    return features;
}

QStringList AudioRouteService::FeaturesAllowed()
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return QStringList();
}

QStringList AudioRouteService::FeaturesEnabled()
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return QStringList();
}

uint AudioRouteService::InterfaceVersion()
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return 0;
}

QVariantMap AudioRouteService::Routes()
{
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return QVariantMap();
}

QVariantMap AudioRouteService::RoutesFiltered(uint filter)
{
    qDebug() << filter;
    qWarning() << "NOT IMPLEMENTED YEAT" << Q_FUNC_INFO;
    return QVariantMap();
}
