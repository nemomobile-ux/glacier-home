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

import MeeGo.Connman 0.2

import "statusbar"

Item {
    id: root
    z: 201
    height: size.dp(40)
    width: parent.width
    anchors.top: parent.top

    ControlCenter{ 
        id: ctrlCenter
    }

    Rectangle {
        id: statusbarPadding
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0.75) }
            GradientStop { position: 1.0; color: "transparent" }
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
                cellularDataTechnology.subscribe()
            } else {
                batteryIndicator.batteryChargePercentage.unsubscribe()
                cellularSignalBars.unsubscribe()
                cellularRegistrationStatus.unsubscribe()
                cellularNetworkName.unsubscribe()
                cellularDataTechnology.unsubscribe()
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
        id: bluetoothEnabled
        key: "Bluetooth.Enabled"
    }

    ContextProperty {
        id: bluetoothConnected
        key: "Bluetooth.Connected"
    }

    NetworkManager {
        id: networkManager
        function updateTechnologies() {
            if (available && technologiesEnabled) {
                wlan.path = networkManager.technologyPathForType("wifi")
            }
        }
        onAvailableChanged: updateTechnologies()
        onTechnologiesEnabledChanged: updateTechnologies()
        onTechnologiesChanged: updateTechnologies()

    }

    NetworkTechnology {
        id: wlan
    }

    ContextProperty {
        id: cellularNetworkName
        key: "Cellular.NetworkName"
    }

    ContextProperty {
        id: cellularDataTechnology
        key: "Cellular.DataTechnology"
    }

    TechnologyModel {
        id: wifimodel
        name: "wifi"
        onPoweredChanged: {
            if (powered)
                wifimodel.requestScan()
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

        StatusbarItem{
            id: dataStatus
            iconSize: statusbar.height
            visible: cellularDataTechnology.value != "unknown"
            source: {
                if(cellularDataTechnology.value == "2") {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_gprs.png"
                }else if(cellularDataTechnology.value == "2.5") {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_egprs.png"
                }else if(cellularDataTechnology.value == "3") {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_utms.png"
                }else if(cellularDataTechnology.value == "3.5") {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_hspa.png"
                }else if(cellularDataTechnology.value == "4") {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_lte.png"
                }else {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_unknown.png"
                }
            }
        }

        StatusbarItem {
            id: wifiStatus
            iconSize: statusbar.height
            visible: wifimodel.powered
            source: {
                if (wlan.connected) {
                    if (networkManager.defaultRoute.strength >= 59) {
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_4.png"
                    } else if (networkManager.defaultRoute.strength >= 55) {
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_3.png"
                    } else if (networkManager.defaultRoute.strength >= 50) {
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_2.png"
                    } else if (networkManager.defaultRoute.strength >= 40) {
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_1.png"
                    } else {
                        return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_0.png"
                    }
                } else if (wlan.connected) {
                    return "image://theme/icon_wifi_touch"
                }
            }
        }

        StatusbarItem {
            id: bluetoothIndicator
            iconSize:       statusbar.height * 0.671875
            iconSizeHeight: statusbar.height
            source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_bluetooth.png"
            visible: bluetoothEnabled.value
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

        //Status Bar Click
        HapticsEffect {
            id: rumbleEffect
            attackIntensity: 0.0
            attackTime: 250
            intensity: 1.0
            duration: 1
            fadeTime: 250
            fadeIntensity: 0.0
        }

        MouseArea {
            width: root.width
            height: root.height
            onClicked: {
                //Do the stuff to show the menu
                ctrlCenter.setControlCenterState( !ctrlCenter.getControlCenterState() )
            }
            onReleased: {
                rumbleEffect.start();  // plays a rumble effect
                buttonUp.play();
                statusbarPressFeedback.visible = false
            }
            onPressed: {
                rumbleEffect.start();  // plays a rumble effect
                buttonDown.play();
                statusbarPressFeedback.visible = true
            }
        }

        SoundEffect {
            id: buttonDown
            source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/button_down.wav"
        }

        SoundEffect {
            id: buttonUp
            source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/button_up.wav"
        }
    }
}
