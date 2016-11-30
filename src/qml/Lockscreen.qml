import QtQuick 2.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0

Image {
    id: lockScreen
    source: "qrc:/qml/images/graphics-wallpaper-home.jpg"

    LockscreenClock {
        id: clock
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }
    DeviceLockUI {
        id: deviceLockUI
        anchors {
            top: clock.bottom
            left: parent.left
        }

        height: parent.height-clock.height
        width: parent.width

        //visible:
        z: 201
    }

    MouseArea {
        anchors.fill: parent
    }
}
