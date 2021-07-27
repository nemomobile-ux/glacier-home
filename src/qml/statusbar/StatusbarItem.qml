import QtQuick 2.6

Item {
    id: statusbarItem

    property alias source: icon.source
    property double iconSize
    property double iconSizeHeight

    property bool transparent: false

    width: iconSize
    height: iconSizeHeight ? iconSizeHeight : iconSize

    Image {
        width: parent.width
        height: parent.height
        id: icon
        anchors.centerIn: parent
        opacity: statusbarItem.transparent ? 0.5 : 1
    }
}
