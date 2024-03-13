#ifndef AUDIOROUTEMANAGER_H
#define AUDIOROUTEMANAGER_H

#include "audiorouteservice.h"
#include <QObject>

class AudioRouteManager : public QObject {
    Q_OBJECT
public:
    explicit AudioRouteManager(QObject* parent = nullptr);

private:
    AudioRouteService* m_audioRouteSerice;
};

#endif // AUDIOROUTEMANAGER_H
