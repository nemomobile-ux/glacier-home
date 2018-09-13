/****************************************************************************************
**
** Copyright (C) 2017 Samuel Pavlovic <sam@volvosoftware.com>
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
import QtQuick.Window 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtGraphicalEffects 1.0
import QtFeedback 5.0
import QtMultimedia 5.0

import MeeGo.Connman 0.2

import org.freedesktop.contextkit 1.0
import org.nemomobile.lipstick 0.1

import "controlcenter"

//Area to return
Item{
    id: controlCenterArea

    property bool activated: false

    width: Screen.width
    height: 0
    visible: height > 0

    clip: true

    function down() {
        controlCenterArea.height = 0
        controlCenterArea.activated = false
    }


    onHeightChanged: {
        if(height != Screen.height) {
            hiderTimer.restart()
        } else {
            hiderTimer.stop()
        }
    }

    onActivatedChanged: {
        if(!activated) {
            down()
        }
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
        enabled: parent.activated
        parent: controlCenterArea

        onPressed: {
            controlCenterArea.height = 0
            controlCenterArea.activated = false
        }
    }

    Rectangle {
        id: controlCenter
        width: parent.width
        height: parent.width
        color: "transparent"

        RowLayout {
            id: layout

            anchors.top: parent.top
            anchors.topMargin: size.dp(40 + 22)
            width: parent.width
            height: size.dp(86)

            NetworkControlButton{
                image: "image://theme/wifi"
                textLabel: qsTr("Wi-Fi")
                networkingModel: "wifi"
            }
            NetworkControlButton{
                image: "image://theme/bluetooth"
                textLabel: qsTr("Bluetooth")
                networkingModel: "bluetooth"
            }
            NetworkControlButton{
                image: "image://theme/exchange-alt"
                textLabel: qsTr("Data")
                networkingModel: "cellular"
            }
            NetworkControlButton{
                image: "image://theme/map-marker-alt"
                textLabel: qsTr("Location")
                networkingModel: "gps"
            }
            ControlButton{
                image: "image://theme/moon"
                textLabel: qsTr("Quiet")
            }
        }

        GridView{
            id: notifyLayout

            anchors{
                top: layout.bottom
                topMargin: size.dp(62)
                left: controlCenterArea.left
                leftMargin: size.dp(31)
            }

            width: parent.width

            cellWidth: parent.width/5
            cellHeight: cellWidth

            model: statusNotiferModel
            delegate: ControlButton{
                width: notifyLayout.cellWidth;
                height: notifyLayout.cellHeight
                image: notifierItem.icon
                textLabel: notifierItem.title

                onClicked: {
                    notifierItem.activate()
                }
            }
        }
    }
/*Little hack for hide control center*/
    MouseArea{
        id: backgroundMouseArea
        anchors.fill: parent

        property int pMouse: 0

        onPressed: {
            backgroundMouseArea.pMouse = backgroundMouseArea.mouseY
        }
        onReleased: {
            if(pMouse-backgroundMouseArea.mouseY >= Screen.height/4){
                controlCenterArea.down()
            }
            pMouse = 0;
        }
    }

    Behavior on height {
        NumberAnimation { duration: 100 }
    }
}

