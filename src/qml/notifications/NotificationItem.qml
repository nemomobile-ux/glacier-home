/****************************************************************************************
**
** Copyright (C) 2021-2022 Chupligin Sergey <neochapay@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1

Item {
    id: notifyArea

    height: modelData.progress == 0 ? Theme.itemHeightExtraLarge : Theme.itemHeightExtraLarge + Theme.itemHeightExtraSmall
    width: parent.width

    clip: true

    property alias appIcon: appIcon
    property alias appBody: appBody
    property alias appName: appName
    property alias appSummary: appSummary

    property alias appTimestamp: appTimestamp
    property alias pressBg: pressBg
    property int iconSize: height-Theme.itemSpacingMedium
    property string timeAgo
    property int swipeTreshold: notifyArea.width/3

    MouseArea{
        id: notifyMouseArea
        anchors.fill: notifyArea

        drag.target: notifyArea
        drag.axis: Drag.XAxis
        drag.minimumX: -notifyArea.width
        drag.maximumX: notifyArea.width
        drag.onActiveChanged: {
            if(!drag.active ) {
                if((notifyArea.x > swipeTreshold) && !modelData.hasProgress) {
                    slideAnimation.start()
                }else if (notifyArea.x < -swipeTreshold){
                    slideReverseAnimation.start()
                } else {
                    slideBackAnimation.start()
                }
            }
        }

        onClicked: {
            if (LipstickSettings.lockscreenVisible === true) {
                return
            }

            if (modelData.userRemovable && !modelData.hasProgress) {
                slideAnimation.start()
            } else {
                modelData.actionInvoked("default")
            }
        }
    }

    function refreshTimestamp() {
        var seconds = Math.floor((new Date() - modelData.timestamp) / 1000)
        var years = Math.floor(seconds / (365*24*60*60))
        var months = Math.floor(seconds / (30*24*60*60))
        var days = Math.floor(seconds / (24*60*60))
        var hours = Math.floor(seconds / (60*60))
        var minutes = Math.floor(seconds / 60)

        if (years >= 1) {
            timeAgo = qsTr("%n year(s) ago", "notifications", years)
        }else if (months >= 1) {
            timeAgo = qsTr("%n months(s) ago", "notifications", months)
        }else if (days >= 1) {
            timeAgo = qsTr("%n day(s) ago", "notifications", days)
        }else if (hours >= 1) {
            timeAgo = qsTr("%n hours(s) ago", "notifications", hours)
        } else if (minutes >= 1) {
            timeAgo = qsTr("%n minutes(s) ago", "notifications", minutes)
        } else {
            timeAgo = qsTr("Just now")
        }
    }

    NumberAnimation {
        id:slideAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: notifyArea.width
        easing.type: Easing.InOutQuad
        onStopped: modelData.actionInvoked("default")
    }

    NumberAnimation {
        id:slideReverseAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: -notifyArea.width
        easing.type: Easing.InOutQuad
        onStopped: modelData.removeRequested()
    }

    NumberAnimation {
        id:slideBackAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: 0
        easing.type: Easing.InOutQuad
    }

    Rectangle {
        id:pressBg
        anchors.fill: parent
        color: Theme.fillColor
        radius: Theme.itemSpacingMedium
        opacity: notifyMouseArea.pressed ? 0.8 : 0.5
    }

    Item {
        id: littleArea
        width: parent.width
        height: Theme.itemHeightExtraLarge

        anchors{
            top: parent.top
            left: parent.left
        }

        Image {
            id: appIcon
            property string defaultIcon: "/usr/share/lipstick-glacier-home-qt5/qml/images/glacier.svg"

            height: parent.height-Theme.itemSpacingMedium
            width: height
            anchors{
                left: parent.left
                leftMargin: Theme.itemSpacingMedium
                verticalCenter:littleArea.verticalCenter
            }

            source: {
                if (modelData.icon) {
                    if(modelData.icon.indexOf("/") == 0)
                        return "file://" + modelData.icon
                    else
                        return "image://theme/" + modelData.icon
                } else if (modelData.appIcon) {
                    if(modelData.appIcon.indexOf("/") == 0)
                        return "file://" + modelData.appIcon
                    else
                        return "image://theme/" + modelData.appIcon
                } else return defaultIcon
            }
            onStatusChanged: {
                if (appIcon.status == Image.Error) {
                    appIcon.source = defaultIcon
                }
            }
        }

        Label {
            id: appName
            text: modelData.appName
            width: Math.min(implicitWidth,  parent.width-appTimestamp.width-Theme.itemSpacingSmall)
            color: Theme.textColor
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            anchors {
                left: appIcon.right
                leftMargin: Theme.itemSpacingSmall
                top: parent.top
                topMargin: Theme.itemSpacingSmall
            }
        }

        Label {
            id:appTimestamp
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeTiny
            text: if(timeAgo) timeAgo
            horizontalAlignment: Text.AlignRight
            anchors {
                top: parent.top
                topMargin: Theme.itemSpacingSmall
                right:parent.right
                rightMargin: Theme.itemSpacingSmall

            }
            Component.onCompleted: refreshTimestamp()
        }

        Label {
            id: appSummary
            text: modelData.summary || modelData.previewSummary
            width: parent.width-Theme.itemSpacingHuge
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeTiny
            anchors{
                left: appIcon.right
                leftMargin: Theme.itemSpacingSmall
                top: appName.bottom
                topMargin: Theme.itemSpacingExtraSmall
            }
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        Label {
            id: appBody
            width: parent.width-Theme.itemSpacingHuge
            text: modelData.body || modelData.previewBody
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeTiny
            anchors{
                left: appIcon.right
                leftMargin: Theme.itemSpacingSmall
                top: appSummary.bottom
                topMargin: Theme.itemSpacingSmall
            }
            maximumLineCount: 1
            elide: Text.ElideRight
        }
    }

    ProgressBar{
        id: progressBar
        width: notifyArea.width  - Theme.itemSpacingSmall *2
        height: Theme.itemHeightExtraSmall / 3
        value: modelData.progress

        anchors{
            top: littleArea.bottom
            topMargin: Theme.itemHeightExtraSmall / 3
            left: littleArea.left
            leftMargin: Theme.itemSpacingSmall
        }

        visible: modelData.progress != 0
        indeterminate: modelData.progress == -1
    }

    Connections {
        target: Lipstick.compositor
        function onDisplayOn() {
            updateTimeTimer.start()
        }

        function onDisplayOff() {
            updateTimeTimer.stop();
        }
    }

    Timer{
        id: updateTimeTimer
        repeat: true
        interval: 1000
        onTriggered: {
            refreshTimestamp()
        }
    }

    Component.onCompleted: {
        refreshTimestamp()
    }
}
