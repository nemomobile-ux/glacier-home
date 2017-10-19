import QtQuick 2.6

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import org.nemomobile.configuration 1.0
import "notifications"

import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

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
        onLockscreenVisibleChanged: snapPosition()
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
        property int pressY: 0
        property bool fingerDown
        property bool ignoreEvents
        anchors.fill: parent
        property bool gestureStarted: false
        property string gesture: ""
        property int startX
        property int threshold: Theme.itemHeightHuge * 2
        property int swipeDistance
        property string action: ""
        anchors.fill: parent

        onPressed: {
            startX = mouseX;
            fingerDown = true
            cancelSnap()
            pressY = mouseY
        }

        onPositionChanged: {
            var delta = pressY - mouseY
            pressY = mouseY + delta
            if (parent.y - delta > 0)
                return
            parent.y = parent.y - delta
        }

        function snapBack() {
            fingerDown = false
            if (!LipstickSettings.lockscreenVisible || Math.abs(parent.y) > parent.height / 3) {
                LipstickSettings.lockscreenVisible = false
            } else if (LipstickSettings.lockscreenVisible) {
                LipstickSettings.lockscreenVisible = true
            }

            lockScreen.snapPosition()
        }
        onMouseXChanged: {
            // Checks which swipe
            if(mouseX > (startX+threshold)) {
                gesture = "right"
                gestureStarted = true;
            }
            else if(mouseX < (startX+threshold)) {
                gesture = "left"
                gestureStarted = true;
            }
            // Makes codepad follow the swipe
            if(codePad.inView) {
                if(gesture == "right") {
                    swipeDistance = mouseX - startX
                    codePad.x = swipeDistance
                }
                if(gesture == "left") {
                    swipeDistance = startX - mouseX
                    codePad.x = -swipeDistance
                }
            }else {
                if(gesture == "right") {
                    swipeDistance = mouseX - startX
                    codePad.x = swipeDistance - parent.width
                }
                else if(gesture == "left") {
                    swipeDistance = startX - mouseX
                    codePad.x = parent.width - swipeDistance
                }

            }

        }

        // Animation to sna codepad into view or out of view
        onReleased: {
            if(codePad.inView) {
                if(gesture == "right") {
                    if(swipeDistance > threshold) {
                        startCodePadAnimation(parent.width)
                        codePad.inView = false
                    }else {
                        startCodePadAnimation(0)
                        codePad.inView = true
                    }
                }else if(gesture == "left") {
                    if(swipeDistance > threshold) {
                        startCodePadAnimation(-parent.width)
                        codePad.inView = false
                    }else {
                        startCodePadAnimation(0)
                        codePad.inView = true
                    }
                }
            }else {
                if(swipeDistance > threshold) {
                    startCodePadAnimation(0)
                    codePad.inView = true
                }else {
                    if(gesture == "right") {
                        startCodePadAnimation(-parent.width)
                        codePad.inView = false
                    }
                    else {
                        startCodePadAnimation(parent.width)
                        codePad.inView = false
                    }
                }
            }
            snapBack()
        }
        onCanceled: snapBack()
    }

    LockscreenClock {
        id: lockscreenClock
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    DeviceLockUI {
        id: codePad
        visible: DeviceLock.state == DeviceLock.Locked && codepadVisible
        anchors {
            top: lockscreenClock.bottom
            topMargin: Theme.itemSpacingHuge
        }
        property bool inView: false
        property bool gestureStarted: mouseArea.gestureStarted
        x: width * 2
        width: lockScreen.width
        height: visible ? lockScreen.height / 2 : 0
        onCodeEntered: {
            console.log("Security code entered: "+authenticationInput.minimumCodeLength)
        }

        authenticationInput: DeviceLockAuthenticationInput {

            readonly property bool unlocking: registered
                        && DeviceLock.state >= DeviceLock.Locked && DeviceLock.state < DeviceLock.Undefined

            registered: true
            active: true
            onStatusChanged: {
                console.log("Status changed")
            }
            onUnlockingChanged: {
                 console.log("Unlock")
                if (unlocking) {
                    DeviceLock.unlock()
                } else {
                    DeviceLock.cancel()
                }
            }
            onAuthenticationUnavailable: {
                console.log("Authentication unavailable: "+error)
            }

            onFeedback: {
                console.log("Feedback: "+feedback)
            }

            onAuthenticationStarted: {
                console.log("Authentication started")
            }
            onAuthenticationEnded: {
                console.log("Ended "+confirmed)
            }
        }
        onGestureStartedChanged: {
            if(gestureStarted) {
                mouseArea.z = 2
            }else {
                mouseArea.z = 0
            }
        }
    }

    Column {
        id: lockscreenNotificationColumn
        
        width:parent.width

        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.itemSpacingHuge
            horizontalCenter: parent.horizontalCenter
        }

        spacing: Theme.itemSpacingHuge

        Repeater {
            model: NotificationListModel{
                id: notifmodel
            }

            delegate: NotificationItem{
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
