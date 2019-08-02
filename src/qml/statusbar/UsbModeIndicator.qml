import QtQuick 2.6

StatusbarItem {
    id: wifiStatus
    iconSize: statusbar.height

    visible: usbModeSettings.currentMode == "developer_mode"

    source: "image://theme/bug"
}
