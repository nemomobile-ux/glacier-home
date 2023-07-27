
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
// Copyright (c) 2021-2023, Chupligin Sergey <neochapay@gmail.com>

import QtQuick 2.6
import org.nemomobile.lipstick 0.1
import Nemo.Controls
import org.nemomobile.glacier 1.0

import "appswitcher"

// App Switcher page
// The place for browsing already running apps

Item {
    id: switcherRoot
    property bool closeMode: false
    property bool visibleInHome: false
    property alias runningAppsCount: switcherModel.itemCount
    property var switchModel: switcherModel
    property var launcher: null
    property var wallpaper: null

    onVisibleInHomeChanged: {
        // Exit close mode when scrolling out of view
        if (!visibleInHome && closeMode) {
            closeMode = false;
        }
    }
    clip: true

    GlacierWindowModel {
        id:switcherModel
    }

    ScrollDecorator{
        id: decorator
        flickable: flickable
    }

    Flickable {
        id: flickable
        contentHeight: gridview.height
        width: closeMode ? parent.width - Theme.itemSpacingLarge : parent.width - Theme.itemSpacingSmall // see comment re right anchor below
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
            topMargin: closeMode ? Theme.itemSpacingLarge : Theme.itemSpacingSmall
            bottom: toolBar.top
            left: parent.left
            // no right anchor to avoid double margin (complicated math)
            leftMargin: closeMode ? Theme.itemSpacingLarge : Theme.itemSpacingSmall
        }

        Grid {
            id: gridview
            columns: switcherModel.itemCount > 4  ? 3 : 2
            spacing: closeMode ? Theme.itemSpacingLarge : Theme.itemSpacingSmall
            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                }
            }

            Repeater {
                id: gridRepeater
                model: switcherModel

                delegate: Item {
                    width: (desktop.width - (gridview.spacing * (gridview.columns + 1))) / gridview.columns
                    height: (desktop.height - (gridview.spacing * (gridview.columns + 1))) / gridview.columns

                    // The outer Item is necessary because of animations in SwitcherItem changing
                    // its size, which would break the Grid.
 
                    //TODO: fix this QtGraphicalEffects removed from Qt6
                    /*FastBlur {
                        anchors.fill: switcherItemBG
                        source: wallpaper
                        radius: 100
                    }*/

                    Rectangle {
                        id: switcherItemBG
                        color: Theme.backgroundColor
                        anchors.fill: switcherItem
                        opacity: 0.5
                    }

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
        function onCountChanged(count) {
            if(gridRepeater.count < 1) {
                closeMode = false
            }
        }
    }
    Connections {
        target: Lipstick.compositor
        function onDisplayOff() {
            closeMode = false
        }
    }
    Connections {
        target: lockScreen
        function onVisibleChanged() {
            if(lockscreenVisible()) {
                closeMode = false
            }
        }
    }
    Connections {
        target: pager
        function onFlickEnded() {
            closeMode = false
        }
    }
    Item {
        id: toolBar
        property int padding: Theme.itemSpacingSmall
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: -1
            bottomMargin: switcherRoot.closeMode ? statusbar.height : -height
        }
        Behavior on anchors.bottomMargin { PropertyAnimation { duration: 100 } }
        z: 202
        height:Theme.itemHeightLarge + 2 * toolBar.padding

        Rectangle {
            anchors.fill: parent
            color: Theme.fillDarkColor
            opacity: 0.3
            border {
                width: size.dp(1)
                color: Theme.backgroundColor
            }
        }

        Row {
            anchors {
                top: parent.top
                margins: toolBar.padding
                right: parent.right
                left: parent.left
                bottom:  parent.bottom
            }
            spacing: toolBar.padding * 2

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
                primary: true
            }
        }
    }

    // Empty switcher indicator
    Text {
        id: noAppsOpenText
        visible: switcherModel.itemCount === 0
        text: qsTr("Nothing open yet")
        anchors.centerIn: parent
        fontSizeMode: Text.Fit
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.textColor
    }
    //TODO: fix this QtGraphicalEffects removed from Qt6
    /*DropShadow {
        anchors.fill: noAppsOpenText
        horizontalOffset: noAppsOpenText.height/15
        verticalOffset: noAppsOpenText.height/10
        radius: noAppsOpenText.height/10
        samples: 4
        color: "#80000000"
        source: noAppsOpenText
        visible: switcherModel.itemCount === 0
    }*/
}
