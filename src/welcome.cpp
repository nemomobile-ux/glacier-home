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

}

void Welcome::endWelcome()
{
    QFile doneFile(QStandardPaths::writableLocation(QStandardPaths::HomeLocation)+"/.glacerWelcomeDone");
    doneFile.open(QIODevice::WriteOnly);
    doneFile.close();
}
