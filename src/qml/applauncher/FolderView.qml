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
// Copyright (c) 2020-2024, Chupigin Sergey <neochapay@gmail.com>

import QtQuick
import Nemo.Controls

import org.nemomobile.lipstick

Item{
    id: folderLoader
    parent: desktop
    z: 9999999999

    width: desktop.width
    height: desktop.height

    opacity: 0

    property alias model: folderGridView.model
    property alias count: folderGridView.count
    property alias reorderItem: folderGridView.reorderItem

    Rectangle {
        width: folderLoader.width
        height: folderLoader.height

        opacity: 0.85
        color: Theme.backgroundColor
        z: -1
    }

    onReorderItemChanged: if(reorderItem == null) folderIconStack.icons=folderIconStack.addIcons()

    onModelChanged: {
        if(model == 0) {
            folderName.focus = false
            opacity = 0
        } else {
            opacity = 1
            folderName.text = model.title
        }
    }

    Item {
        id: mainFolderItem
        width: parent.width
        height: childrenRect.height

        IconButton {
            id: closeButton
            width: height
            height: Theme.itemHeightMedium
            source: "image://theme/times-circle"

            anchors {
                top: parent.top
                topMargin: Theme.itemSpacingSmall
                right: parent.right
                rightMargin: Theme.itemSpacingSmall
            }

            onClicked: {
                closeFolder()
            }
        }

        //Show/Edit folder name
        TextField {
            id: folderName
            width: parent.width - Theme.itemSpacingHuge*2
            visible: folderLoader.model != 0

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: Theme.itemSpacingHuge
                leftMargin: Theme.itemSpacingMedium
                rightMargin: Theme.itemSpacingMedium
                bottomMargin:Theme.itemSpacingHuge
            }

            color : Theme.textColor

            onAccepted: {
                model.title = folderName.text
            }

            onFocusChanged: {
                if(focus == false && model.title != folderName.text) {
                    model.title = folderName.text
                }
            }
        }

        GridView {
            // view of apps in folder
            id: folderGridView
            property Item reorderItem
            property bool isRootFolder:false
            property int folderIndex: -1
            property bool onUninstall: false

            cacheBuffer: (folderGridView.contentHeight > 0) ? folderGridView.contentHeight : 0

            width: parent.width
            height: childrenRect.height

            anchors{
                top: folderName.bottom
                topMargin: Theme.itemSpacingMedium
            }

            cellWidth:  parent.width/Math.round(parent.width/Theme.itemWidthSmall)
            cellHeight: cellWidth+Theme.itemSpacingMedium+Theme.fontSizeTiny*3

            delegate: LauncherItemDelegate {
                id:folderLauncherItem
                property QtObject modelData : model
                property int cellIndex: index
                parent: folderGridView
                parentItem: folderGridView
                width: folderGridView.cellWidth
                height: folderGridView.cellHeight
                isFolder: model.object.type == LauncherModel.Folder
                source: model.object.iconId == "" || isFolder ? "/usr/share/lipstick-glacier-home-qt6/qml/theme/default-icon.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
                iconCaption.text: model.object.title
                iconCaption.color: Theme.textColor
                folderModel:folderGridView.model
            }
        }

        InverseMouseArea {
            anchors.fill: parent
            enabled: folderLoader.width == desktop.width

            onPressed: {
                closeFolder();
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            easing.type: Easing.InQuad
            duration: 400
        }
    }

    function closeFolder() {
        folderLoader.model = 0
    }
}
