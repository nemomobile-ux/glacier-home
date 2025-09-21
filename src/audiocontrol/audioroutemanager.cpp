#include "audioroutemanager.h"
#include "routemanageradaptor.h"

#include <QDBusConnection>
#include <QDBusError>

AudioRouteManager::AudioRouteManager(QObject* parent)
    : QObject { parent }
{
    QDBusConnection systemBus = QDBusConnection::systemBus();

    m_audioRouteSerice = new AudioRouteService(this);
    new RouteManagerAdaptor(m_audioRouteSerice);

    if (!systemBus.registerObject("/org/nemomobile/Route/Manager", "org.nemomobile.Route.Manager", m_audioRouteSerice)) {
        qWarning() << "Cant register Audio Router Manager";
    }

    if (!systemBus.registerService("org.nemomobile.Route.Manager")) {
        qWarning("Unable to register D-Bus service %s: %s", "org.nemomobile.Route.Manager", systemBus.lastError().message().toUtf8().constData());
    }
}
