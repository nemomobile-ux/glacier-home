import QtQuick 2.6

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import org.nemomobile.configuration 1.0
import "notifications"

import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import "notifications"

Image {
    id: lockScreen
    source: lockScreenWallpaper.value
    fillMode: Image.PreserveAspectCrop

    property bool displayOn

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

        onPressed: {
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

        onCanceled: snapBack()
        onReleased: snapBack()
    }

    LockscreenClock {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    Column {
        id: lockscreenNotificationColumn
        
        width:parent.width * 0.85

        anchors {
            bottom: parent.bottom
            bottomMargin: 172
            
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 32

        Repeater {
            model: NotificationListModel{
                id: notifmodel
            }

            delegate: LockscreenNotificationItem{}
        }
    }
}
