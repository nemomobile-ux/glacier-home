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
MouseArea{
    id: controlCenterArea
    property bool controlCenterState: false //Is control center enabled or disabled?

    width: Screen.width
    height: Screen.height
    visible: controlCenterState
    state: "hide"

    Rectangle{
        id: controlCenterOutAreaDim
        anchors.fill: parent
        color: "black"
        opacity:0.5
    }

    //Control Center area
    MouseArea{
        width: parent.width
        height: parent.width

        Rectangle {
            id: controlCenter
            width: parent.width
            height: parent.width
            color: Theme.backgroundColor
            radius:32
            x:0
            y:0

            RowLayout {
                id: layout

                anchors.top: parent.top
                anchors.topMargin: size.dp(40 + 22)
                width: parent.width
                height: size.dp(86)

                ControlButton{
                    image: "image://theme/wifi"
                    textLabel: qsTr("Wi-Fi")
                }
                ControlButton{
                    image: "image://theme/bluetooth"
                    textLabel: qsTr("Bluetooth")
                }
                ControlButton{
                    image: "image://theme/exchange-alt"
                    textLabel: qsTr("Data")
                }
                ControlButton{
                    image: "image://theme/map-marker-alt"
                    textLabel: qsTr("Location")
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
    }

    //Close the thing if background is tapped
    onClicked: {
        //Do the stuff to show the menu
        setControlCenterState( false )
    }

    function setControlCenterState(enabled) {
        controlCenterState = true
        enabled ? state = '' : state = 'hide'
    }
    
    function getControlCenterState(){
        return controlCenterState;
    }

    states: [
        State { name: "hide"

            PropertyChanges {
                target: controlCenter
                y: -controlCenter.height
            }
            PropertyChanges {
                target: controlCenterOutAreaDim
                opacity: 0
            }
        }
    ]
    transitions: [
        Transition {
            SequentialAnimation {
                ScriptAction {
                    script: controlCenterState = true
                }
                id: closeAnimation
                NumberAnimation {
                    properties: "x,y,opacity"
                    easing.type: Easing.InOutQuint
                }
                ScriptAction {
                    script: state == 'hide' ? controlCenterState = false : controlCenterState = true
                }
            }
        }
    ]
}
