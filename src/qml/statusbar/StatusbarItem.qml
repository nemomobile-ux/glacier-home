import QtQuick 2.6
import QtQuick.Layouts 1.0

Item {
    id: statusbarItem

    property alias source: icon.source
    property string panel_source
    property Component panel
    property double iconSize
    property double iconSizeHeight

    property bool transparent: false

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

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (panel_source !== "" && !panel) {
                panel_loader.source = panel_source
                panel_loader.visible = !panel_loader.visible
            }
            if (panel && panel_source === "") {
                panel_loader.sourceComponent = panel
                panel_loader.visible = !panel_loader.visible
            }
        }
    }
}
