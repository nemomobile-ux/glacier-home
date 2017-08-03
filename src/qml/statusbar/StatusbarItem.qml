import QtQuick 2.0
import QtQuick.Layouts 1.0

Item {
    property alias source: icon.source
    property alias pressed: mouse.pressed
    property string panel_source
    property Component panel
    property double iconSize
    Layout.fillWidth: true
    Layout.fillHeight: true
    function clicked() {
        if (panel_source !== "" && !panel) {
            panel_loader.source = panel_source
            panel_loader.visible = !panel_loader.visible
        }
        if (panel && panel_source === "") {
            panel_loader.sourceComponent = panel
            panel_loader.visible = !panel_loader.visible
        }
    }

    Rectangle{
        anchors.fill:parent
        opacity: 0.8
        color: Theme.fillDarkColor
        visible: panel_loader.visible && (panel_loader.sourceComponent == panel)
    }

    Image {
        fillMode: Image.PreserveAspectFit
        height: iconSize
        id: icon
        anchors.centerIn: parent
    }
    MouseArea {
        id:mouse
        anchors.fill: parent
        enabled: !lockscreenVisible()
        onClicked: parent.clicked()
    }

}
