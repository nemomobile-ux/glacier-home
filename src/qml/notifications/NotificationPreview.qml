
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

import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import "../scripts/desktop.js" as Desktop

Item {
    id: notificationWindow
    property alias summary: summary.text
    property alias body: body.text
    property alias icon: icon.source
    width: Desktop.instance.parent.width
    height: Desktop.instance.parent.height
    rotation: Desktop.instance.parent.rotation
    x: Desktop.instance.parent.x
    y: Desktop.instance.parent.y
    Rectangle {
        id: dimmer

        height: Math.min(parent.width,parent.height)/14

        anchors.top: parent.top
        anchors.topMargin: notificationArea.notificationHeight
        anchors.left: parent.left
        anchors.right: parent.right

        gradient: Gradient {
            GradientStop { position: 1.0; color: "black" }
            GradientStop { position: 0; color: "transparent" }
        }
    }

    MouseArea {
        id: notificationArea
        property int notificationHeight: Math.min(parent.width,parent.height)/12
        property int notificationMargin: 14
        property int notificationIconSize: Math.min(parent.width,parent.height)/12
        anchors.top: parent.top
        anchors.left: parent.left
        width: notificationWindow.width
        height: notificationArea.notificationHeight

        onClicked: if (notificationPreviewPresenter.notification != null) notificationPreviewPresenter.notification.actionInvoked("default")

        Rectangle {
            id: notificationPreview
            anchors {
                fill: parent
            }
            color: "transparent"
            radius: 10

            opacity: 0

            states: [
                State {
                    name: "show"
                    PropertyChanges {
                        target: notificationPreview
                        opacity: 1
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
                        target: notificationPreview
                        opacity: 0
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
                        NumberAnimation { property: "opacity"; duration: 200 }
                        ScriptAction { scriptName: "notificationShown" }
                    }
                },
                Transition {
                    to: "hide"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 200 }
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
                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: notificationArea.notificationMargin
                    leftMargin: notificationArea.notificationMargin
                }
                width: notificationArea.notificationIconSize
                height: width
                source: "/usr/share/lipstick-glacier-home-qt5/qml/images/notification-circle.png"
            }

            Label {
                id: summary
                anchors {
                    top: parent.top
                    left: icon.right
                    right: parent.right
                    leftMargin: notificationArea.notificationMargin + 26
                    rightMargin: notificationArea.notificationMargin
                    bottomMargin: notificationArea.notificationMargin
                }
                font.pointSize: 12
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewSummary : ""
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            Label {
                id: body
                anchors {
                    top: summary.bottom
                    left: summary.left
                    right: summary.right
                }
                font {
                    pointSize: 10
                    bold: true
                }
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewBody : ""
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            Connections {
                target: notificationPreviewPresenter;
                onNotificationChanged: notificationPreview.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide"
            }
        }
    }
}
