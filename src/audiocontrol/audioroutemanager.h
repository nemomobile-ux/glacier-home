#ifndef AUDIOROUTEMANAGER_H
#define AUDIOROUTEMANAGER_H

#include <QObject>
#include "audiorouteservice.h"

class AudioRouteManager : public QObject {
    Q_OBJECT
public:
    explicit AudioRouteManager(QObject* parent = nullptr);

private:
    AudioRouteService* m_audioRouteSerice;
};

#endif // AUDIOROUTEMANAGER_H
