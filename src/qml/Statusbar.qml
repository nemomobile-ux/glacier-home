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
import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtGraphicalEffects 1.0
import org.freedesktop.contextkit 1.0
import MeeGo.Connman 0.2
import org.nemomobile.lipstick 0.1
import QtFeedback 5.0
import QtMultimedia 5.0

import "statusbar"

Item {
    id: root
    z: 201
    height: Math.min(parent.width,parent.height)/13.33333333333 //(480/36, so 36 pixels at a 480 pixel wide screen)
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
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
    }
    Item {
        id: statusbarRight
        height: parent.height*0.5
        width:  parent.width*0.5
        anchors.verticalCenter: statusbar.verticalCenter
        anchors.right: parent.right
    }

    Connections {
        target: lipstickSettings;
        onLockscreenVisibleChanged: {
            if(lipstickSettings.lockscreenVisible) {
                batteryChargePercentage.subscribe()
                cellularSignalBars.subscribe()
                cellularRegistrationStatus.subscribe()
                cellularNetworkName.subscribe()
                cellularDataTechnology.subscribe()
            } else {
                batteryChargePercentage.unsubscribe()
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
        height: 240
        width: parent.width
        visible: false
    }

    Row {
        anchors.fill: statusbar
        spacing: statusbar.height / 3

        StatusbarItem {
            iconSize:1
        }

        BatteryIndicator{}

        StatusbarItem {
            iconSize: statusbar.height
            //source: (cellularSignalBars.value > 0) ? "image://theme/icon_cell" + cellularSignalBars.value
            source: "theme/icon_signal_" + cellularSignalBars.value + ".png"

        }

        StatusbarItem {
            
            Text {
                id: tech
                wrapMode: Text.WrapAnywhere
                font.pixelSize: statusbar.height
                color: "white"
                text: (cellularNetworkName.value !== "") ? cellularNetworkName.value.substring(0,10) : "No Service"
            }
            iconSize: tech.width
        }

        StatusbarItem {
            iconSize: statusbar.height
            source: {
                if (wlan.connected) {                     
                    if (networkManager.defaultRoute.strength >= 59) {
                        return "theme/icon_wifi_4.png"
                    } else if (networkManager.defaultRoute.strength >= 55) {
                        return "theme/icon_wifi_3.png"
                    } else if (networkManager.defaultRoute.strength >= 50) {
                        return "theme/icon_wifi_2.png"
                    } else if (networkManager.defaultRoute.strength >= 40) {
                        return "theme/icon_wifi_1.png"
                    } else {
                        return "theme/icon_wifi_0.png"
                    }
                } else {
                    return "theme/data_"+ cellularDataTechnology.value + ".png"
                }
                    
            }
            panel: WifiPanel {}
        }
    }

    Row {
        anchors.fill: statusbarRight
        spacing: statusbar.height / 3
        layoutDirection: Qt.RightToLeft

        StatusbarItem {
            iconSize:1
        }

        StatusbarItem {
            Text {
                id: hours
                wrapMode: Text.WrapAnywhere
                font.pixelSize: statusbar.height
                color: "white"
                text: {
                    //Todo: Get regional settings
                    var separator = ":"
                    return Qt.formatDateTime(wallClock.time, "hh") + separator + Qt.formatDateTime(wallClock.time, "mm")
                }
            }
            iconSize: hours.width
        }
        StatusbarItem {
            iconSize: statusbar.height
            source: "theme/icon_music.png"
            visible: false
        }
        StatusbarItem {
            id: bluetoothIndicator
            iconSize:       statusbar.height * 0.671875
            iconSizeHeight: statusbar.height
            //opacity: (bluetoothConnected.value) ? 1 : 0.5
            //source: "image://theme/icon_bt_focused"
            source: "theme/icon_bluetooth.png"
            visible: bluetoothEnabled.value
        }

        StatusbarItem {
            iconSize: statusbar.height
            source: "theme/icon_nfc.png"
            //source: "image://theme/icon_nfc_normal"
        }
        StatusbarItem {
            iconSize: statusbar.height * 0.75
            iconSizeHeight: statusbar.height
            source: "theme/icon_gps.png"
            //source: "image://theme/icon_gps_normal"
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
            source: "theme/button_down.wav"
        }
        SoundEffect {
            id: buttonUp
            source: "theme/button_up.wav"
        }
    }
}
