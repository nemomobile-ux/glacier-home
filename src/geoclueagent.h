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
#ifndef GEOCLUE_AGENT_H
#define GEOCLUE_AGENT_H

#include <QObject>
#include <QDBusMessage>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusServiceWatcher>
#include <QDebug>
#include <QDBusPendingCall>

class GeoclueAgent : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.GeoClue2.Agent")
    Q_PROPERTY(bool inUse READ inUse NOTIFY inUseChanged)
    Q_SCRIPTABLE Q_PROPERTY(uint MaxAccuracyLevel READ MaxAccuracyLevel)

public:
    explicit GeoclueAgent (QObject *parent = nullptr);
    uint MaxAccuracyLevel();
    bool inUse() {return  m_inUse;}

signals:
    void inUseChanged(bool inUse);

public slots:
    Q_SCRIPTABLE bool AuthorizeApp(QString desktop_id, uint req_accuracy_level, uint &allowed_accuracy_level);
    bool requiresAuthorization();

    void locationEnabledItemChanded();
    void loactionLevelItemChanged();

private slots:
    void onServiceRegistred(const QString &service);
    void onServiceUnregistred(const QString &service);
    void authorizationRequestAnswer(QDBusPendingCallWatcher *call);
    void propertiesChanged(QString interface, QVariantMap properties);
private:
    void authorizationRequest();
    void deleteClient();

    bool m_inUse;
    bool m_authRequest;

    bool m_locationEnabled;
    uint m_locationLevel;
};
#endif
