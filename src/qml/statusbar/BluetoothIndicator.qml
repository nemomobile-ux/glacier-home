import QtQuick 2.6
import MeeGo.Connman 0.2

StatusbarItem {
    id: bluetoothIndicator
    iconSize:       parent.height * 0.671875
    iconSizeHeight: parent.height
    source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_bluetooth.png"
    visible: bluetoothTechnology.powered

    transparent: !bluetoothTechnology.connected


    NetworkTechnology {
        id: bluetoothTechnology
        path: "/net/connman/technology/bluetooth"
    }
}
