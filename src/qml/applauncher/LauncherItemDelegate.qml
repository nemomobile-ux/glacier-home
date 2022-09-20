
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
// Copyright (c) 2020-2021, Chupligin Sergey <neochapay@gmail.com>
// Copyright (c) 2017, Eetu Kahelin
// Copyright (c) 2013, Jolla Ltd <robin.burchell@jollamobile.com>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>


import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.lipstick 0.1

Item {
    id: launcherItemDelegate
    property alias source: iconImage.source
    property alias iconCaption: iconText
    property bool reordering: launcherItem.reordering
    property bool isFolder
    property alias onUninstall: launcherItem.onUninstall
    property alias parentItem: launcherItem.parentItem
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

    onOnUninstallChanged: {
        if(onUninstall) {
            doUninstallAnumation.start()
        } else {
            doUninstallAnumation.stop()
        }
    }

    Rectangle{
        id: uninuninstallerItem
        width: launcherItem.width*2
        height: launcherItem.height/2
        visible: onUninstall
        color: Theme.backgroundAccentColor

        radius: 10

        anchors{
            horizontalCenter: launcherItemDelegate.horizontalCenter
            bottom: launcherItemDelegate.top
        }

        onVisibleChanged: {
            console.log(x + " " + y)
        }
    }

    SequentialAnimation {
        id: doUninstallAnumation
        loops: Animation.Infinite
        PropertyAnimation {
            target: launcherItem
            properties: "y";
            easing.type: Easing.InOutElastic;
            easing.amplitude: 2.0;
            easing.period: 1.5
            to: launcherItemDelegate.y+launcherItem.width*0.2
        }
        PropertyAnimation {
            target: launcherItem
            properties: "y";
            easing.type: Easing.InOutElastic;
            easing.amplitude: 2.0;
            easing.period: 1.5
            to: launcherItemDelegate.y
        }
    }


    // Application icon for the launcher
    LauncherItemWrapper {
        id: launcherItem
        width: launcherItemDelegate.width
        height: iconWrapper.height+Theme.itemSpacingSmall+Theme.fontSizeTiny*3
        isFolder: launcherItemDelegate.isFolder
        clip: true

        Item {
            id: iconWrapper
            height: width
            width: parent.width-Theme.itemSpacingSmall*2
            anchors{
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                left: parent.left
                leftMargin: Theme.itemSpacingSmall
            }

            Image {
                id: iconImage
                anchors.centerIn: parent
                height: launcherItem.reordering ? parent.height : parent.height*0.8
                width: launcherItem.reordering ? parent.width : parent.width*0.8
                asynchronous: true
                onStatusChanged: {
                    if (iconImage.status == Image.Error) {
                        iconImage.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png"
                    }
                }
            }

            Spinner {
                id: startSpinner
                anchors.centerIn:  iconImage
                width: parent.width - Theme.itemSpacingHuge
                height: width
                enabled: (modelData.object.type === LauncherModel.Application) ? modelData.object.isLaunching ? switcher.switchModel.getWindowIdForTitle(modelData.object.title) == 0 : false : false

                Connections {
                    target: Lipstick.compositor
                    function onWindowAdded(window) {
                        if(window.title == modelData.object.title){
                            startSpinner.stop()
                        }
                    }
                }

                onEnabledChanged: {
                    if(enabled) {
                        idleTimer.start()
                    } else {
                        idleTimer.stop();
                    }
                }

                Timer {
                    id: idleTimer
                    interval: 500
                    onTriggered: {
                        startSpinner.stop()
                    }
                }
            }

        }
        // Caption for the icon
        Text {
            id: iconText
            // elide only works if an explicit width is set
            width: iconWrapper.width
            height: Theme.fontSizeTiny*3
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.textColor
            visible: !launcherItem.reordering

            wrapMode: Text.WordWrap

            anchors {
                top: iconWrapper.bottom
                topMargin: Theme.itemSpacingSmall
                horizontalCenter: iconWrapper.horizontalCenter
            }
        }
    }
}
