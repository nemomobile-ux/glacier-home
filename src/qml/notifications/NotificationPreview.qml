/*
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (C) 2012 Jolla Ltd.
// Contact: Vesa Halttunen <vesa.halttunen@jollamobile.com>
// Copyright (C) 2018 Chupligin Sergey <neochapay@gmail.com>
*/
import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1

import "../scripts/desktop.js" as Desktop

Item {
    id: notificationWindow
    property alias summary: summary.text
    property alias body: body.text
    property alias icon: icon.source
    width: Desktop.instance.width
    height: Desktop.instance.height
    rotation: Desktop.instance.parent.rotation
    x: Desktop.instance.x
    y: Desktop.instance.y

/*Glacier use fontawesome icons but nemo use maemo icons */
    function formatIcon(icon){
        if(icon === "") {
            return "../images/notification-circle.png"
        }

        if(icon === "icon-system-charging") {
            return "image://theme/plug"
        }

        if(icon === "icon-system-usb") {
            return "image://theme/bug"
        }

        return "image://theme/"+icon;
    }

    MouseArea {
        id: notificationArea
        property int notificationHeight: Math.min(parent.width,parent.height)/7
        property int notificationMargin: 14
        property int notificationIconSize: Math.min(parent.width,parent.height)/12
        y: -notificationArea.height
        width: notificationWindow.width
        height: notificationArea.notificationHeight

        onClicked: if (notificationPreviewPresenter.notification != null) notificationPreviewPresenter.notification.actionInvoked("default")

        Rectangle {
            id: notificationPreview
            width: notificationWindow.width
            height: notificationArea.notificationHeight
            radius: 32
            color: "black"

            states: [
                State {
                    name: "show"
                    PropertyChanges {
                        target: notificationArea
                        opacity: 1
                        y: 0
                    }
                    StateChangeScript {
                        name: "notificationShown"
                        script: {
                            notificationTimer.start()
                        }
                    }
                },
                State {
                    name: "hide"
                    PropertyChanges {
                        target: notificationArea
                        opacity: 0
                        y: -notificationArea.height
                    }
                    StateChangeScript {
                        name: "notificationHidden"
                        script: {
                            notificationTimer.stop()
                            notificationPreviewPresenter.showNextNotification()
                        }
                    }
                }
            ]
            transitions: [
                Transition {
                    to: "show"
                    SequentialAnimation {
                        NumberAnimation {
                            properties: "x,y,opacity"
                            easing.type: Easing.InOutQuint
                        }
                        ScriptAction { scriptName: "notificationShown" }
                    }
                },
                Transition {
                    to: "hide"
                    SequentialAnimation {
                        NumberAnimation {
                            properties: "x,y,opacity"
                            easing.type: Easing.InOutQuint
                        }
                        ScriptAction { scriptName: "notificationHidden" }
                    }
                }
            ]

            Timer {
                id: notificationTimer
                interval: 3000
                repeat: false
                onTriggered: notificationPreview.state = "hide"
            }


            Image {
                id: icon
                width: notificationArea.notificationIconSize
                height: width
                anchors{
                    left: parent.left
                    leftMargin: (notificationArea.height-width)/2
                    verticalCenter: parent.verticalCenter
                }

                source: formatIcon(notificationPreviewPresenter.notification.icon)
            }

            Rectangle{
                id: label
                color: "transparent"
                width: parent.width - parent.height
                height: parent.height

                clip: true

                anchors {
                    top: parent.top
                    left: icon.right
                    leftMargin: (notificationArea.height-icon.width)/2
                }
                Text {
                    id: summary
                    width:  parent.width
                    height: (text == "") ? 0 : undefined
                    font {
                        pointSize: Theme.fontSizeTiny/4
                        bold: true
                    }

                    anchors{
                        left: parent.left
                        top: parent.top
                        topMargin: (text == "") ? undefined : (notificationArea.height-icon.width)/4
                    }

                    text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewSummary : ""
                    color: Theme.textColor
                    clip: true
                    elide: Text.ElideRight
                }

                Text {
                    id: body
                    anchors {
                        top: (summary.text == "") ? undefined : summary.bottom
                        left: (summary.text == "") ? undefined : summary.left
                        right: (summary.text == "") ? undefined : summary.right
                        verticalCenter: (summary.text == "") ? parent.verticalCenter : undefined
                    }
                    font {
                        pointSize: (summary.text == "") ? Theme.fontSizeTiny/4 : Theme.fontSizeTiny/6
                        bold: false
                    }
                    width:  parent.width
                    text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewBody : ""
                    color: Theme.textColor
                    clip: true
                    elide: Text.ElideRight
                }
            }

            Connections {
                target: notificationPreviewPresenter;
                onNotificationChanged: {
                    notificationPreview.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide"
                }
            }

            //Hack to only have border radius on the bottom corner, qml doesn't allow per corner radius
            Rectangle{
                anchors.top: parent.top
                height: parent.height/2
                width: parent.width
                color: parent.color
                z:-1
            }
        }
    }
}
