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
// Copyright (c) 2021-2024, Sergey Chupligin <neochapay@gmail.com>
// Copyright (c) 2017, Eetu Kahelin
// Copyright (c) 2013, Jolla Ltd <robin.burchell@jollamobile.com>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>

import QtQuick
import Nemo
import Nemo.Controls
import org.nemomobile.lipstick

Item {
    id: wrapper
    property alias iconCaption: iconText
    property bool reordering: launcherItem.reordering
    property bool isFolder
    property int folderAppsCount
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
                if(folderLoader.count > 0) {
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
            property int iconCount: 9
            property var icons: addIcons()

            function addIcons() {
                var iconsList = []
                for (var i = 0; i < modelData.object.itemCount && i < iconCount; i++) {
                    var icon = (modelData.object.get(i).iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + modelData.object.get(i).iconId
                    iconsList.push(icon)
                }
                return iconsList
            }

            Grid{
                id: iconFolderViwe
                width: folderIconStack.width
                height: width

                columns: folderIconStack.icons.length > 4 ? 3 : 2
                rows: folderIconStack.icons.length > 4 ? 3 : 2

                Repeater{
                    id: iconRepeater
                    model: folderIconStack.icons

                    Item{
                        id: iconWrapper
                        width: iconFolderViwe.width/iconFolderViwe.columns
                        height: width

                        Image{
                            id: iconImage
                            width: iconWrapper.width-Theme.itemSpacingExtraSmall
                            height: width
                            anchors.centerIn: parent
                            source: model.modelData

                            onStatusChanged: {
                                if (iconImage.status == Image.Error) {
                                    iconImage.source = "/usr/share/glacier-home/qml/theme/default-icon.png"
                                }
                            }
                        }
                    }
                }
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
    }
}

