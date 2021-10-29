/****************************************************************************************
**
** Copyright (C) 2017 Samuel Pavlovic <sam@volvosoftware.com>
** Copyright (C) 2020-2021 Chupligin Sergey <neochapay@gmail.com>
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

import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtGraphicalEffects 1.0

import org.nemomobile.statusnotifier 1.0
import org.nemomobile.glacier 1.0

import Nemo.DBus 2.0

import "../statusbar"

Item{
    id: controlCenterArea
    clip: true
    width: parent.width
    height: childrenRect.height

    function openSettingsPage(plugin,extended) {
        settingsInterface.call("openSettingsPage",[plugin, extended])
    }

    ControlCenterButtonsModel{
        id: controlCenterButtonModel
    }

    DBusInterface {
        id: settingsInterface

        service: "org.nemomobile.qmlsettings"
        path: "/"
        iface: "org.nemomobile.qmlsettings"

        signalsEnabled: true
    }

    Rectangle {
        id: controlCenter
        width: parent.width
        height: childrenRect.height
        color: "transparent"

        Grid {
            id: fastActions

            columns: 5
            clip: true

            anchors{
                top: parent.top
                topMargin: Theme.itemSpacingSmall
                left: parent.left
            }

            width: parent.width
            height: Theme.itemHeightHuge + Theme.fontSizeTiny*3 + Theme.itemSpacingSmall*2
            spacing: Theme.itemSpacingSmall
            leftPadding: (fastActions.width-Theme.itemSpacingSmall*fastActions.columns-Theme.itemHeightHuge*fastActions.columns)/2

            Repeater{
                id: buttonRepeater
                model: controlCenterButtonModel
                delegate: Loader{
                    source: "/usr/share/lipstick-glacier-home-qt5/qml/feedspage/"+path+".qml"
                }
            }
        }

        Grid{
            id: statusIcons

            columns: Math.round(parent.width/Theme.itemHeightSmall)
            width: parent.width
            height: Theme.itemHeightSmall-Theme.itemSpacingSmall*2

            spacing: Theme.itemSpacingSmall
            clip: true

            anchors{
                top: fastActions.bottom
                topMargin: Theme.itemSpacingSmall
                left: parent.left
                leftMargin: Theme.itemSpacingSmall
            }

            Repeater{
                id: statusIconsRepeator
                model: statusNotiferModel

                delegate: StatusbarItem{
                    iconSize: statusIcons.height
                    source: notifierItem.icon
                }
            }
        }
    }
}

