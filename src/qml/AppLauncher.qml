/* This file is part of glacier-home, a nice user experience for touchscreens.
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
// Copyright (c) 2018-2023, Chupligin Sergey <neochapay@gmail.com>
*/

import QtQuick 2.6

import org.nemomobile.lipstick 0.1
import Nemo.Configuration 1.0

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

        onValueChanged: {
            searchListView.visible =  alwaysShowSearch.value
            searchListView.calculateHeight()
        }
    }

    ConfigurationValue {
        id: columnCount
        key: "/home/glacier/appLauncher/columnCount"
        defaultValue: 5
    }


    LauncherFolderModel{
        id: launcherModel

        Component.onCompleted: {
            blacklistedApplications = fileUtils.getBlacklistedApplications();
        }
    }

    /*top search line*/
    SearchListView {
        id: searchListView
        width: appLauncher.width
        visible: alwaysShowSearch.value

        Timer{
            id: searchListViewTimer;
            running: false;
            interval: 7000;
            repeat: true
            onTriggered: {
                if(searchString.length < 1 && !alwaysShowSearch.value == true)
                {
                    searchListView.visible = false
                    searchListView.height = 0
                }
            }
        }
    }

    Connections {
        target: lockScreen
        function onVisibleChanged() {
            if(lockscreenVisible()) {
                searchListView.cleanup()
            }
        }
    }

    Connections {
        target: Lipstick.compositor
        function onDisplayOff() {
            searchListView.cleanup()
        }
        function onWindowAdded(window) {
            if(window.category === "" && window.title !== "Home"){
                searchListView.cleanup()
            }
        }
        function onWindowRaised(window) {
            if(window.category === "" && window.title !== "Home"){
                searchListView.cleanup()
            }
        }
    }

    onSearchStringChanged: searchListViewTimer.restart()

    /*app grid*/

    GridView {
        id: gridview
        cellWidth:  Math.min(parent.width, parent.height)/columnCount.value
        cellHeight: cellWidth+Theme.itemSpacingMedium+Theme.fontSizeTiny*3

        height: parent.height
        anchors.top: searchListView.bottom
        anchors.topMargin: Theme.itemSpacingMedium
        anchors.bottom: parent.bottom
        width: parent.width

        cacheBuffer: (gridview.contentHeight > 0) ? gridview.contentHeight : 0

        property Item reorderItem
        property bool onUninstall
        property var switcher: null
        property int iconSize: Theme.itemHeightSmall

        maximumFlickVelocity: parent.Height * 4

        visible: searchString.length === 0

        property int minCellSize: Theme.iconSizeLauncher +  Theme.iconSizeLauncher/2
        property int rows: Math.floor(parent.height / cellWidth)
        property int columns:  Math.floor(parent.width / cellHeight)

        y: searchListView.visible ? searchListView.height+Theme.itemSpacingHuge : Theme.itemSpacingHuge

        Behavior on y {
            NumberAnimation { duration: 200 }
        }

        onContentYChanged: {
            if( contentY < -Theme.itemHeightHuge && alwaysShowSearch.value == false ) {
                searchListView.visible = true
                searchListViewTimer.running = true
            }
        }

        property int folderIndex: -1
        property bool isRootFolder:true
        property bool newFolderActive
        property bool newFolder: newFolderActive &&  isRootFolder && folderIndex >= 0
        clip: true

        footer: Item {
            height: Math.min(desktop.width,desktop.height)/10
        }

        onFolderIndexChanged: if (folderIndex == -1) newFolderActive = false

        model: launcherModel

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
                folderModel:launcherModel

                Component.onCompleted: {
                    if(modelData) {
                        launcherItem.iconCaption.text = modelData.object.title
                        launcherItem.isFolder = modelData.object.type == LauncherModel.Folder
                        launcherItem.source = modelData.object.iconId == "" ? "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png" : (modelData.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + modelData.object.iconId
                    }
                }
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
                folderModel:launcherModel
            }
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
}
