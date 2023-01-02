/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2017-2021 Sergey Chupligin <mail@neochapay.ru>
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
import QtQuick.Layouts 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.mpris 1.0
import org.nemomobile.statusnotifier 1.0

import "statusbar"

Item {
    id: root
    z: 198
    height: Theme.itemHeightSmall
    width: parent.width
    anchors.top: parent.top

    property real opacityStart: 0.0

    Rectangle {
        id: statusbarPadding
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 1.0; color: "transparent" }
            GradientStop {
                position: opacityStart;
                color: Qt.rgba(0,0,0,0.6)
            }
        }
    }

    Rectangle {
        id: statusbarPressFeedback
        anchors.fill: parent
        visible: false
        color: "black"
        opacity: 0.5
        z:202
    }

    Item {
        id: statusbarLeft
        height: parent.height*0.5
        width:  parent.width*0.5
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: statusbarLeft.height/2
        }

        Row {
            id: notifyIconArea
            anchors.fill: statusbarLeft
            spacing: statusbarLeft.height / 3

            Repeater{
                id: statusesRepeater
                model: statusNotiferModel

                delegate: StatusbarItem{
                    iconSize: statusbarLeft.height
                    source: notifierItem.icon
                    visible: notifierItem.status !== StatusNotifierItem.PassiveStatus
                }
            }
        }
    }


    Item {
        id: statusbarRight
        height: parent.height*0.5
        width:  parent.width*0.5
        anchors{
            verticalCenter: statusbarLeft.verticalCenter
            right: parent.right
            rightMargin: statusbarRight.height/2
        }

        Row {
            id: rightStatusBar
            width: parent.width
            height: parent.height

            spacing: statusbarRight.height / 3
            layoutDirection: Qt.RightToLeft

            Item {
                id: clock
                width: hours.width
                height: statusbarLeft.height

                Text {
                    id: hours
                    wrapMode: Text.WrapAnywhere
                    font.pixelSize: statusbarRight.height
                    color: Theme.textColor
                    height: statusbarLeft.height

                    verticalAlignment: Text.AlignVCenter

                    text: {
                        //Todo: Get regional settings
                        var separator = ":"
                        return Qt.formatDateTime(wallClock.time, "hh") + separator + Qt.formatDateTime(wallClock.time, "mm")
                    }
                }
            }

            BatteryIndicator{
                id: batteryIndicator
            }

            PowerSaveModeIndicator{
                id: powerSaveModeIndicator
            }

            SimIndicator{
                id: simIndicator
            }

            DataStatusItem{
                id: dataStatus
            }

            WifiIndicator{
                id: wifiStatus
            }

            BluetoothIndicator{
                id: bluetoothIndicator
            }

            NfcIndicator {
                id: nfcIndicator
            }

            LocationIndicator{
                id: locationIndicator
            }

            DeveloperModeIndicator{
                id: developerModeIndicator
            }

            USBModeIndicator{
                id: usbModedIndicator
            }
        }
    }

    Loader {
        id: panel_loader
        anchors.bottom: root.top
        height: 0
        width: parent.width
        visible: false
        onVisibleChanged: {
            if(visible) riseUp.start()
            else closeDown.start()
        }

        NumberAnimation {
            id:riseUp
            target: panel_loader
            property: "height"
            duration: 200
            from:0
            to:Theme.itemWidthMedium
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            id:closeDown
            target: panel_loader
            property: "height"
            duration: 200
            from: panel_loader.height
            to: 0
            easing.type: Easing.InOutQuad
        }
    }
}
