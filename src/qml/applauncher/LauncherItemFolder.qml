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
// Copyright (c) 2017, Eetu Kahelin
// Copyright (c) 2013, Jolla Ltd <robin.burchell@jollamobile.com>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>

import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: wrapper
    property alias iconCaption: iconText
    property bool reordering: launcherItem.reordering
    property bool isFolder
    property int folderAppsCount
    property alias folderLoader: folderLoader
    property alias folderModel:launcherItem.folderModel
    onXChanged: moveTimer.start()
    onYChanged: moveTimer.start()

    Timer {
        id: moveTimer
        interval: 1
        onTriggered: moveIcon()
    }

    function moveIcon() {
        if (!reordering) {
            if (!launcherItem.slideMoveAnim.running) {
                launcherItem.slideMoveAnim.start()
            }
        }
    }
    // Application icon for the launcher
    LauncherItemWrapper {
        id: launcherItem
        width: wrapper.width
        height: wrapper.height
        isFolder: wrapper.isFolder
        parentItem: wrapper.parent

        clip: true
        onClicked: {
            // TODO: disallow if close mode enabled
            if (modelData.object.type === LauncherModel.Folder) {
                if(folderLoader.count > 0 || reopenTimer.running) {
                    folderLoader.model = 0
                } else {
                    folderLoader.model = modelData.object
                }
            }
        }

        Item {
            id:folderIconStack
            width: parent.width
            height: parent.height - iconText.height
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round((parent.height - (height + iconText.height)) / 2)
            property int iconSize: Theme.iconSizeLauncher * 0.9
            property real transparency: 0.6
            property int iconCount: 4
            property var icons: addIcons()

            function addIcons() {
                var iconsList = []
                for (var i = 0; i < modelData.object.itemCount && i < iconCount; i++) {
                    var icon = (modelData.object.get(i).iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + modelData.object.get(i).iconId
                    iconsList.push(icon)
                }
                return iconsList
            }

            Image {
                width: folderIconStack.iconSize
                height: folderIconStack.iconSize
                x:toppestIcon.x+Theme.itemSpacingSmall
                y:toppestIcon.y+Theme.itemSpacingSmall
                visible: folderIconStack.icons.length > folderIconStack.iconCount-1
                source: visible ? folderIconStack.icons[folderIconStack.iconCount-1] : ""
            }

            Image {
                width: folderIconStack.iconSize
                height: folderIconStack.iconSize
                x:toppestIcon.x-Theme.itemSpacingSmall
                y:toppestIcon.y+Theme.itemSpacingSmall
                visible: folderIconStack.icons.length > folderIconStack.iconCount-2
                source: visible ? folderIconStack.icons[folderIconStack.iconCount-2] : ""
            }

            Image {
                width: folderIconStack.iconSize
                height: folderIconStack.iconSize
                x:toppestIcon.x+Theme.itemSpacingSmall
                y:toppestIcon.y-Theme.itemSpacingSmall
                visible: folderIconStack.icons.length > folderIconStack.iconCount-3
                source: visible ? folderIconStack.icons[folderIconStack.iconCount-3] : ""
            }

            Image {
                id:toppestIcon
                width: folderIconStack.iconSize
                height: folderIconStack.iconSize
                anchors.centerIn: parent
                visible: folderIconStack.icons.length > 0
                source: visible ? folderIconStack.icons[0]: ""
            }

            Text{
                id: itemsCount
                visible: false// launcherItem.isFolder
                text: wrapper.folderAppsCount
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: folderIconStack.iconSize.width/4
                color: "white"
            }
        }
        // Caption for the icon
        Text {
            id: iconText
            // elide only works if an explicit width is set
            width: launcherItem.width
            height: Theme.fontSizeTiny*3

            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.textColor
            //https://bugreports.qt.io/browse/QTBUG-56052
            y: -contentHeight + font.pixelSize + folderIconStack.y + folderIconStack.height
            anchors {
                left: parent.left
                right: parent.right
            }
        }

        Rectangle {
            id:triangle
            width: wrapper.height/4
            height: width
            rotation: 45
            color: Theme.textColor
            opacity: 0.85
            visible: folderLoader.visible && folderLoader.count > 0
            anchors.top:launcherItem.bottom
            anchors.horizontalCenter: launcherItem.horizontalCenter
        }
    }

    FolderView{
        id: folderLoader
    }

    //When display goes off, close the folderloader
    Connections {
        target: Lipstick.compositor
        function onDisplayOff() {
            folderLoader.model = 0
        }
    }

    Timer {
        id: reopenTimer
        interval: 300
        running: false
    }
}

