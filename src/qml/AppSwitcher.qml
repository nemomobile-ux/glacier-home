
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
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

import QtQuick 2.6
import org.nemomobile.lipstick 0.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.glacier 1.0

// App Switcher page
// The place for browsing already running apps

Item {
    id: switcherRoot
    property bool closeMode: false
    property bool visibleInHome: false
    property alias runningAppsCount: switcherModel.itemCount
    property var switchModel: switcherModel
    property var launcher: null

    onVisibleInHomeChanged: {
        // Exit close mode when scrolling out of view
        if (!visibleInHome && closeMode) {
            closeMode = false;
        }
    }
    clip: true
    // Empty switcher indicator
    Rectangle {
        id: topText
        visible: switcherModel.itemCount === 0
        width: noAppsLabel.width
        height: Theme.itemHeightMedium
        anchors {
            top: parent.top
            topMargin:Theme.itemSpacingLarge
            horizontalCenter: parent.horizontalCenter
        }
        color: "transparent"

        Label {
            id: noAppsLabel
            text: qsTr("No apps open")
            anchors {
                top: parent.top
                left: parent.left
            }
            font.weight: Font.Light
            font.pixelSize: Theme.fontSizeExtraLarge
        }
    }
    Flickable {
        id: flickable
        contentHeight: gridview.height
        width: closeMode ? parent.width - 20 : parent.width // see comment re right anchor below
        MouseArea {
            height: flickable.contentHeight > flickable.height ? flickable.contentHeight : flickable.height
            width: flickable.width
            onPressAndHold: closeMode = !closeMode
            onClicked: {
                if (closeMode)
                    closeMode = false
            }
        }

        anchors {
            top: parent.top
            topMargin: closeMode ? 20 : 0
            bottom: toolBar.top
            left: parent.left
            // no right anchor to avoid double margin (complicated math)
            leftMargin: closeMode ? 20 : 0
        }

        Grid {
            id: gridview
            columns: 2
            spacing: closeMode ? 20 : 0
            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                }
            }

            Repeater {
                id: gridRepeater
                model: GlacierWindowModel {
                    id:switcherModel
                }

                delegate: Item {
                    width: (flickable.width - (gridview.spacing * gridview.columns)) / gridview.columns
                    height: width * (desktop.height / desktop.width)

                    // The outer Item is necessary because of animations in SwitcherItem changing
                    // its size, which would break the Grid.
                    SwitcherItem {
                        id: switcherItem
                        width: parent.width
                        height: parent.height
                    }

                    function close() {
                        switcherItem.close()
                    }
                }
            }
        }
    }

    Rectangle {
        id: toolBar
        color: 'black'
        border {
            width: 1
            color: '#333333'
        }
        z: 202
        height: toolBarDone.height + 2*padding
        property int padding: 9

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: -1
            bottomMargin: switcherRoot.closeMode ? 48 : -height
        }

        Behavior on anchors.bottomMargin { PropertyAnimation { duration: 100 } }
        Button {
            id: toolBarDone
            width: parent.width / 3
            height: width
            anchors {
                top: parent.top
                topMargin: toolBar.padding
                right: parent.horizontalCenter
                rightMargin: toolBar.padding
            }
            onClicked: {
                switcherRoot.closeMode = false;
            }
            style: ButtonStyle {
                label: Label {
                    text: "Done"
                    anchors.fill: parent
                    anchors.margins: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.HorizontalFit
                    anchors.centerIn: parent
                }
            }
        }

        Button {
            id: toolBarCloseAll
            width: toolBarDone.width
            height: width
            anchors {
                top: parent.top
                topMargin: toolBar.padding
                left: parent.horizontalCenter
                leftMargin: toolBar.padding
            }
            onClicked: {
                // TODO: use close animation inside item
                for (var i = gridRepeater.count - 1; i >= 0; i--) {
                    gridRepeater.itemAt(i).close()
                }
            }
            style: ButtonStyle {
                label: Label {
                    text: qsTr("Close\nAll")
                    anchors.margins: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    fontSizeMode: Text.Fit
                    anchors.centerIn: parent
                }
            }
        }
    }
}
