
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
// Copyright (c) 2017, Eetu Kahelin

import QtQuick 2.6
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

// App Launcher page
// the place for browsing installed applications and launching them

GridView {
    id: gridview
    cellWidth: cellSize
    cellHeight: cellSize
    width: parent.width
    cacheBuffer: gridview.contentHeight
    property Item reorderItem
    property bool onUninstall
    property alias deleter: deleter
    property var switcher: null
    property int cellSize: Math.min(parent.width,parent.height)/4
    property int folderIndex: -1
    property bool isRootFolder:true
    property bool newFolderActive
    property bool newFolder: newFolderActive &&  isRootFolder && folderIndex >= 0


    // just for margin purposes
    header: Item {
        height: Math.min(parent.width,parent.height)/10
    }
    footer: Item {
        height: Math.min(parent.width,parent.height)/10
    }

    Item {//todo
        id: deleter
        anchors.top: parent.top
        property alias remove: remove
        property alias uninstall: uninstall
        Rectangle {//todo
            id: remove
            property alias text: removeLabel.text
            visible: onUninstall
            height: 110
            color: "red"
            width: gridview.width / 2
            Label {
                id: removeLabel
                anchors.centerIn: parent
                text: qsTr("Remove")
                font.pointSize: 8
            }
        }
        Rectangle {//todo
            id: uninstall
            property alias text: uninstallLabel.text
            anchors.left: remove.right
            visible: onUninstall
            color: "red"
            width: gridview.width / 2
            height: 110
            Label {
                id: uninstallLabel
                anchors.centerIn: parent
                text: qsTr("Uninstall")
                font.pointSize: 8
            }
        }
    }

    onFolderIndexChanged: if (folderIndex == -1) newFolderActive = false

    model: LauncherFolderModel { id: launcherModel }
    //Using loader that in the future we can also have widgets as delegate
    delegate: Loader {
        id:loader
        width: cellSize
        height: cellSize
        onXChanged: item.x = x
        onYChanged: item.y = y
        property QtObject modelData : model
        property int cellSize: gridview.cellHeight
        property int cellIndex: index
        sourceComponent: object.type == LauncherModel.Folder ? folder : app
    }

    Component {
        id:app
        LauncherItemDelegate {
            id: launcherItem
            parent: gridview
            parentItem: gridview
            iconCaption.color:Theme.textColor
            iconCaption.text: modelData.object.title
            isFolder: modelData.object.type == LauncherModel.Folder
            source: modelData.object.iconId == "" ? "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png" : (modelData.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + modelData.object.iconId
            notNemoIcon:  isFolder || modelData.object.iconId == "" ? false : modelData.object.iconId.indexOf("harbour") > -1  ||  modelData.object.iconId.indexOf("apkd_launcher") > -1 ? true : false
            folderModel:launcherModel
        }
    }
    Component {
        id:folder
        LauncherItemFolder {
            id: launcherfolder
            parent: gridview
            iconCaption.color:Theme.textColor
            iconCaption.text: modelData.object.title
            isFolder: modelData.object.type == LauncherModel.Folder
            folderAppsCount: isFolder && modelData.object ? modelData.object.itemCount : 0
            notNemoIcon:  isFolder || modelData.object.iconId == "" ? false : modelData.object.iconId.indexOf("harbour") > -1  ||  modelData.object.iconId.indexOf("apkd_launcher") > -1 ? true : false
            folderModel:launcherModel
        }
    }
}
