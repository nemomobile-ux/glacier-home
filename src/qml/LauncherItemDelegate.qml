
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
    property alias source: iconImage.source
    property alias iconCaption: iconText
    property bool reordering: launcherItem.reordering
    property bool isFolder
    //Sailfish and other app icons are larger than nemo icons. Thats why this property could be used to scale them
    property bool notNemoIcon
    property alias parentItem: launcherItem.parentItem
    property alias folderModel:launcherItem.folderModel

    onXChanged: moveTimer.start()
    onYChanged: moveTimer.start()
    clip: true

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
        isFolder: wrapper.isFolder
        notNemoIcon: wrapper.notNemoIcon

        Item {
            id: iconWrapper
            height: parent.height - iconText.height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.round((parent.height - (height + iconText.height)) / 2)

            Image {
                id: iconImage
                anchors.centerIn: parent
                sourceSize.width: Theme.iconSizeLauncher
                sourceSize.height: Theme.iconSizeLauncher
                height: Theme.iconSizeLauncher
                width: height
                asynchronous: true
                onStatusChanged: {
                    if (iconImage.status == Image.Error) {
                        iconImage.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png"
                    }
                }
            }
            Spinner {
                id: spinnerr
                anchors.centerIn:  iconImage
                width: iconWrapper.width
                height: width
                enabled: (modelData.object.type === LauncherModel.Application) ? modelData.object.isLaunching ? switcher.switchModel.getWindowIdForTitle(modelData.object.title) == 0 : false : false

                Connections {
                    target: Lipstick.compositor
                    onWindowAdded: {
                        if(window.category=="" && window.title !== "Home"){
                            spinnerr.stop()
                        }
                    }
                }
            }

        }
        // Caption for the icon
        Text {
            id: iconText
            // elide only works if an explicit width is set
            width: iconWrapper.width
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.textColor
            //https://bugreports.qt.io/browse/QTBUG-56052
            y: -contentHeight + font.pixelSize + iconWrapper.y + iconWrapper.height
            anchors {
                left: parent.left
                right: parent.right
            }
        }
    }


}
