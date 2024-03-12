// Copyright (c) 2024, Sergey Chupligin <neochapay@gmail.com>
//
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

import QtQuick
import org.nemomobile.lipstick

Item {
    property bool isPortrait: (orientationAngleContextProperty.value == 90 || orientationAngleContextProperty.value == 270)
    id: usbWindow
    width: initialSize.width
    height: initialSize.height

    QtObject {
        id: orientationAngleContextProperty
        property int value: 0
    }

    Item {
        property bool shouldBeVisible
        id: usbDialog
        width: usbWindow.isPortrait ? usbWindow.height : usbWindow.width
        height: usbWindow.isPortrait ? usbWindow.width : usbWindow.height
        transform: Rotation {
            origin.x: { switch(orientationAngleContextProperty.value) {
                      case 270:
                          return usbWindow.height / 2
                      case 180:
                      case 90:
                          return usbWindow.width / 2
                      default:
                          return 0
                      } }
            origin.y: { switch(orientationAngleContextProperty.value) {
                case 270:
                case 180:
                    return usbWindow.height / 2
                case 90:
                    return usbWindow.width / 2
                default:
                    return 0
                } }
            angle: (orientationAngleContextProperty.value === undefined || orientationAngleContextProperty.value == 0) ? 0 : -360 + orientationAngleContextProperty.value
        }
        opacity: shouldBeVisible ? 1 : 0

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.8
            border.color: "white"
        }

        MouseArea {
            id: usbDialogBackground
            anchors.fill: parent
            onClicked: { usbModeSelector.setUSBMode(4); usbDialog.shouldBeVisible = false }

            Rectangle {
                id: chargingOnly
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: parent.height / 4
                }
                height: 102
                color: "black"
                radius: 5
                border {
                    color: "gray"
                    width: 2
                }

                Text {
                    anchors {
                        fill: parent
                    }
                    text: qsTr("Current mode: Charging only")
                    color: "white"
                    font.pixelSize: 30
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                id: button1
                anchors {
                    top: chargingOnly.bottom
                    topMargin: 40
                    left: parent.left
                    right: parent.right
                }
                text: qsTr("MTP Mode")
                color: "white"
                font.pixelSize: 30
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: { usbModeSelector.setUSBMode(11); usbDialog.shouldBeVisible = false }
                }
            }

            Text {
                id: button2
                anchors {
                    top: button1.bottom
                    topMargin: 40
                    left: parent.left
                    right: parent.right
                }
                text: qsTr("Mass Storage Mode")
                color: "white"
                font.pixelSize: 30
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: { usbModeSelector.setUSBMode(3); usbDialog.shouldBeVisible = false }
                }
            }

            Text {
                id: button3
                anchors {
                    top: button2.bottom
                    topMargin: 40
                    left: parent.left
                    right: parent.right
                }
                text: qsTr("Developer Mode")
                color: "white"
                font.pixelSize: 30
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: { usbModeSelector.setUSBMode(10); usbDialog.shouldBeVisible = false }
                }
            }
        }

        Connections {
            target: usbModeSelector
            function onWindowVisibleChanged(windowVisible) { if (usbModeSelector.windowVisible) usbDialog.shouldBeVisible = true }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                onRunningChanged: if (!running && usbDialog.opacity == 0) usbModeSelector.windowVisible = false
            }
        }
    }
}
