/****************************************************************************************
**
** Copyright (C) 2021-2025 Chupligin Sergey <neochapay@gmail.com>
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

import QtQuick
import Nemo
import Nemo.Controls

import Amber.Mpris

import org.nemomobile.lipstick
import org.nemomobile.devicelock

import Nemo.Configuration

import "notifications"
import "lockscreen"

Item {
    id: lockScreen
    anchors.fill: parent

    Image{
        id: backgroundImage
        source: lockScreenWallpaper.value
        fillMode: Image.PreserveAspectCrop
        width: lockScreen.width
        height: lockScreen.height
        x: 0
        y: 0
        z: -1
    }

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
        defaultValue: "/usr/share/glacier-home/qml/images/graphics-wallpaper-home.jpg"
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
    property real openingState: backgroundImage.y / -height
    visible: openingState < 1
    onHeightChanged: {
        if (mouseArea.fingerDown)
            return // we'll fix this up on touch release via the animations

        if (snapOpenAnimation.running) {
            snapOpenAnimation.to = -height
        } else if (!snapClosedAnimation.running && !LipstickSettings.lockscreenVisible) {
            y = -height
        }
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
        target: backgroundImage
        property: "y"
        to: 0
        easing.type: Easing.OutBounce
        duration: 400
    }

    PropertyAnimation {
        id: snapOpenAnimation
        target: backgroundImage
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
                if (backgroundImage.y - delta > 0) {
                    return
                }
                backgroundImage.y = -delta
            }
        }

        onReleased: {
            if(!locked) {
                displayOffTimer.restart()
                if(backgroundImage.y < -(lockScreen.width/3)) {
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
            target: backgroundImage
            property: "y"
            to: -height
            duration: 250
            easing.type: Easing.OutQuint
        }

        onStopped: {
            LipstickSettings.lockscreenVisible = false
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
            if (LipstickSettings.lockscreenVisible && displayOn) {
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
            if(displayOn && LipstickSettings.lockscreenVisible && !Lipstick.compositor.gestureOnGoing && !codePad.visible) {
                LipstickSettings.lockscreenVisible = true
                Lipstick.compositor.setDisplayOff()
            }
        }
    }

    Rectangle{
        id: clockBackgroundGradient
        width: parent.width
        height: lockscreenClock.height + Theme.itemSpacingHuge

        gradient: Gradient {
            GradientStop { position: 0.0; color: '#b0000000' }
            GradientStop { position: 1.0; color: '#00000000' }
        }

        Behavior on height{
            NumberAnimation {
                duration: 200
            }
        }

        Connections {
            target: codePad
            function onVisibleChanged() {
                if (codePad.visible) {
                    clockBackgroundGradient.height = lockScreen.height
                } else {
                    clockBackgroundGradient.height = lockscreenClock.height + Theme.itemSpacingHuge
                }
            }
        }
    }

    LockscreenClock {
        id: lockscreenClock
        anchors {
            top: backgroundImage.top
            horizontalCenter: parent.horizontalCenter
        }
        opacity: 1+backgroundImage.y/(lockScreen.width/15)
        scale: 1-backgroundImage.y/(lockScreen.width/4)
    }

    OperatorLine {
        id: operatorLine

        anchors{
            top: lockscreenClock.bottom
            bottomMargin: -Theme.itemSpacingHuge
            horizontalCenter: parent.horizontalCenter
        }
    }

    Item{
        id: mediaControlsItem
        visible: !codePad.visible
        width: parent.width
        height: visible ? Theme.itemHeightHuge*2 : 0

        MprisController {
            id: mprisController
        }

        anchors{
            top: operatorLine.bottom
            bottomMargin: -Theme.itemSpacingHuge
            horizontalCenter: parent.horizontalCenter
        }

        Loader{
            id: mediaControlsLoader
            active: mprisController.availableServices.length > 0
            Component.onCompleted: setSource("lockscreen/MediaControls.qml", { "mprisController": mprisController, "parent": mediaControlsItem})
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

        authenticationInput: DeviceLockAuthenticationInput {
            readonly property bool unlocking: registered && DeviceLock.state >= DeviceLock.Locked && DeviceLock.state < DeviceLock.Undefined

            registered: LipstickSettings.lockscreenVisible === true
            active: LipstickSettings.lockscreenVisible === true

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
            bottom: lockScreen.bottom
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
}
