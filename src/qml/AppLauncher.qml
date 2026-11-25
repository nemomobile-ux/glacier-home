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
// Copyright (c) 2018-2025, Chupligin Sergey <neochapay@gmail.com>
*/

import QtQuick

import org.nemomobile.lipstick
import Nemo.Configuration
import Nemo.Notifications
import Nemo
import Nemo.Controls

import "applauncher"

// App Launcher page
// the place for browsing installed applications and launching them

Flickable{
    id: appLauncher
    width: parent.width
    height: desktop.height
    property var switcher: null
    property alias searchString: searchListView.searchString
    property var contextMenuItem: null
    property string uninstallingDesktopFile: ""

    ConfigurationValue {
        id: alwaysShowSearch
        key: "/home/glacier/appLauncher/alwaysShowSearch"
        defaultValue: true

        onValueChanged: {
            searchListView.visible =  alwaysShowSearch.value
            searchListView.calculateHeight()
        }
    }

    LauncherFolderModel{
        id: launcherModel

        Component.onCompleted: {
            blacklistedApplications = fileUtils.getBlacklistedApplications();
        }
    }

    Connections {
        target: pkgUtils
        function onPackageManagerTransactionStarted() {
            uninstallNotification.summary = qsTr("Uninstalling application")
            uninstallNotification.body = ""
            uninstallNotification.progress = -1
            uninstallNotification.publish()
        }

        function onPackageManagerActionProgress(action, status, progress) {
            if (action) {
                uninstallNotification.summary = action
            }
            if (status) {
                uninstallNotification.body = status
            }
            uninstallNotification.progress = progress
            uninstallNotification.publish()
        }

        function onPackageManagerTransactionFinished() {
            uninstallNotification.progress = 0
            uninstallNotification.close()
            appLauncher.uninstallingDesktopFile = ""
        }
    }

    Notification{
        id: uninstallNotification
        appName: qsTr("Package manager")
        itemCount: 1
    }

    /*top search line*/
    SearchListView {
        id: searchListView
        width: appLauncher.width
        visible: alwaysShowSearch.value

        anchors{
            top: parent.top
            topMargin: Theme.itemHeightSmall
        }

        Timer{
            id: searchListViewTimer;
            running: false;
            interval: 7000;
            repeat: true
            onTriggered: {
                if(searchString.length < 1 && alwaysShowSearch.value == false)
                {
                    searchListView.cleanup()
                }
            }
        }
    }

    Connections {
        target: lockScreen
        function onVisibleChanged() {
            if(LipstickSettings.lockscreenVisible) {
                searchListView.cleanup()
                appLauncher.contextMenuItem = null
            }
        }
    }

    Connections {
        target: Lipstick.compositor
        function onDisplayOff() {
            searchListView.cleanup()
            appLauncher.contextMenuItem = null
        }
        function onWindowAdded(window) {
            if(window.category === ""
               && window.title !== "Home"
               && window.title !== "maliit-server")
            {
                searchListView.cleanup()
                appLauncher.contextMenuItem = null
            }
        }
        function onWindowRaised(window) {
            if(window.category === ""
                    && window.title !== "Home"
                    && window.title !== "maliit-server"){
                searchListView.cleanup()
                appLauncher.contextMenuItem = null
            }
        }
    }

    onSearchStringChanged: searchListViewTimer.restart()

    /*app grid*/

    Item {
        id: appLauncherGridContainer
        width: parent.width
        height: parent.height - searchListView.height

        anchors.top: searchListView.bottom

        GridView {
            id: gridview
            cellWidth:  parent.width/Math.round(parent.width/Theme.itemWidthSmall)
            cellHeight: cellWidth+Theme.itemSpacingMedium+Theme.fontSizeTiny*3

            height: parent.height
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

            y: Theme.itemSpacingHuge

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
                            launcherItem.source = modelData.object.iconId == "" ? "/usr/share/glacier-home/qml/theme/default-icon.png" : (modelData.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + modelData.object.iconId
                        }
                    }

                    onContextMenuRequested: {
                        appLauncher.contextMenuItem = modelData ? modelData.object : null
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
    }

    FolderView{
        id: folderLoader
        onContextMenuRequested: function(appObject) {
            appLauncher.contextMenuItem = appObject
        }
    }

    //When display goes off, close the folderloader
    Connections {
        target: Lipstick.compositor
        function onDisplayOff() {
            folderLoader.model = 0
        }
    }

    Item {
        id: contextMenuOverlay
        visible: appLauncher.contextMenuItem !== null
        width: appLauncher.width
        height: appLauncher.height
        y: appLauncher.contentY
        z: 10000000000

        MouseArea {
            anchors.fill: parent
            onClicked: appLauncher.contextMenuItem = null
        }

        Rectangle {
            id: contextMenuPanel
            width: Math.min(parent.width * 0.6, Theme.itemWidthExtraLarge)
            height: contextMenuColumn.height + Theme.itemSpacingMedium * 2
            radius: Theme.itemSpacingSmall
            color: Theme.backgroundColor
            border.color: Theme.textColor
            border.width: 1
            anchors.centerIn: parent

            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: contextMenuColumn
                width: parent.width - Theme.itemSpacingMedium * 2
                anchors.centerIn: parent
                spacing: Theme.itemSpacingSmall

                Label {
                    width: parent.width
                    text: appLauncher.contextMenuItem ? appLauncher.contextMenuItem.title : ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                Button {
                    width: parent.width
                    height: Theme.itemHeightSmall
                    text: qsTr("Uninstall")
                    onClicked: {
                        if (appLauncher.contextMenuItem) {
                            var filePath = appLauncher.contextMenuItem.filePath
                            var title = appLauncher.contextMenuItem.title || ""
                            if (filePath) {
                                appLauncher.uninstallingDesktopFile = filePath
                                if (!pkgUtils.uninstallApplication(filePath)) {
                                    appLauncher.uninstallingDesktopFile = ""
                                    uninstallNotification.summary = qsTr("Package not found")
                                    uninstallNotification.body = filePath || title
                                    uninstallNotification.progress = 0
                                    uninstallNotification.publish()
                                }
                            } else {
                                uninstallNotification.summary = qsTr("Package not found")
                                uninstallNotification.body = title
                                uninstallNotification.progress = 0
                                uninstallNotification.publish()
                            }
                        }
                        appLauncher.contextMenuItem = null
                    }
                }

                Button {
                    width: parent.width
                    height: Theme.itemHeightSmall
                    text: qsTr("Cancel")
                    onClicked: appLauncher.contextMenuItem = null
                }
            }
        }
    }
}
