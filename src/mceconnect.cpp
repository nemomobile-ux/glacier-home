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

#include "mceconnect.h"

#include <QDBusConnection>

#include <mce/dbus-names.h>
#include <mce/mode-names.h>

MceConnect::MceConnect(QObject* parent)
    : QObject(parent)
    , m_mouseAvailable(false)
    , m_keyboardAvailable(false)
    , m_rebootDialogVisible(false)
{
    QDBusConnection::systemBus().connect(
        QString(),
        QStringLiteral(MCE_SIGNAL_PATH),
        QStringLiteral(MCE_SIGNAL_IF),
        QStringLiteral(MCE_POWER_BUTTON_TRIGGER),
        this,
        SLOT(getPowerKeyAction(QString)));

    QDBusConnection::systemBus().connect(
        QString(),
        QStringLiteral(MCE_SIGNAL_PATH),
        QStringLiteral(MCE_SIGNAL_IF),
        QStringLiteral(MCE_HARDWARE_MOUSE_STATE_GET),
        this,
        SLOT(getMouseAction(QString)));

    QDBusConnection::systemBus().connect(
        QString(),
        QStringLiteral(MCE_SIGNAL_PATH),
        QStringLiteral(MCE_SIGNAL_IF),
        QStringLiteral(MCE_HARDWARE_KEYBOARD_STATE_SIG),
        this,
        SLOT(getKeyboardAction(QString)));
}

void MceConnect::rebootDialogVisible(const bool visible)
{
    if (visible != m_rebootDialogVisible) {
        m_rebootDialogVisible = visible;
        emit rebootDialogVisibleChanged();
    }
}

void MceConnect::getPowerKeyAction(const QString& action)
{
    if (action == QLatin1String("power-key-menu")) {
        emit powerKeyPressed();
    }
}

void MceConnect::getMouseAction(const QString& mouse_state)
{
    bool mouseAvailable;

    if (mouse_state == MCE_HARDWARE_MOUSE_AVAILABLE) {
        mouseAvailable = true;
    } else {
        mouseAvailable = false;
    }

    if (mouseAvailable != m_mouseAvailable) {
        m_mouseAvailable = mouseAvailable;
        emit mouseAvailableChanged();
    }
}

void MceConnect::getKeyboardAction(const QString& keyboard_state)
{
    bool keyboardAvailable;

    if (keyboard_state == MCE_HARDWARE_KEYBOARD_AVAILABLE) {
        keyboardAvailable = true;
    } else {
        keyboardAvailable = false;
    }

    if (keyboardAvailable != m_keyboardAvailable) {
        m_keyboardAvailable = keyboardAvailable;
        emit keyboardAvailableChanged();
    }
}
