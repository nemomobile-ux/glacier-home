#ifndef AUDIOROUTESERVICE_H
#define AUDIOROUTESERVICE_H

#include <QObject>

class AudioRouteService : public QObject {
    Q_OBJECT

public:
    explicit AudioRouteService(QObject* parent = nullptr);
    QString ActiveRoutes(uint& output_device_type, QString& input_device, uint& input_device_type);
    QString GetAll(uint& output_device_type, QString& input_device, uint& input_device_type, QVariantMap& features);

    void Disable(const QString& feature);
    void Enable(const QString& feature);
    void Prefer(const QString& device);

    QStringList Features();
    QStringList FeaturesAllowed();
    QStringList FeaturesEnabled();
    uint InterfaceVersion();

    QVariantMap Routes();
    QVariantMap RoutesFiltered(uint filter);
};

#endif // AUDIOROUTESERVICE_H
