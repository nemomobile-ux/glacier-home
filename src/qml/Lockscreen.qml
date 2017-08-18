import QtQuick 2.6

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import org.nemomobile.configuration 1.0
import "notifications"


Image {
    id: lockScreen
    source: lockScreenWallpaper.value
    fillMode: Image.PreserveAspectCrop

    property bool displayOn

    ConfigurationValue{
        id: lockScreenWallpaper
        key: "/home/glacier/lockScreen/wallpaperImage"
        defaultValue: "/usr/share/lipstick-glacier-home-qt5/qml/images/graphics-wallpaper-home.jpg"
    }
    LockscreenClock {
        id: clock
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    MouseArea {
        id:mouseArea
        anchors.fill: parent
    }
    Connections {
        target:Lipstick.compositor
        onDisplayOff: {
            displayOn = false
            displayOffTimer.stop()
        }
        onDisplayOn:{
            displayOn = true
            displayOffTimer.stop()
        }
    }

    Connections {
        target: LipstickSettings
        onLockscreenVisibleChanged: {
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
            if(displayOn && lockscreenVisible() && !Lipstick.compositor.gestureOnGoing && !codepad.visible) {
                setLockScreen(true)
                Lipstick.compositor.setDisplayOff()
            }
        }
    }

    ListView {
        id: notificationColumn
        opacity: codePad.visible ? 1 - codePad.opacity : 1
        anchors{
            top: clock.bottom
            topMargin: Theme.itemSpacingHuge
            bottom:parent.bottom
            bottomMargin: Theme.itemSpacingHuge
            left:parent.left
            leftMargin: Theme.itemSpacingLarge
            right:parent.right
            rightMargin: Theme.itemSpacingLarge
        }
        interactive:false
        spacing: 0

        model: NotificationListModel {
            id: notifmodel
        }
        delegate: NotificationItem {
            enabled:DeviceLock.state !== DeviceLock.Locked
            scale: notificationColumn.opacity
            transformOrigin: Item.Left
            iconSize: Theme.itemHeightMedium
            appName.font.pixelSize: Theme.fontSizeSmall
            appName.visible: DeviceLock.state !== DeviceLock.Locked
            appName.anchors.verticalCenter: appIcon.verticalCenter
            appName.anchors.top: null
            appBody.font.pixelSize: Theme.fontSizeTiny
            appBody.visible: false
            appSummary.visible: false
        }
    }
}
