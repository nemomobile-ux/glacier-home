
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

import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

// App Launcher page
// the place for browsing installed applications and launching them

GridView {
    id: gridview
    cellWidth: Math.min(parent.width,parent.height)/4
    cellHeight: cellWidth + 30
    width: parent.width
    cacheBuffer: gridview.contentHeight
    property Item reorderItem
    property bool onUninstall
    property alias deleter: deleter
    property var switcher: null

    // just for margin purposes
    header: Item {
        height: Math.min(parent.width,parent.height)/10
    }
    footer: Item {
        height: Math.min(parent.width,parent.height)/10
    }

    Item {
        id: deleter
        anchors.top: parent.top
        property alias remove: remove
        property alias uninstall: uninstall
        Rectangle {
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
        Rectangle {
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

    model: LauncherFolderModel { id: launcherModel }

    delegate: LauncherItemDelegate {
        id: launcherItem
        width: gridview.cellWidth
        height: gridview.cellHeight
        iconCaption: model.object.title
        isFolder: model.object.type == LauncherModel.Folder
        folderAppsCount: isFolder && model.object ? model.object.itemCount : 0
        source: model.object.iconId == "" || isFolder ? "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png" : (model.object.iconId.indexOf("/") == 0 ? "file://" : "image://theme/") + model.object.iconId
    }
}
