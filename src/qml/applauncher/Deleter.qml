// This file is part of glacier-home, a nice user experience for touchscreens.
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
// Copyright (c) 2018, Chupligin Sergey <neochapay@gmail.com>

import QtQuick 2.6

import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Item {//Doesn't yet uninstall applications
    id: deleter
    property alias remove: remove
    property alias uninstall: uninstall

    property Item delegate: Item{}

    function uninstalling(action, caption) {
        state = action
        if (action==="remove") {
            remove.text = qsTr("Removing") + " " + caption
        } else if (action == "uninstall") {
            uninstall.text = qsTr("Uninstalling") + " " + caption
        }
    }

    states: [
        State {
            name: "remove"
            PropertyChanges {
                target: remove
                color1: "#D9ff0000"
                color2: "#D9ff0000"
                color3: "#D9ff0000"
            }
            PropertyChanges {
                target: uninstall
                color1: "#D9ff0000"
                color2: "#80ff0000"
                color3: "#4Dff0000"
            }
            PropertyChanges {
                target: uninstall
                text: qsTr("Uninstall")
            }
        },
        State {
            name: "uninstall"
            PropertyChanges {
                target: uninstall
                color1: "#D9ff0000"
                color2: "#D9ff0000"
                color3: "#D9ff0000"
            }
            PropertyChanges {
                target: remove
                color1: "#D9ff0000"
                color2: "#80ff0000"
                color3: "#4Dff0000"
            }
            PropertyChanges {
                target: remove
                text: qsTr("Remove")
            }
        },
        State {
            name:"basic"
            PropertyChanges {
                target: remove
                color1: "#D9ff0000"
                color2: "#80ff0000"
                color3: "#4Dff0000"
            }
            PropertyChanges {
                target: remove
                text: qsTr("Remove")
            }
            PropertyChanges {
                target: uninstall
                color1: "#D9ff0000"
                color2: "#80ff0000"
                color3: "#4Dff0000"
            }
            PropertyChanges {
                target: uninstall
                text: qsTr("Uninstall")
            }
        }
    ]

    Rectangle {//WHY?
        id: remove
        property color color1: "#D9ff0000"
        property color color2: "#80ff0000"
        property color color3: "#4Dff0000"
        property alias text: removeLabel.text
        anchors.left: parent.left
        visible: gridview.onUninstall
        height: Theme.itemHeightExtraLarge
        width: gridview.width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: remove.color1 }
            GradientStop { position: 0.5; color: remove.color2 }
            GradientStop { position: 1.0; color: remove.color3 }
        }
        Row {
            width: parent.width
            height: parent.height
            Image {
                id:removeIcon
                fillMode: Image.PreserveAspectFit
                height: parent.height -Theme.itemSpacingExtraSmall
                width: height
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/remove"
                visible: deleter.state != "remove"
            }

            Label {
                id: removeLabel
                text: qsTr("Remove")
                height: parent.height
                width: parent.width - (removeIcon.visible ?  removeIcon.width : 0)
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Theme.fontSizeSmall
                elide:Text.ElideRight
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment:Text.AlignVCenter
            }
        }
    }
    Rectangle {
        id: uninstall
        property color color1: "#D9ff0000"
        property color color2: "#80ff0000"
        property color color3: "#4Dff0000"
        property alias text: uninstallLabel.text
        anchors.left: remove.right
        visible: gridview.onUninstall
        width: gridview.width / 2
        height: Theme.itemHeightExtraLarge
        gradient: Gradient {
            GradientStop { position: 0.0; color: uninstall.color1 }
            GradientStop { position: 0.5; color: uninstall.color2 }
            GradientStop { position: 1.0; color: uninstall.color3 }
        }
        Row {
            width: parent.width
            height: parent.height
            Image {
                id:trashIcon
                fillMode: Image.PreserveAspectFit
                height: parent.height -Theme.itemSpacingExtraSmall
                width: height
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/trash"
                visible: deleter.state != "uninstall"
            }
            Label {
                id: uninstallLabel
                height: parent.height
                width: parent.width - (trashIcon.visible ?  trashIcon.width : 0)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Uninstall")
                font.pixelSize: Theme.fontSizeSmall
                elide:Text.ElideRight
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment:Text.AlignVCenter
            }
        }
    }
}

