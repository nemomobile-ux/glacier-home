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
    property string source
    property alias iconCaption: launcherItem.iconCaption
    property bool reordering: launcherItem.reordering
    property bool isFolder
    property int folderAppsCount
    property bool notNemoIcon
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
        folderAppsCount:wrapper.folderAppsCount
        isFolder: wrapper.isFolder
        notNemoIcon:wrapper.notNemoIcon
        parentItem: wrapper.parent
        source: wrapper.source
        clip: true
        onClicked: {
            // TODO: disallow if close mode enabled
            if (modelData.object.type !== LauncherModel.Folder) {
                var winId = switcher.switchModel.getWindowIdForTitle(modelData.object.title)
                if (winId == 0 || !modelData.object.isLaunching)
                    modelData.object.launchApplication()
                else
                    Lipstick.compositor.windowToFront(winId)
            } else {
                folderLoader.model = modelData.object
                folderLoader.visible = true
            }
        }
        Rectangle {
            id:triangle
            width: wrapper.height/4
            height: width
            rotation: 45
            color: "white"
            opacity: 0.85
            visible: folderLoader.visible && folderLoader.count > 0
            anchors.top:launcherItem.bottom
            anchors.horizontalCenter: launcherItem.horizontalCenter
        }
    }

    GridView {
        id: folderLoader
        property Item reorderItem
        property bool isRootFolder:false
        cacheBuffer: folderLoader.contentHeight
        parent: gridview.contentItem
        y: wrapper.y + wrapper.width
        x: 0
        z: wrapper.z + 100
        width: gridview.width
        height: count==0 ? 0 :  (Math.floor((count*wrapper.height-1)/width) + 1) * wrapper.height
        cellWidth: wrapper.width
        cellHeight: wrapper.width
        visible:false

        Rectangle {
            width: parent.width
            height: parent.height
            opacity: 0.85
            color: triangle.color
            radius: Theme.itemSpacingMedium
            z: -1
        }

        delegate: LauncherItemDelegate {
            id:folderLauncherItem
            property QtObject modelData : model
            property int cellIndex: index
            parent: folderLoader
            parentItem: folderLoader
            width: wrapper.width
            height: wrapper.height
            notNemoIcon:  isFolder || model.object.iconId == "" ? false : model.object.iconId.indexOf("harbour") > -1  ||  model.object.iconId.indexOf("apkd_launcher") > -1 ? true : false //Dirty but works most of the times
            isFolder: model.object.type == LauncherModel.Folder
            folderAppsCount: isFolder && model.object ? model.object.itemCount : 0
            source: model.object.iconId == "" || isFolder ? "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
            iconCaption.text: model.object.title
            iconCaption.color: Theme.backgroundColor
            folderModel:folderLoader.model
        }
    }

    //When display goes off, close the folderloader
    Connections {
        target: Lipstick.compositor
        onDisplayOff: {
            folderLoader.visible=false
            folderLoader.model = 0
        }
    }
    Connections {
        target: Lipstick.compositor
        onWindowAdded: {
            if(window.category=="" && window.title !== "Home"){
                folderLoader.visible=false
                folderLoader.model = 0
            }
        }
    }

    InverseMouseArea {
        anchors.fill: folderLoader
        enabled: folderLoader.visible && folderLoader.count > 0
        parent:folderLoader.contentItem
        onPressed: {
            folderLoader.visible=false
            folderLoader.model = 0
        }
    }


}

