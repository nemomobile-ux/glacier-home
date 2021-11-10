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

#ifndef MCECONNECT_H
#define MCECONNECT_H

#include <QObject>

class MceConnect : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool mouseAvailable READ mouseAvailable NOTIFY mouseAvailableChanged)
    Q_PROPERTY(bool keyboardeAvailable READ keyboardAvailable NOTIFY keyboardAvailableChanged)

public:
    explicit MceConnect(QObject *parent = 0);
    bool mouseAvailable() {return m_mouseAvailable;}
    bool keyboardAvailable() {return m_keyboardAvailable;}

signals:
    void powerKeyPressed();
    void mouseAvailableChanged();
    void keyboardAvailableChanged();

private slots:
    void getPowerKeyAction(const QString &action);
    void getMouseAction(const QString &mouse_state);
    void getKeyboardAction(const QString &keyboard_state);

private:
    bool m_mouseAvailable;
    bool m_keyboardAvailable;
};

#endif // MCECONNECT_H
