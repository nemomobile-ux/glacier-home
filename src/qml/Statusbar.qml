/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2017 Sergey Chupligin <mail@neochapay.ru>
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
import QtGraphicalEffects 1.0
import QtFeedback 5.0
import QtMultimedia 5.0

import org.freedesktop.contextkit 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.mpris 1.0

import "statusbar"

Item {
    id: root
    z: 198
    height: size.dp(40)
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
        id: statusbar
        height: parent.height*0.5
        width:  parent.width*0.5
        anchors{
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: statusbar.height/2
        }
    }
    Item {
        id: statusbarRight
        height: parent.height*0.5
        width:  parent.width*0.5
        anchors{
            verticalCenter: statusbar.verticalCenter
            right: parent.right
            rightMargin: statusbarRight.height/2
        }
    }

    Connections {
        target: lipstickSettings;
        onLockscreenVisibleChanged: {
            if(lipstickSettings.lockscreenVisible) {
                batteryIndicator.batteryChargePercentage.subscribe()
                cellularSignalBars.subscribe()
                cellularRegistrationStatus.subscribe()
                cellularNetworkName.subscribe()
                dataStatus.cellularDataTechnology.subscribe()
            } else {
                batteryIndicator.batteryChargePercentage.unsubscribe()
                cellularSignalBars.unsubscribe()
                cellularRegistrationStatus.unsubscribe()
                cellularNetworkName.unsubscribe()
                dataStatus.cellularDataTechnology.unsubscribe()
            }
        }
    }

    ContextProperty {
        id: cellularSignalBars
        key: "Cellular.SignalBars"
    }

    ContextProperty {
        id: cellularRegistrationStatus
        key: "Cellular.RegistrationStatus"
    }

    ContextProperty {
        id: cellularNetworkName
        key: "Cellular.NetworkName"
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

    Row {
        anchors.fill: statusbar
        spacing: statusbar.height / 3

        Repeater{
            id: statusesRepeater
            model: statusNotiferModel

            delegate: StatusbarItem{
                iconSize: statusbar.height
                source: notifierItem.icon
            }
        }
    }

    Row {
        id: rightStatusBar

        anchors.fill: statusbarRight
        spacing: statusbar.height / 3
        layoutDirection: Qt.RightToLeft

        StatusbarItem {
            id: clock
            Text {
                id: hours
                wrapMode: Text.WrapAnywhere
                font.pixelSize: statusbar.height
                color: Theme.textColor
                height: statusbar.height
                verticalAlignment: Text.AlignVCenter

                text: {
                    //Todo: Get regional settings
                    var separator = ":"
                    return Qt.formatDateTime(wallClock.time, "hh") + separator + Qt.formatDateTime(wallClock.time, "mm")
                }
            }
            iconSize: hours.width
        }

        BatteryIndicator{
            id: batteryIndicator
        }

        StatusbarItem {
            id: cellStatus
            iconSize: statusbar.height
            source: if(cellularSignalBars.value){
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_signal_" + cellularSignalBars.value + ".png"
                    } else {
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/nosim.png"
                    }
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

        StatusbarItem {
            id: nfcIndicator
            iconSize: statusbar.height
            source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_nfc.png"
        }

        StatusbarItem {
            id: gpsIndicator
            iconSize: statusbar.height * 0.75
            iconSizeHeight: statusbar.height
            source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_gps.png"
        }

        UsbModeIndicator{
            id: usbModedIndicator
        }
    }
}
