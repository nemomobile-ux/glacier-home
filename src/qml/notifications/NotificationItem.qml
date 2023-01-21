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

import Nemo.DBus 2.0

import "NofiticationImage.js" as NotificationImage

Item {
    id: notifyArea

    height: littleArea.height + ( (modelData.progress === 0) ? 0 : Theme.itemHeightExtraSmall )
    width: parent.width

    clip: true

    property alias appName: appName
    property alias appIcon: appIcon
    property alias appBody: appBody
    property alias appSummary: appSummary

    property alias appTimestamp: appTimestamp
    property alias pressBg: pressBg
    property alias iconSize: appIcon.height
    property string timeAgo
    property int swipeTreshold: notifyArea.width/3


    DBusInterface {
        id: dbus

        function invokeRemoteAction(action) {
            dbus.service = action.service
            dbus.path = action.path
            dbus.iface = action.iface
            dbus.call(action.method, action.arguments || [])
        }
    }

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

            if (modelData.remoteActions.length > 0) {
                var action = modelData.remoteActions[0];
                dbus.invokeRemoteAction(action)
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
        } else if (months >= 1) {
            timeAgo = qsTr("%n months(s) ago", "notifications", months)
        } else if (days >= 1) {
            timeAgo = qsTr("%n day(s) ago", "notifications", days)
        } else if (hours >= 1) {
            timeAgo = qsTr("%n hours(s) ago", "notifications", hours)
        } else if (minutes >= 1) {
            timeAgo = qsTr("%n minutes(s) ago", "notifications", minutes)
        } else {
            timeAgo = qsTr("Just now")
        }
    }

    NumberAnimation {
        id: slideAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: notifyArea.width
        easing.type: Easing.InOutQuad
        onStopped: modelData.actionInvoked("default")
    }

    NumberAnimation {
        id: slideReverseAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: -notifyArea.width
        easing.type: Easing.InOutQuad
        onStopped: modelData.removeRequested()
    }

    NumberAnimation {
        id: slideBackAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: 0
        easing.type: Easing.InOutQuad
    }

    Rectangle {
        id: pressBg
        anchors.fill: parent
        color: Theme.fillColor
        radius: Theme.itemSpacingMedium
        opacity: notifyMouseArea.pressed ? 0.8 : 0.5
    }

    Item {
        id: littleArea
        width: parent.width
        height: Math.max(appIcon.height, appSummary.paintedHeight + appBody.paintedHeight +  Theme.itemSpacingExtraSmall) + 2 * Theme.itemSpacingSmall


        Image {
            id: appIcon

            fillMode: Image.PreserveAspectFit
            width: height
            height: Theme.itemHeightLarge
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: Theme.itemSpacingMedium

            source: NotificationImage.notificationImage(modelData.icon, modelData.appIcon)

            onStatusChanged: {
                if (appIcon.status == Image.Error) {
                    appIcon.source = NotificationImage.defaultIcon
                }
            }
        }


        Label {
            id: appTimestamp
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeTiny
            text: if(timeAgo) timeAgo
            horizontalAlignment: Text.AlignRight

            anchors {
                top: parent.top
                topMargin: Theme.itemSpacingExtraSmall
                right:parent.right
                rightMargin: Theme.itemSpacingSmall
            }
            Component.onCompleted: refreshTimestamp()
        }

        Label {
            id: appSummary
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeMedium
            text: modelData.summary || modelData.previewSummary
            maximumLineCount: 1
            elide: Text.ElideRight
            width: parent.width - (appTimestamp.paintedWidth + appIcon.width + 4*Theme.itemSpacingSmall)

            anchors {
                top: parent.top
                topMargin: Theme.itemSpacingSmall
                left: appIcon.right
                leftMargin: Theme.itemSpacingSmall
            }
        }

        Label {
            id: appBody
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeSmall
            text: modelData.body || modelData.previewBody
            maximumLineCount: 1
            elide: Text.ElideRight
            width: parent.width - ( appName.paintedWidth + appIcon.width + 4*Theme.itemSpacingSmall )

            anchors {
                top: appSummary.bottom
                topMargin: Theme.itemSpacingExtraSmall/2
                left: appIcon.right
                leftMargin: Theme.itemSpacingSmall
                bottom: parent.bottom
                bottomMargin: Theme.itemSpacingSmall
            }
        }


        Label {
            id: appName
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeTiny
            text: modelData.appName
            horizontalAlignment: Text.AlignRight

            anchors {
                bottom: parent.bottom
                bottomMargin: Theme.itemSpacingSmall
                right: parent.right
                rightMargin: Theme.itemSpacingSmall
            }
        }



    }

    ProgressBar {
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

        visible: modelData.progress !== 0
        indeterminate: modelData.progress === -1
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

        /*
        console.log(
            "appName: " +modelData.appName + "\n" +
            "explicitAppName : " + modelData.explicitAppName + "\n" +
            "disambiguatedAppName: " + modelData.disambiguatedAppName + "\n" +
            "id: " + modelData.id + "\n" +
            "appIcon: " + modelData.appIcon + "\n" +
            "appIconOrigin: " + modelData.appIconOrigin + "\n" +
            "summary: " +modelData.summary + "\n" +
            "body: " + modelData.body  + "\n" +
            "actions: " +modelData.actions + "\n" +
            "hints: " +modelData.hints  + "\n" +
            "expireTimeout: " + modelData.expireTimeout  + "\n" +
            "timestamp: " + modelData.timestamp  + "\n" +
            "previewSummary: " + modelData.previewSummary  + "\n" +
            "previewBody: " + modelData.previewBody  + "\n" +
            "subText: " + modelData.subText  + "\n" +
            "urgency: " + modelData.urgency + "\n" +
            "itemCount: " + modelData.itemCount  + "\n" +
            "priority: " +modelData.priority  + "\n" +
            "category: " + modelData.category  + "\n" +
            "userRemovable: " + modelData.userRemovable  + "\n" +
            "remoteActions: " + modelData.remoteActions  + "\n" +
            "owner: " + modelData.owner  + "\n" +
            "progress: " + modelData.progress  + "\n" +
            "hasProgress: " + modelData.hasProgress  + "\n" +
            "isTransient: " + modelData.isTransient  + "\n" +
            "color: " + modelData.color + "\n"
        )
        */


    }



}
