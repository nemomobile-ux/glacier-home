#include "mceconnect.h"

#include <QDBusConnection>

MceConnect::MceConnect(QObject *parent) :
    QObject(parent)
{
    QDBusConnection::systemBus().connect(
                    QString(),
                    QStringLiteral("/com/nokia/mce/signal"),
                    QStringLiteral("com.nokia.mce.signal"),
                    QStringLiteral("power_button_trigger"),
                    this,
                    SLOT(getAction(QString)));

}

void MceConnect::getAction(const QString &action)
{
    if (action == QLatin1String("power-key-menu")) {
        emit powerKeyPressed();
    }
}

