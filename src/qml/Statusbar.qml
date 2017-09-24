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
import org.freedesktop.contextkit 1.0
import MeeGo.Connman 0.2

import org.nemomobile.lipstick 0.1
import org.nemomobile.mpris 1.0

import "statusbar"

Item {
    id: root
    z: 201
    height: Theme.itemHeightMedium
    width: parent.width
    anchors.bottom: parent.bottom
    enabled: !lockscreenVisible()

    Rectangle {
        id: statusbar
        color: Theme.fillDarkColor
        anchors.fill: parent
        opacity: 0.5
        z: 200
    }

    MouseArea {
        property int oldX
        property int oldY
        anchors.fill: row
        z: row.z + 10
        //enabled: !lockscreenVisible()
        onClicked: {
            if(oldX != mouseX && oldY !== mouseY && row.childAt(mouseX, mouseY) && row.currentChild !== row.childAt(mouseX, mouseY)) {
                row.currentChild = row.childAt(mouseX, mouseY)
                row.currentChild.clicked()
            }else {
                row.currentChild = null
            }
        }

        onPositionChanged: {
            oldX = mouseX
            oldY = mouseY
            if(pressed && row.childAt(mouseX, mouseY)) {
                if(row.currentChild !== row.childAt(mouseX, mouseY)) {
                    row.currentChild = row.childAt(mouseX, mouseY)
                    if(panel_loader.visible) panel_loader.visible = false
                    row.currentChild.clicked()
                }
            } else {
                row.currentChild = null
            }
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

    RowLayout {
        id:row
        anchors.fill: statusbar
        spacing: Theme.itemSpacingSmall
        property var currentChild
        StatusbarItem {
            iconSize: Theme.itemHeightExtraSmall
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
            iconSize: root.height
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: tech.font.pixelSize*2
                Label {
                    id: tech
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:Text.AlignBottom
                    width: parent.width
                    height: paintedHeight
                    font.pixelSize: Theme.fontSizeSmall
                    elide:Text.ElideNone
                    maximumLineCount: 1
                    clip:true
                    text: (cellularNetworkName.value !== "") ? cellularNetworkName.value.substring(0,3).toUpperCase() : "NA"
                }

                Label {
                    y: -contentHeight + font.pixelSize*2 + tech.y
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    height: paintedHeight
                    font.pixelSize: Theme.fontSizeSmall
                    elide:Text.ElideNone
                    maximumLineCount: 1
                    text: {
                        var techToG = {gprs: "2", egprs: "2.5", umts: "3", hspa: "3.5", lte: "4", unknown: "0"}
                        return techToG[cellularDataTechnology.value ? cellularDataTechnology.value : "unknown"] + "G"
                    }
                }
            }
            panel: SimPanel {}
        }

        StatusbarItem {
            id:wifiStatus
            iconSize: Theme.itemHeightExtraSmall
            source: {
                if (wlan.connected) {
                    if (networkManager.defaultRoute.type !== "wifi")
                        return "image://theme/icon_wifi_0"
                    if (networkManager.defaultRoute.strength >= 59) {
                        return "image://theme/icon_wifi_focused4"
                    } else if (networkManager.defaultRoute.strength >= 55) {
                        return "image://theme/icon_wifi_focused3"
                    } else if (networkManager.defaultRoute.strength >= 50) {
                        return "image://theme/icon_wifi_focused2"
                    } else if (networkManager.defaultRoute.strength >= 40) {
                        return "image://theme/icon_wifi_focused1"
                    } else {
                        return "image://theme/icon_wifi_0"
                    }
                } else if (wifimodel.powered && !wlan.connected) {
                    return "image://theme/icon_wifi_touch"
                } else {
                    return "image://theme/icon_wifi_0"
                }
            }
            panel: WifiPanel {}
        }
        StatusbarItem {
            id: bluetootIndicator
            iconSize: Theme.itemHeightExtraSmall
            source: (bluetoothConnected.value) ? "image://theme/icon_bt_focused" : "image://theme/icon_bt_normal"
            visible: bluetoothEnabled.value
        }
        StatusbarItem {
            iconSize: Theme.itemHeightExtraSmall
            source: "image://theme/icon_nfc_normal"
        }
        StatusbarItem {
            iconSize: Theme.itemHeightExtraSmall
            source: "image://theme/icon_gps_normal"
        }

        StatusbarItem {
            iconSize: Theme.itemHeightExtraSmall
            source: (mprisManager.currentService && mprisManager.playbackStatus == Mpris.Playing) ?
                        "/usr/share/themes/glacier/fontawesome/icons/pause.png"
                      : "/usr/share/themes/glacier/fontawesome/icons/play.png"

            MprisManager {
                id: mprisManager
            }

            panel: MediaController{}
        }
        StatusbarItem {
            iconSize: root.height
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: hours.font.pixelSize*2
                Label {
                    id: hours
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:Text.AlignBottom
                    width: parent.width
                    height: paintedHeight
                    font.pixelSize: Theme.fontSizeSmall
                    elide:Text.ElideNone
                    maximumLineCount: 1
                    text: Qt.formatDateTime(wallClock.time, "hh")
                }
                Label {
                    id: minutes
                    y: -contentHeight + font.pixelSize*2 + hours.y
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    height: paintedHeight
                    font.pixelSize: Theme.fontSizeSmall
                    elide:Text.ElideNone
                    maximumLineCount: 1
                    text: Qt.formatDateTime(wallClock.time, "mm")
                }
            }
        }

        BatteryIndicator{
            id:batteryIndicator
        }
    }
}
