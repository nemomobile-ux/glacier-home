/****************************************************************************************
**
** Copyright (C) 2021 Chupligin Sergey <neochapay@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

#include "geoclueagent.h"
#include "geoagent.h"

#include <MGConfItem>

GeoclueAgent::GeoclueAgent(QObject* parent)
    : m_inUse(false)
    , m_authRequest(true)
{
    QDBusConnection::systemBus().interface()->startService("org.freedesktop.GeoClue2");
    new AgentAdaptor(this);

    QDBusConnection dbus = QDBusConnection::systemBus();
    dbus.registerObject("/org/freedesktop/GeoClue2/Agent", "org.freedesktop.GeoClue2.Agent", this);

    MGConfItem* locationEnabledItem = new MGConfItem(QStringLiteral("/home/glacier/loaction/enabled"));
    MGConfItem* loactionLevelItem = new MGConfItem(QStringLiteral("/home/glacier/loaction/level"));

    connect(locationEnabledItem, &MGConfItem::valueChanged, this, &GeoclueAgent::locationEnabledItemChanded);
    connect(loactionLevelItem, &MGConfItem::valueChanged, this, &GeoclueAgent::loactionLevelItemChanged);

    m_locationEnabled = MGConfItem(QStringLiteral("/home/glacier/loaction/enabled")).value(0).toBool();
    m_locationLevel = MGConfItem(QStringLiteral("/home/glacier/loaction/level")).value(0).toUInt();

    authorizationRequest();

    QDBusServiceWatcher* watcher = new QDBusServiceWatcher("org.freedesktop.GeoClue2",
        QDBusConnection::systemBus());
    connect(watcher, &QDBusServiceWatcher::serviceRegistered, this, &GeoclueAgent::onServiceRegistred);
    connect(watcher, &QDBusServiceWatcher::serviceUnregistered, this, &GeoclueAgent::onServiceUnregistred);

    QDBusConnection::systemBus().connect("org.freedesktop.GeoClue2",
        "/org/freedesktop/GeoClue2/Manager",
        "org.freedesktop.DBus.Properties",
        "PropertiesChanged",
        this,
        SLOT(propertiesChanged(QString, QVariantMap)));
}

uint GeoclueAgent::MaxAccuracyLevel()
{
    /*@todo allow setup mode
     * now 0 - disabled other - enabled
     */
    if (!m_locationEnabled) {
        return 0;
    }
    /*@todo allow setup mode */

    /*
     * GCLUE_ACCURACY_LEVEL_NONE            Accuracy level unknown or unset.
     * GCLUE_ACCURACY_LEVEL_COUNTRY         Country-level accuracy.
     * GCLUE_ACCURACY_LEVEL_CITY            City-level accuracy.
     * GCLUE_ACCURACY_LEVEL_NEIGHBORHOOD    neighborhood-level accuracy.
     * GCLUE_ACCURACY_LEVEL_STREET          Street-level accuracy.
     * GCLUE_ACCURACY_LEVEL_EXACT           Exact accuracy. Typically requires GPS receiver.
     */

    return 6;
}

bool GeoclueAgent::AuthorizeApp(QString desktop_id, uint req_accuracy_level, uint& allowed_accuracy_level)
{
    allowed_accuracy_level = req_accuracy_level;
    return true;
}

bool GeoclueAgent::requiresAuthorization()
{
    return m_authRequest;
}

void GeoclueAgent::propertiesChanged(QString interface, QVariantMap properties)
{
    if (interface == "org.freedesktop.GeoClue2.Manager") {
        if (properties.contains("InUse")) {
            bool currentInUse = std::find(properties.cbegin(), properties.cend(), "InUse")->toBool();

            if (currentInUse != m_inUse) {
                m_inUse = currentInUse;
                emit inUseChanged(m_inUse);
            }
        }
    }
}

void GeoclueAgent::locationEnabledItemChanded()
{
    m_locationEnabled = MGConfItem(QStringLiteral("/home/glacier/loaction/enabled")).value(0).toBool();
    deleteClient(); // to update currect values we need to reload clients
}

void GeoclueAgent::loactionLevelItemChanged()
{
    m_locationLevel = MGConfItem(QStringLiteral("/home/glacier/loaction/level")).value(0).toUInt();
    deleteClient(); // to update currect values we need to reload clients
}

void GeoclueAgent::onServiceRegistred(const QString& service)
{
    m_authRequest = true;
    authorizationRequest();
}

void GeoclueAgent::onServiceUnregistred(const QString& service)
{
    if (!m_authRequest) {
        qDebug() << "Trying restart geoclue";
        QDBusConnection::systemBus().interface()->startService("org.freedesktop.GeoClue2");
    }
}

void GeoclueAgent::authorizationRequestAnswer(QDBusPendingCallWatcher* call)
{
    QDBusPendingReply<void> reply = *call;

    if (reply.isError()) {
        if (reply.error().name() == "org.freedesktop.DBus.Error.AccessDenied") {
            m_authRequest = true;
            return;
        }
    } else {
        QDBusMessage clientMessage = QDBusMessage::createMethodCall("org.freedesktop.GeoClue2",
            "/org/freedesktop/GeoClue2/Manager",
            "org.freedesktop.GeoClue2.Manager",
            "GetClient");
        QDBusConnection::systemBus().asyncCall(clientMessage);
        m_authRequest = false;
    }

    call->deleteLater();
}

void GeoclueAgent::authorizationRequest()
{
    QDBusMessage agentMessage = QDBusMessage::createMethodCall(
        "org.freedesktop.GeoClue2",
        "/org/freedesktop/GeoClue2/Manager",
        "org.freedesktop.GeoClue2.Manager",
        "AddAgent");

    QList<QVariant> args;
    args.append("lipstick");

    agentMessage.setArguments(args);

    QDBusPendingCall authRequiestMessage = QDBusConnection::systemBus().asyncCall(agentMessage);
    QDBusPendingCallWatcher* watcher = new QDBusPendingCallWatcher(authRequiestMessage);

    connect(watcher, &QDBusPendingCallWatcher::finished, this, &GeoclueAgent::authorizationRequestAnswer);
}

void GeoclueAgent::deleteClient()
{
    QDBusMessage deleteClientMessage = QDBusMessage::createMethodCall("org.freedesktop.GeoClue2",
        "/org/freedesktop/GeoClue2/Manager",
        "org.freedesktop.GeoClue2.Manager",
        "DeleteClient");
    QDBusConnection::systemBus().asyncCall(deleteClientMessage);
    m_authRequest = true;
    authorizationRequest();
}
