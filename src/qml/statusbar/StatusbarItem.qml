import QtQuick 2.6
import QtQuick.Layouts 1.0

Item {
    property alias source: icon.source
    property alias pressed: mouse.pressed
    property alias _reopenTimer: reopenTimer
    property string panel_source
    property Component panel
    property double iconSize
    Layout.fillWidth: true
    Layout.fillHeight: true
    function clicked() {
        if(reopenTimer.running){
            panel_loader.visible = false
            row.currentChild = null
        } else {
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

    Rectangle{
        anchors.fill:parent
        opacity: 0.6
        color: Theme.fillDarkColor
        visible: panel_loader.visible && (panel_loader.sourceComponent == panel)
    }

    Image {
        fillMode: Image.PreserveAspectFit
        height: iconSize
        width: iconSize
        id: icon
        anchors.centerIn: parent
    }
    MouseArea {
        id:mouse
        anchors.centerIn: parent
        width: parent.width + Theme.itemSpacingSmall
        height: parent.height + Theme.itemSpacingSmall
        enabled: !lockscreenVisible()
        onClicked: parent.clicked()
    }
    Timer {
        id: reopenTimer
        interval: 300
        running: false
    }

}
