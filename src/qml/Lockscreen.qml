/****************************************************************************************
**
** Copyright (C) 2021 Chupligin Sergey <neochapay@gmail.com>
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
import org.nemomobile.devicelock 1.0

import Nemo.Configuration 1.0

import "notifications"
import "lockscreen"

import "scripts/desktop.js" as Desktop

Image {
    id: lockScreen
    source: lockScreenWallpaper.value
    fillMode: Image.PreserveAspectCrop

    property bool displayOn
    clip: true

    ConfigurationValue {
        id: differentWallpaper
        key: "/home/glacier/differentWallpaper"
        defaultValue: true
    }

    ConfigurationValue{
        id: lockScreenWallpaper
        key: (differentWallpaper.value == true) ? "/home/glacier/lockScreen/wallpaperImage" : "/home/glacier/homeScreen/wallpaperImage"
        defaultValue: "/usr/share/lipstick-glacier-home-qt5/qml/images/graphics-wallpaper-home.jpg"
    }

    ConfigurationValue{
        id: showNotifiBody
        key: "/home/glacier/lockScreen/showNotifiBody"
        defaultValue: false
    }

    /**
     * openingState should be a value between 0 and 1, where 0 means
     * the lockscreen is "down" (obscures the view) and 1 means the
     * lockscreen is "up" (not visible).
     **/
    property real openingState: y / -height
    visible: openingState < 1
    onHeightChanged: {
        if (mouseArea.fingerDown)
            return // we'll fix this up on touch release via the animations

        if (snapOpenAnimation.running)
            snapOpenAnimation.to = -height
        else if (!snapClosedAnimation.running && !LipstickSettings.lockscreenVisible)
            y = -height
    }

    onDisplayOnChanged: {
        if(lockScreen.displayOn) {
            angileAnimation.run()
        }
    }

    function snapPosition() {
        if (LipstickSettings.lockscreenVisible) {
            snapOpenAnimation.stop()
            snapClosedAnimation.start()
        } else {
            snapClosedAnimation.stop()
            snapOpenAnimation.start()
        }
    }

    function cancelSnap() {
        snapClosedAnimation.stop()
        snapOpenAnimation.stop()
    }

    Connections {
        target: LipstickSettings
        function onLockscreenVisibleChanged(visible) { snapPosition() }
    }

    SequentialAnimation {
        id: snapCodePadAnimation

        property alias valueTo: codePadAnimation.to

        NumberAnimation {
            id: codePadAnimation
            target: codePad
            property: "x"
            duration: 200
            easing.type: Easing.OutQuint
        }
    }


    PropertyAnimation {
        id: snapClosedAnimation
        target: lockScreen
        property: "y"
        to: 0
        easing.type: Easing.OutBounce
        duration: 400
    }

    PropertyAnimation {
        id: snapOpenAnimation
        target: lockScreen
        property: "y"
        to: -height
        easing.type: Easing.OutExpo
        duration: 400
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        property int pressY: 0
        property bool fingerDown

        property bool locked: DeviceLock.state >= DeviceLock.Locked && DeviceLock.automaticLocking >=0

        onClicked: {
            if(locked) {
                codePad.visible = true
                codePad.width = 400
            }
        }

        onPressed: {
            if(!locked) {
                fingerDown = true
                cancelSnap()
                pressY = mouseY
            }
        }

        onPositionChanged: {
            if(!locked) {
                var delta = pressY - mouseY
                if (parent.y - delta > 0)
                    return
                parent.y = parent.y - delta
            }
        }

        onReleased: {
            if(!locked) {
                displayOffTimer.restart()
                if(parent.height-parent.y > Theme.itemHeightHuge*2) {
                    unlockAnimation.start()
                } else {
                    lockScreen.snapPosition()
                }
            }
        }

        function startCodePadAnimation(value) {
            snapCodePadAnimation.valueTo = value
            snapCodePadAnimation.start()
        }
    }

    SequentialAnimation {
        id: unlockAnimation
        property alias valueTo: unlockNumAnimation.to
        property alias setProperty: unlockNumAnimation.property


        NumberAnimation {
            id: unlockNumAnimation
            target: lockScreen
            property: "y"
            to: -height
            duration: 250
            easing.type: Easing.OutQuint
        }
        onStopped: {
            setLockScreen(false)
        }
    }
    Connections {
        target:Lipstick.compositor
        function onDisplayOff() {
            displayOn = false
            displayOffTimer.stop()
            codePad.visible = false
        }

        function onDisplayOn() {
            displayOn = true
            displayOffTimer.stop()
        }
    }
    Connections {
        target: LipstickSettings
        function onLockscreenVisibleChanged(visible) {
            if (lockscreenVisible() && displayOn) {
                displayOffTimer.restart()
            }
        }
    }
    Timer {
        id:displayOffTimer
        interval: 7000
        onRunningChanged: {
            if(running && !displayOn) {
                stop()
            }
        }
        onTriggered: {
            if(displayOn && lockscreenVisible() && !Lipstick.compositor.gestureOnGoing && !codePad.visible) {
                setLockScreen(true)
                Lipstick.compositor.setDisplayOff()
            }
        }
    }

    LockscreenClock {
        id: lockscreenClock
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    OperatorLine {
        id: operatorLine

        anchors{
            top: lockscreenClock.bottom
            bottomMargin: -Theme.itemSpacingHuge
            horizontalCenter: parent.horizontalCenter
        }
    }

    MediaControls{
        id: mediaControls
        visible: !codePad.visible

        anchors{
            top: operatorLine.bottom
            bottomMargin: -Theme.itemSpacingHuge
            horizontalCenter: parent.horizontalCenter
        }
    }

    DeviceLockUI {
        id: codePad
        visible: false
        anchors {
            top: lockscreenClock.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: Theme.itemSpacingHuge
        }

        width: lockScreen.width
        height: visible ? lockScreen.height / 2 : 0

        authenticationInput: DeviceLockAuthenticationInput {
            readonly property bool unlocking: registered && DeviceLock.state >= DeviceLock.Locked && DeviceLock.state < DeviceLock.Undefined

            registered: lockscreenVisible()
            active: lockscreenVisible()

            onUnlockingChanged: {
                if (unlocking) {
                    DeviceLock.unlock()
                } else {
                    DeviceLock.cancel()
                }
            }

            onAuthenticationEnded: {
                if(confirmed) {
                    unlockAnimationHelper(mouseArea.gesture)
                }
            }

            function unlockAnimationHelper(gesture) {
                if(gesture == "left") {
                    unlockAnimation.setProperty = "x"
                    unlockAnimation.valueTo = -width
                    unlockAnimation.start()
                }
                if(gesture == "right") {
                    unlockAnimation.setProperty = "x"
                    unlockAnimation.valueTo = width
                    unlockAnimation.start()
                }
            }
        }

        onAuthOK: unlockAnimation.start()
    }

    Column {
        id: lockscreenNotificationColumn
        width: parent.width
        visible: !codePad.visible

        anchors {
            bottom: angileAnimation.top
            bottomMargin: Theme.itemSpacingHuge
            horizontalCenter: parent.horizontalCenter
            left: parent.left
            leftMargin: Theme.itemSpacingSmall
        }

        move: Transition {
            NumberAnimation { properties: "y"; duration: 400 }
        }

        spacing: Theme.itemSpacingLarge

        Repeater {
            model: NotificationListModel{
                id: notifmodel
            }

            delegate: NotificationItem{
                width: parent.width
                Rectangle{
                    anchors.fill: parent
                    color: Theme.backgroundColor
                    opacity: 0.5
                    radius: Theme.itemSpacingSmall
                    z: -1
                }
            }
        }
    }

    AngleAnimation {
        id: angileAnimation
        width: Theme.itemHeightLarge
        height: Theme.itemHeightLarge/2*3

        anchors{
            bottom: parent.bottom
            bottomMargin: Theme.itemSpacingSmall
            horizontalCenter: parent.horizontalCenter
        }
    }
}
