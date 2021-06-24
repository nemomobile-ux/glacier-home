import QtQuick 2.6
import QtQuick.Layouts 1.0

Item {
    id: statusbarItem

    property alias source: icon.source
    property double iconSize
    property double iconSizeHeight

    property bool transparent: false
    property bool mainReady: false

    Layout.fillWidth: true
    Layout.fillHeight: true
    width: iconSize
    height: iconSizeHeight ? iconSizeHeight : iconSize

    Image {
        width: parent.width
        height: parent.height
        id: icon
        anchors.centerIn: parent
        opacity: statusbarItem.transparent ? 0.5 : 1
    }

    onXChanged: {
        if(statusbarItem.x < 0 && statusbarItem.mainReady) {
            statusbarItem.parent = leftStatusBar
        }
    }

    Connections{
        target: desktop
        onReadyChanged: {
            if(ready) {
                mainReady = true;
            }
        }
    }
}
