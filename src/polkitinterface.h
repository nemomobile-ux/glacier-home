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

#ifndef POLKITINTERFACE_H
#define POLKITINTERFACE_H

#include <polkit-qt5-1/PolkitQt1/Agent/Listener>
#include <polkit-qt5-1/PolkitQt1/Identity>
#include <polkit-qt5-1/PolkitQt1/Subject>
#include <polkit-qt5-1/PolkitQt1/Details>
#include <QObject>
#include <QDebug>
#include <QDBusConnection>

class PolkitInterface : public PolkitQt1::Agent::Listener
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.nemomobile.lipstick.polkitAuthAgent")

    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    Q_PROPERTY(QString user READ user NOTIFY userChanged)

public:
    explicit PolkitInterface(QObject *parent = 0);
    QString message() {return  m_message;}
    QString user() {return m_user;}

signals:
    void openAuthWindow();
    void closeAuthWindow();

    void messageChanged();
    void userChanged();
    void iconChanged();

public slots:
    void initiateAuthentication(const QString &actionId,
                                const QString &message,
                                const QString &iconName,
                                const PolkitQt1::Details &details,
                                const QString &cookie,
                                const PolkitQt1::Identity::List &identities,
                                PolkitQt1::Agent::AsyncResult *result);
    bool initiateAuthenticationFinish();
    void cancelAuthentication();

    void sessionRequest(QString request, bool echo);
    void sessionComplete(bool auth);
    void initSession();

    void accepted(QString password);
    void rejected();
    void setUser(PolkitQt1::Identity newUser);

private:
    QString m_message;
    QString m_user;

    QString m_cookie;

    PolkitQt1::Identity m_currentIdentity;
    PolkitQt1::Agent::AsyncResult* m_asyncResult;
    PolkitQt1::Agent::Session* m_session;

    QString formalizeUser(PolkitQt1::Identity id);
};

#endif // POLKITINTERFACE_H
