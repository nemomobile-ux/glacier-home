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

import Nemo.DBus 2.0

import "controlcenter"
import "statusbar"

import "scripts/desktop.js" as Desktop

Item{
    id: controlCenterArea

    width: desktop.isUiPortrait ? Desktop.instance.width : Desktop.instance.height
    anchors.horizontalCenter: parent.horizontalCenter

    height: 0
    visible: height > 0

    clip: true

    function down() {
        controlCenterArea.height = 0
        Desktop.compositor.state = ""
    }

    function openSettingsPage(plugin,extended) {
        settingsInterface.call("openSettingsPage",[plugin, extended])
    }

    onHeightChanged: {
        if(height != (desktop.isUiPortrait ? Desktop.instance.width : Desktop.instance.height)) {
            hiderTimer.restart()
        } else {
            hiderTimer.stop()
        }
    }


    DBusInterface {
        id: settingsInterface

        service: "org.nemomobile.qmlsettings"
        path: "/"
        iface: "org.nemomobile.qmlsettings"

        signalsEnabled: true
    }

    Timer{
        id: hiderTimer
        repeat: false
        running: false
        interval: 5000
        onTriggered: {
            down()
        }
    }

    Rectangle{
        id: controlCenterOutAreaDim
        anchors.fill: parent
        color: Theme.backgroundColor
    }

    InverseMouseArea{
        anchors.fill: parent
        enabled: controlCenterArea.height > 0
        parent: controlCenterArea

        onPressed: {
            controlCenterArea.height = 0
        }
    }

    Rectangle {
        id: controlCenter
        width: parent.width
        height: parent.width
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

            WiFiButton{
                id: wifiButton
            }

            BluetoothButton{
                id: bluetoothButton
            }

            CellularDataControlButton{
                id: cellularDataControlButton
            }

            LocationControlButton{
                id: locationControlButton
            }

            QuietControlButton{
                id: quietControlButton
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
/*Little hack for hide control center*/
    MouseArea{
        id: backgroundMouseArea
        width: parent.width
        height: parent.height-controlCenter.height
        anchors.top: controlCenter.bottom

        property int pMouse: 0

        onPressed: {
            backgroundMouseArea.pMouse = backgroundMouseArea.mouseY
        }
        onReleased: {
            if(pMouse-backgroundMouseArea.mouseY >= Theme.itemHeightHuge){
                controlCenterArea.down()
            }
            pMouse = 0;
        }
    }

    Behavior on height {
        NumberAnimation { duration: 300 }
    }
}

