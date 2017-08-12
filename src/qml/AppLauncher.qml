
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
    width: cellWidth * columns
    cacheBuffer: gridview.contentHeight
    property Item reorderItem
    property bool onUninstall
    property alias deleter: deleter
    property var switcher: null
    property string searchString
    property int minCellSize: Theme.iconSizeLauncher + Theme.itemSpacingHuge
    property int rows: Math.floor(parent.height / minCellSize)
    property int columns:  Math.floor(parent.width / minCellSize)

    cellWidth: parent.width / columns
    cellHeight: Math.round(parent.height / rows)

    property int folderIndex: -1
    property bool isRootFolder:true
    property bool newFolderActive
    property bool newFolder: newFolderActive &&  isRootFolder && folderIndex >= 0
    clip: true

    onContentYChanged: {
        if( contentY < -140 ) {
            headerItem.visible = true;
            timer.running = true;
        }
    }

    onSearchStringChanged: timer.restart()

    Timer{
        id: timer; running: false; interval: 7000; repeat: true
        onTriggered: {
            if(searchString.length < 1 ) headerItem.visible = false
        }
    }
    Connections {
        target: headerItem
        onHeightChanged:{
            if(headerItem.oldHeight < headerItem.height)
                if(!flicking) gridview.contentY = headerItem.y
            headerItem.oldHeight = headerItem.height
        }
        onVisibleChanged:timer.restart()
    }
    Connections {
        target: Lipstick.compositor
        onDisplayOff: {
            headerItem.searchField.text = ""
            headerItem.visible = false
        }
        onWindowAdded: {
            if(window.category=="" && window.title !== "Home"){
                headerItem.searchField.text = ""
                headerItem.visible = false
            }
        }
        onWindowRaised: {
            if(window.category=="" && window.title !== "Home"){
                headerItem.searchField.text = ""
                headerItem.visible = false
            }
        }
    }
    Connections {
        target: pager
        onFlickEnded: {
            headerItem.searchField.text = ""
            headerItem.visible = false

        }
    }
    Connections {
        target: lockScreen
        onVisibleChanged: {
            if(lockscreenVisible()) {
                headerItem.searchField.text = ""
                headerItem.visible = false
            }
        }
    }

    header: SearchListView {
        width: gridview.width
    }

    footer: Item {
        height: Theme.itemHeightLarge*1.5
    }

    Item {//Doesn't yet uninstall applications
        id: deleter
        anchors.top: parent.top
        property alias remove: remove
        property alias uninstall: uninstall
        function uninstalling(action, caption) {
            state = action
            if (action==="remove") {
                remove.text = qsTr("Removing") + " " + caption
            } else if (action == "uninstall") {
                uninstall.text = qsTr("Uninstalling") + " " + caption
            }
        }

        states: [
            State {
                name: "remove"
                PropertyChanges {
                    target: remove
                    color1: "#D9ff0000"
                    color2: "#D9ff0000"
                    color3: "#D9ff0000"
                }
                PropertyChanges {
                    target: uninstall
                    color1: "#D9ff0000"
                    color2: "#80ff0000"
                    color3: "#4Dff0000"
                }
                PropertyChanges {
                    target: uninstall
                    text: qsTr("Uninstall")
                }
            },
            State {
                name: "uninstall"
                PropertyChanges {
                    target: uninstall
                    color1: "#D9ff0000"
                    color2: "#D9ff0000"
                    color3: "#D9ff0000"
                }
                PropertyChanges {
                    target: remove
                    color1: "#D9ff0000"
                    color2: "#80ff0000"
                    color3: "#4Dff0000"
                }
                PropertyChanges {
                    target: remove
                    text: qsTr("Remove")
                }
            },
            State {
                name:"basic"
                PropertyChanges {
                    target: remove
                    color1: "#D9ff0000"
                    color2: "#80ff0000"
                    color3: "#4Dff0000"
                }
                PropertyChanges {
                    target: remove
                    text: qsTr("Remove")
                }
                PropertyChanges {
                    target: uninstall
                    color1: "#D9ff0000"
                    color2: "#80ff0000"
                    color3: "#4Dff0000"
                }
                PropertyChanges {
                    target: uninstall
                    text: qsTr("Uninstall")
                }
            }
        ]

        Rectangle {//WHY?
            id: remove
            property color color1: "#D9ff0000"
            property color color2: "#80ff0000"
            property color color3: "#4Dff0000"
            property alias text: removeLabel.text
            visible: gridview.onUninstall
            height: Theme.itemHeightExtraLarge
            width: gridview.width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: remove.color1 }
                GradientStop { position: 0.5; color: remove.color2 }
                GradientStop { position: 1.0; color: remove.color3 }
            }

            Label {
                id: removeLabel
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                text: qsTr("Remove")
                font.pixelSize: Theme.fontSizeLarge
                elide:Text.ElideRight
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment:Text.AlignVCenter
            }
        }
        Rectangle {
            id: uninstall
            property color color1: "#D9ff0000"
            property color color2: "#80ff0000"
            property color color3: "#4Dff0000"
            property alias text: uninstallLabel.text
            anchors.left: remove.right
            visible: gridview.onUninstall
            width: gridview.width / 2
            height: Theme.itemHeightExtraLarge
            gradient: Gradient {
                GradientStop { position: 0.0; color: uninstall.color1 }
                GradientStop { position: 0.5; color: uninstall.color2 }
                GradientStop { position: 1.0; color: uninstall.color3 }
            }
            Label {
                id: uninstallLabel
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                text: qsTr("Uninstall")
                font.pixelSize: Theme.fontSizeLarge
                elide:Text.ElideRight
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment:Text.AlignVCenter
            }
        }
    }

    onFolderIndexChanged: if (folderIndex == -1) newFolderActive = false

    model: LauncherFolderModel { id: launcherModel }
    //Using loader that in the future we can also have widgets as delegate
    delegate: Loader {
        id:loader
        width: cellWidth
        height: cellHeight
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
