
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
        width: closeMode ? parent.width - Theme.itemSpacingLarge : parent.width // see comment re right anchor below
        MouseArea {
            height: flickable.contentHeight > flickable.height ? flickable.contentHeight : flickable.height
            width: flickable.width
            onPressAndHold: closeMode = !closeMode
            enabled: gridRepeater.count > 0
            onClicked: {
                if (closeMode)
                    closeMode = false
            }
        }

        anchors {
            top: parent.top
            topMargin: closeMode ? Theme.itemSpacingLarge : 0
            bottom: toolBar.top
            left: parent.left
            // no right anchor to avoid double margin (complicated math)
            leftMargin: closeMode ? Theme.itemSpacingLarge : 0
        }

        Grid {
            id: gridview
            columns: 2
            spacing: closeMode ? Theme.itemSpacingLarge : 0
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

    Connections {
        target:gridRepeater
        onCountChanged: {
            if(gridRepeater.count < 1) {
                closeMode = false
            }
        }
    }
    Connections {
        target: Lipstick.compositor
        onDisplayOff: {
            closeMode = false
        }
    }
    Connections {
        target: lockScreen
        onVisibleChanged: {
            if(lockscreenVisible()) {
                closeMode = false
            }
        }
    }
    Connections {
        target: pager
        onFlickEnded: {
            closeMode = false
        }
    }
    Rectangle {
        id: toolBar
        color: Theme.backgroundColor
        border {
            width: 1
            color: Theme.fillDarkColor
        }
        z: 202
        height:Theme.itemHeightExtraLarge + 2*padding
        property int padding: Theme.itemSpacingSmall

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: -1
            bottomMargin: switcherRoot.closeMode ? statusbar.height : -height
        }

        Behavior on anchors.bottomMargin { PropertyAnimation { duration: 100 } }
        Row {
            anchors {
                top: parent.top
                margins: toolBar.padding
                right: parent.right
                left: parent.left
                bottom:  parent.bottom
            }
            spacing: toolBar.padding*2

            Button {
                id: toolBarDone
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width / 2 - toolBar.padding
                onClicked: {
                    switcherRoot.closeMode = false;
                }
                text: qsTr("Done")
                //Untill fontSizes are fixed
                style: ButtonStyle {
                    label: Text {
                        renderType: Text.NativeRendering
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: control.text
                        color: Theme.textColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: control.primary ? Theme.fontWeightLarge : Theme.fontWeightMedium
                        opacity: control.enabled ? 1.0 : 0.3
                    }
                }
            }

            Button {
                id: toolBarCloseAll
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                 width: parent.width / 2 - toolBar.padding
                onClicked: {
                    // TODO: use close animation inside item
                    for (var i = gridRepeater.count - 1; i >= 0; i--) {
                        gridRepeater.itemAt(i).close()
                    }
                }
                text: qsTr("Close All")
                //Untill fontSizes are fixed
                style: ButtonStyle {
                    label: Text {
                        renderType: Text.NativeRendering
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: control.text
                        color: Theme.textColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: control.primary ? Theme.fontWeightLarge : Theme.fontWeightMedium
                        opacity: control.enabled ? 1.0 : 0.3
                    }
                }
            }
        }
    }
}
