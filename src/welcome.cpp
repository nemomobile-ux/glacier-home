#include "welcome.h"
#include <QDBusPendingCall>
#include <QDBusVariant>
#include <QFile>
#include <QDebug>
#include <QStandardPaths>

Welcome::Welcome()
{
    QFile doneFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation)+"/.glacerWelcomeDone");
    m_needToStart = !doneFile.exists();
    qDebug() << QStandardPaths::writableLocation(QStandardPaths::HomeLocation)+"/.glacerWelcomeDone";
    m_mceDbus = new QDBusInterface("com.nokia.mce", "/com/nokia/mce/request", "com.nokia.mce.request", QDBusConnection::systemBus());
}

bool Welcome::isFirstRun()
{
    return m_needToStart;
}

void Welcome::startWelcome()
{
    m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/display/inhibit_blank_mode").path(), QVariant::fromValue(QDBusVariant(3)));
    m_mceDbus->asyncCall("req_tklock_mode_change", "unlocked");
    m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/locks/tklock_blank_disable").path(), QVariant::fromValue(QDBusVariant(1)));
}

void Welcome::endWelcome()
{
    m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/display/inhibit_blank_mode").path(), QVariant::fromValue(QDBusVariant(0)));
    m_mceDbus->asyncCall("req_tklock_mode_change", "locked");
    m_mceDbus->asyncCall("set_config", QDBusObjectPath("/system/osso/dsm/locks/tklock_blank_disable").path(), QVariant::fromValue(QDBusVariant(0)));

    QFile doneFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation)+"/.glacerWelcomeDone");
    doneFile.open(QIODevice::WriteOnly);
    doneFile.close();
}
