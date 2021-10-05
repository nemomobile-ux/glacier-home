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

#include "polkitinterface.h"
#include "polkitagent.h"

PolkitInterface::PolkitInterface(QObject *parent) : PolkitQt1::Agent::Listener(parent)
  ,m_message("")
  ,m_user("")
  ,m_cookie("")
  ,m_currentIdentity(nullptr)
  ,m_asyncResult(nullptr)
  ,m_session(nullptr)
{
    new PolkitAuthAgentAdaptor(this);
    QDBusConnection dbus = QDBusConnection::sessionBus();
    dbus.registerService("org.nemomobile.lipstick.polkitAuthAgent");

    if (!QDBusConnection::sessionBus().registerObject("/org/nemomobile/lipstick/polkitAuthAgent"
                                                      , this,
                                                      QDBusConnection::ExportScriptableSlots |
                                                      QDBusConnection::ExportScriptableProperties |
                                                      QDBusConnection::ExportAdaptors))
    {
        qWarning() << Q_FUNC_INFO << "Could not initiate DBus!";
    }
}

void PolkitInterface::initiateAuthentication(const QString &actionId,
                                             const QString &message,
                                             const QString &iconName,
                                             const PolkitQt1::Details &details,
                                             const QString &cookie,
                                             const PolkitQt1::Identity::List &identities,
                                             PolkitQt1::Agent::AsyncResult *result)
{
    m_currentIdentity = identities.first();
    m_asyncResult = result;
    m_cookie = cookie;

    if(m_message != message) {
        m_message = message;
        emit messageChanged();
    }

    if(m_user != formalizeUser(identities.first())) {
        m_user = formalizeUser(identities.first());
        emit userChanged();
    }

    emit openAuthWindow();
}

bool PolkitInterface::initiateAuthenticationFinish()
{
    return false;
}

void PolkitInterface::cancelAuthentication()
{
    emit closeAuthWindow();
}

void PolkitInterface::sessionRequest(QString request, bool echo)
{
    if (request.startsWith("password:", Qt::CaseInsensitive)) {
        if(m_user != formalizeUser(m_currentIdentity)) {
            m_user = formalizeUser(m_currentIdentity);
            emit userChanged();
        }
    }
}

void PolkitInterface::sessionComplete(bool auth)
{
    if(auth) {
        if(m_session == nullptr) {
            m_asyncResult->setCompleted();
        } else {
            m_session->result()->setCompleted();
            m_session->deleteLater();
        }
        emit closeAuthWindow();
    } else {
        m_session->deleteLater();
        emit openAuthWindow();
    }
    m_session = nullptr;
}

void PolkitInterface::initSession()
{
    m_session = new PolkitQt1::Agent::Session(m_currentIdentity, m_cookie, m_asyncResult, this);
    connect(m_session, &PolkitQt1::Agent::Session::request, this, &PolkitInterface::sessionRequest);
    connect(m_session, &PolkitQt1::Agent::Session::completed, this, &PolkitInterface::sessionComplete);
    m_session->initiate();
}

void PolkitInterface::accepted(QString password)
{
    initSession();
    m_session->setResponse(password);
}

void PolkitInterface::rejected()
{
    m_session->cancel();
}

void PolkitInterface::setUser(PolkitQt1::Identity newUser)
{
    m_currentIdentity = newUser;
}

QString PolkitInterface::formalizeUser(PolkitQt1::Identity id)
{
    return id.toString().remove("unix-user:");
}
