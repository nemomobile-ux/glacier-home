/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
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
import org.freedesktop.contextkit 1.0
import MeeGo.Connman 0.2
import org.nemomobile.lipstick 0.1

Item {
    id: root
    z: 201
    height: Math.min(parent.width,parent.height)/12
    width: parent.width
    anchors.bottom: parent.bottom

    Rectangle {
        id: statusbar
        color: "black"
        anchors.fill: parent
        opacity: 0.5
        z: 200
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
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        value: "100"
    }

    ContextProperty {
        id: cellularSignalBars
        key: "Cellular.SignalBars"
    }

    ContextProperty {
        id: cellularRegistrationStatus
        key: "Cellular.RegistrationStatus"
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

    RowLayout {
        anchors.fill: statusbar
        spacing: root.height/4
        StatusbarItem {
            iconSize: root.height/2
            source: (cellularSignalBars.value > 0) ? "image://theme/icon_cell" + cellularSignalBars.value : "image://theme/icon_cell1"

            MouseArea{
                anchors.fill: parent
                onPressAndHold: {
                    var screenShotPath = "/home/nemo/Pictures/Screenshots/"
                    var file = "glacier-screenshot-"+Qt.formatDateTime(new Date, "yyMMdd_hhmmss")+".png"

                    Lipstick.takeScreenshot(screenShotPath + file);
                }
            }

        }

        StatusbarItem {
            iconSize: root.height/2
            Label {
                id: tech
                width: root.height/4
                height: root.height/4
                font.pixelSize: root.height/4+root.height/5
                font.bold: true
                wrapMode: Text.ElideRight
                text: (cellularNetworkName.value !== "") ? cellularNetworkName.value.substring(0,3).toUpperCase() : "NA"
            }

            Label {
                anchors.top: tech.bottom
                anchors.topMargin: root.height/8
                width: root.height/4
                height: root/height/4
                font.pixelSize: root.height/4+root.height/5
                text: {
                    var techToG = {gprs: "2", egprs: "2.5", umts: "3", hspa: "3.5", lte: "4", unknown: "0"}
                    return techToG[cellularDataTechnology.value ? cellularDataTechnology.value : "unknown"] + "G"
                }
            }
            panel: SimPanel {}
        }

        StatusbarItem {
            iconSize: root.height/2
            source: {
                if (wlan.connected) {
                    if (networkManager.defaultRoute.type !== "wifi")
                        return "image://theme/icon_wifi_0"
                    if (networkManager.defaultRoute.strength >= 59) {
                        return "image://theme/icon_wifi_normal4"
                    } else if (networkManager.defaultRoute.strength >= 55) {
                        return "image://theme/icon_wifi_normal3"
                    } else if (networkManager.defaultRoute.strength >= 50) {
                        return "image://theme/icon_wifi_normal2"
                    } else if (networkManager.defaultRoute.strength >= 40) {
                        return "image://theme/icon_wifi_normal1"
                    } else {
                        return "image://theme/icon_wifi_0"
                    }
                } else {
                    return "image://theme/icon_wifi_0"
                }
            }
            panel: WifiPanel {}
        }
        StatusbarItem {
            iconSize: root.height/2
            source: "image://theme/icon_bt_normal"
        }
        StatusbarItem {
            iconSize: root.height/2
            source: "image://theme/icon_nfc_normal"
        }
        StatusbarItem {
            iconSize: root.height/2
            source: "image://theme/icon_gps_normal"
        }
        StatusbarItem {
            iconSize: root.height/2
            source: "image://theme/icon_play_pause"
        }
        StatusbarItem {
            iconSize: root.height/2
            Label {
                id: hours
                width: root.height/4
                height: root.height/4
                font.pixelSize: root.height/4+root.height/5
                text: Qt.formatDateTime(wallClock.time, "hh")
            }
            Label {
                id: minutes
                anchors.top: hours.bottom
                anchors.topMargin: root.height/8
                width: root.height/4
                height: root.height/4
                font.pixelSize: root.height/4+root.height/5
                text: Qt.formatDateTime(wallClock.time, "mm")
            }
        }

        StatusbarItem {
            iconSize: root.height/2
            panel: BatteryPanel {}
            source: {
                if(batteryChargePercentage.value > 85) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery6.png"
                } else if (batteryChargePercentage.value <= 5) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery0.png"
                } else if (batteryChargePercentage.value <= 10) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery1.png"
                } else if (batteryChargePercentage.value <= 25) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery2.png"
                } else if (batteryChargePercentage.value <= 40) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/imagesbattery3.png"
                } else if (batteryChargePercentage.value <= 65) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery4.png"
                } else if (batteryChargePercentage.value <= 80) {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery5.png"
                } else {
                    return "/usr/share/lipstick-glacier-home-qt5/qml/images/battery6.png"
                }
            }
        }
    }
}
