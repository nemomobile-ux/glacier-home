#include "resourcecontrolmanager.h"
#include "resourcecontroladaptor.h"

#include <QDBusConnection>
#include <QDBusError>

ResourceControlManager::ResourceControlManager(QObject* parent)
    : QObject { parent }
{
    QDBusConnection systemBus = QDBusConnection::systemBus();
    m_resourceControlServce = new ResourceControlService(this);
    new ResourCecontrolAdaptor(m_resourceControlServce);

    if (!systemBus.registerObject("/org/maemo/resource/manager", "org.maemo.resource.manager", m_resourceControlServce)) {
        qWarning() << "Cant register Resource Control Manager";
    }

    if (!systemBus.registerService("org.maemo.resource.manager")) {
        qWarning("Unable to register D-Bus service %s: %s", "org.maemo.resource.manager", systemBus.lastError().message().toUtf8().constData());
    }
}
