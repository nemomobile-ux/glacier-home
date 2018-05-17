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
// Copyright (c) 2018, Chupligin Sergey <neochapay@gmail.com>

import QtQuick 2.6

import org.nemomobile.lipstick 0.1
import org.nemomobile.configuration 1.0

import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0


import "applauncher"

// App Launcher page
// the place for browsing installed applications and launching them

Flickable{
    id: appLauncher
    width: parent.width
    height: desktop.height
    property var switcher: null
    property string searchString

    ConfigurationValue {
        id: alwaysShowSearch
        key: "/home/glacier/appLauncher/alwaysShowSearch"
        defaultValue: true
    }

    /*top search line*/
    SearchListView {
        id: searchListView
        width: appLauncher.width
        visible: alwaysShowSearch

        Timer{
            id: searchListViewTimer;
            running: false;
            interval: 7000;
            repeat: true
            onTriggered: {
                if(searchString.length < 1 && !alwaysShowSearch)
                {
                    headerItem.visible = false
                }
            }
        }
    }

    Connections {
        target: lockScreen
        onVisibleChanged: {
            if(lockscreenVisible()) {
                searchListView.cleanup()
            }
        }
    }

    Connections {
        target: Lipstick.compositor
        onDisplayOff: {
            searchListView.cleanup()
        }
        onWindowAdded: {
            if(window.category === "" && window.title !== "Home"){
                searchListView.cleanup()
            }
        }
        onWindowRaised: {
            if(window.category === "" && window.title !== "Home"){
                searchListView.cleanup()
            }
        }
    }

    onSearchStringChanged: searchListViewTimer.restart()

    /*app grid*/
    GridView {
        id: gridview
        width: parent.width
        height: parent.height-searchListView.height-Theme.itemSpacingHuge

        visible: searchString.length === 0

        cacheBuffer: gridview.contentHeight
        property Item reorderItem
        property bool onUninstall

        property int minCellSize: Theme.iconSizeLauncher +  Theme.iconSizeLauncher/2
        property int rows: Math.floor(parent.height / minCellSize)
        property int columns:  Math.floor(parent.width / minCellSize)

        cellWidth: parent.width / columns
        cellHeight: Math.round(parent.height / rows)

        anchors{
            top: searchListView.bottom
            topMargin: Theme.itemSpacingHuge
        }

        property int folderIndex: -1
        property bool isRootFolder:true
        property bool newFolderActive
        property bool newFolder: newFolderActive &&  isRootFolder && folderIndex >= 0
        clip: true

        /*onContentYChanged: {
            if( contentY < -Theme.itemHeightHuge ) {
                headerItem.visible = true;
                timer.running = true;
            }
        }*/

        footer: Item {
            height: Theme.itemHeightLarge*1.5
        }

        onFolderIndexChanged: if (folderIndex == -1) newFolderActive = false

        model: LauncherFolderModel{
            id: launcherModel
        }

        //Using loader that in the future we can also have widgets as delegate
        delegate: Loader {
            id:loader
            width: gridview.cellWidth
            height: gridview.cellHeight
            onXChanged: item.x = x
            onYChanged: item.y = y
            property QtObject modelData : model
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

    Deleter{
        id: deleter
        anchors{
            bottom: parent.bottom
        }

        state: "uninstall"
    }
}
