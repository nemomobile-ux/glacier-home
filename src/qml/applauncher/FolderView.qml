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
// Copyright (c) 2020, Chupigin Sergey <neochapay@gmail.com>

import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1

Item{
    id: folderLoader
    parent: gridview.contentItem
    y: wrapper.y + wrapper.width
    x: 0
    z: 9999999999

    property Item reorderItem
    property bool isRootFolder:false
    property int folderIndex: -1

    property alias model: folderGridView.model
    property alias count: folderGridView.count

    Rectangle {
        width: parent.width
        height: parent.height
        opacity: 0.85
        color: triangle.color
        radius: Theme.itemSpacingMedium
        z: -1
    }

    onReorderItemChanged: if(reorderItem == null) folderIconStack.icons=folderIconStack.addIcons()

    onModelChanged: {
        if(model == 0) {
            width = 0
            height = 0
            x =  wrapper.x + wrapper.width/2
            y = wrapper.y + wrapper.width/2
            folderName.visible = false
            folderName.focus = false
        } else {
            width = desktop.width
            height = desktop.height
            y = 0
            x = 0
            folderName.visible = true
        }
    }
//Show/Edit folder name
    TextField {
        id: folderName
        width: parent.width - Theme.itemSpacingHuge*2
        visible: false //folderLoader.model != 0

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Theme.itemSpacingHuge
            leftMargin: Theme.itemSpacingMedium
            rightMargin: Theme.itemSpacingMedium
            bottomMargin:Theme.itemSpacingHuge
        }

        text: modelData.object.title
        textColor : Theme.backgroundColor

        onAccepted: {
            modelData.object.title = folderName.text
        }

        onFocusChanged: {
            if(focus == false && modelData.object.title != folderName.text) {
                modelData.object.title = folderName.text
            }
        }
    }

    GridView {
        // view of apps in folder
        id: folderGridView
        cacheBuffer: (folderGridView.contentHeight > 0) ? folderGridView.contentHeight : 0

        width: parent.width
        height: parent.height - folderName.height - Theme.itemSpacingHuge*2

        anchors{
            top: folderName.bottom
        }

        cellWidth: wrapper.width
        cellHeight: wrapper.height

        delegate: LauncherItemDelegate {
            id:folderLauncherItem
            property QtObject modelData : model
            property int cellIndex: index
            parent: folderGridView
            parentItem: folderGridView
            width: wrapper.width
            height: wrapper.height
            notNemoIcon:  isFolder || model.object.iconId == "" ? false : model.object.iconId.indexOf("harbour") > -1  ||  model.object.iconId.indexOf("apkd_launcher") > -1 ? true : false //Dirty but works most of the times
            isFolder: model.object.type == LauncherModel.Folder
            source: model.object.iconId == "" || isFolder ? "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
            iconCaption.text: model.object.title
            iconCaption.color: Theme.backgroundColor
            folderModel:folderGridView.model
        }
    }

    Behavior on height {
        NumberAnimation {
            easing.type: Easing.InQuad
            duration: 400
        }
    }

    Behavior on width {
        NumberAnimation {
            easing.type: Easing.InQuad
            duration: 400
        }
    }

    Behavior on x {
        NumberAnimation {
            easing.type: Easing.InQuad
            duration: 400
        }
    }

    Behavior on y {
        NumberAnimation {
            easing.type: Easing.InQuad
            duration: 400
        }
    }

    InverseMouseArea {
        anchors.fill: parent
        enabled: count > 0

        onPressed: {
            folderLoader.model = 0
            reopenTimer.start()
        }
    }
}
