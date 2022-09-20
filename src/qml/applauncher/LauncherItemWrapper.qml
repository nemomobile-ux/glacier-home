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
// Copyright (c) 2022, Chupligin Sergey (NeoChapay) <neochapay@gmail.com>
// Copyright (c) 2017, Eetu Kahelin
// Copyright (c) 2013, Jolla Ltd <robin.burchell@jollamobile.com>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>

import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.lipstick 0.1

MouseArea {
    property bool reordering
    property int newIndex: -1
    property int newFolderIndex: -1
    property real oldY
    property bool isFolder
    property bool onUninstall: false
    property Item parentItem
    property alias slideMoveAnim: slideMoveAnim
    property QtObject folderModel
    property Item folderItem
    property string deleteState: "basic"

    id: launcherItem
    parent: parentItem.contentItem
    transformOrigin: Item.Center
    onXChanged: moved()
    onYChanged: moved()

    drag.minimumX: (parentItem.contentItem !== null) ? parentItem.contentItem.x - width/2 : 0
    drag.maximumX: (parentItem.contentItem !== null) ? parentItem.contentItem.childrenRect.width + width/2 : 0
    drag.minimumY: (parentItem.contentItem !== null) ? parentItem.contentItem.y -height/2 -height/4 : 0
    drag.maximumY: (parentItem.contentItem !== null) ? parentItem.contentItem.childrenRect.height +height/2 : 0

    Component.onCompleted:  {
        if(parentItem) {
            launcherItem.scale = gridview.newFolder && parentItem.folderIndex == cellIndex && !isFolder ? 0.5 : (reordering || parentItem.folderIndex == cellIndex ? 1.3 : 1)
        } else {
            return;
        }
    }

    onClicked: {
        if(!onUninstall && modelData.object.type !== LauncherModel.Folder) {
            // TODO: disallow if close mode enabled
            var winId = switcher.switchModel.getWindowIdForTitle(modelData.object.title)
            if (winId == 0 && !modelData.object.isLaunching) {
                modelData.object.launchApplication()
            } else {
                Lipstick.compositor.windowToFront(winId)
            }
        }
    }

    onPressed: {
        newIndex = -1
        newFolderIndex = -1
        onUninstall = false
    }

    onMouseXChanged: {
        onUninstall = false
    }

    onMouseYChanged: {
        onUninstall = false
    }

    onPressAndHold: {
        deleteTimer.start()
        reparent(parentItem)
        parentItem.reorderItem = launcherItem
        drag.target = launcherItem
        z = 1000
        reordering = true

        // don't allow dragging an icon out of pages with a horizontal flick
        pager.interactive = false
    }

    onReleased: {
        deleteTimer.stop()

        if (reordering && !onUninstall) {
            reordering = false
            reorderEnded()
            reorderTimer.stop()
            drag.target = null
            parentItem.reorderItem = null
            pager.interactive = true
            parentItem.folderIndex = -1
            reparent(parentItem.contentItem)
            z = parent.z

            slideMoveAnim.start()
        }
    }

    function reparent(newParent) {
        var newPos = mapToItem(newParent, 0, 0)
        parent = newParent
        x = newPos.x - width/2 * (1-scale)
        y = newPos.y - height/2 * (1-scale)
    }

    function moved() {
        if (reordering) {
            var gridViewPos = parentItem.contentItem.mapFromItem(launcherItem, width/2, height/2)
            var item = parentItem.itemAt(gridViewPos.x, gridViewPos.y)
            var idx = -1
            var folderIdx = -1

            if(!item) {
                return;
            }

            //When adding new icon to folder or creating new folder
            var offset = gridViewPos.x - item.x
            var folderThreshold = !isFolder ? item.width / 4 : item.width / 2
            if (offset < folderThreshold) {
                if (Math.abs(cellIndex - item.cellIndex) > 1 || cellIndex > item.cellIndex || item.y !== launcherItemDelegate.offsetY) {
                    idx = cellIndex < item.cellIndex ? item.cellIndex - 1 : item.cellIndex
                    folderItem = null
                }
            } else if (offset >= item.width - folderThreshold) {
                if (Math.abs(cellIndex - item.cellIndex) > 1 || cellIndex < item.cellIndex || item.y !== launcherItemDelegate.offsetY) {
                    idx = cellIndex > item.cellIndex ? item.cellIndex + 1 : item.cellIndex
                    folderItem = null
                }
            } else if (item.cellIndex !== cellIndex && parent.isRootFolder && !isFolder) {
                folderItem = item
                folderIdx = item.cellIndex
            }
            if (newIndex !== idx) {
                newIndex = idx
                reorderTimer.restart()
            }
            if (newFolderIndex != folderIdx) {
                newFolderIndex = folderIdx
                reorderTimer.restart()
            }
            if (newFolderIndex != parentItem.folderIndex) {
                parentItem.folderIndex = -1
            }
        }
    }

    function reorderEnded() {
        if(!modelData){
            return;
        }

        //called when icon is released and reordering is true
        if (parentItem.folderIndex >= 0) {
            if (folderModel.get(parentItem.folderIndex).type == LauncherModel.Application) {
                var folder = folderModel.createFolder(parentItem.folderIndex, qsTr("folder"))
                if (folder) {
                    folderModel.moveToFolder(modelData.object, folder)
                }
            } else {
                folderModel.moveToFolder(modelData.object, folderModel.get(parentItem.folderIndex))
            }
            parentItem.folderIndex = -1
            parentItem.newFolderActive = false
        }
        //To drop appicon out of the folder
        var realY = parseInt(parentItem.mapFromItem(launcherItem, 0, 0).y) + parseInt(((launcherItem.height*launcherItem.scale-launcherItem.height)/2).toFixed(2))
        if (!parent.isRootFolder && (realY < -Math.abs(launcherItem.height/2) || realY > parentItem.height)) {
            var parentFolderIndex = folderModel.parentFolder.indexOf(folderModel)
            folderModel.parentFolder.moveToFolder(modelData.object, folderModel.parentFolder, parentFolderIndex+1)
        }
        if(deleteState != "basic"){
            //Just placeholder to get visual feedback
            enabled=false
        }
    }
    Timer {//Just placeholder to get visual feedback
        id:deleteTimer
        interval: 3000
        onTriggered: {
            slideMoveAnim.start()
            launcherItem.enabled = false
            onUninstall = true
        }
    }

    InverseMouseArea{
        anchors.fill: parent
        onPressed: {
            onUninstall = false
            reordering = false
        }
    }

    Timer {
        id: reorderTimer
        interval: folderItem && folderItem.isFolder ? 10 : 100
        onTriggered: {
            if (newFolderIndex >= 0 && newFolderIndex !== cellIndex) {
                if (!folderItem.isFolder) {
                    parentItem.newFolderActive = true
                } else {
                    parentItem.newFolderActive = false
                }
                parentItem.folderIndex = newFolderIndex
            } else  if (newIndex != -1 && newIndex !== cellIndex) {
                folderModel.move(cellIndex, newIndex)
            }
            newIndex = -1
        }
    }

    Behavior on scale {
        NumberAnimation {
            easing.type: Easing.InOutQuad;
            duration: 150
        }
    }

    ParallelAnimation {
        id: slideMoveAnim
        NumberAnimation {
            target: launcherItem;
            property: "x";
            to: launcherItemDelegate.x;
            duration: 130;
            easing.type: Easing.OutQuint
        }

        NumberAnimation {
            target: launcherItem;
            property: "y";
            to: launcherItemDelegate.y;
            duration: 130;
            easing.type: Easing.OutQuint
        }
    }

    Connections {
        target: modelData.object
        ignoreUnknownSignals: true
        function onItemRemoved(removedModelData) {
            var modelDataObject = modelData.object
            //If there is only one item in folder, remove the folder
            if (modelDataObject.itemCount === 1) {
                var parentFolderIndex = modelDataObject.parentFolder.indexOf(modelDataObject)
                modelDataObject.parentFolder.moveToFolder(modelDataObject.get(0), modelDataObject.parentFolder, parentFolderIndex)
                modelDataObject.destroyFolder()
            }
        }
    }
}
