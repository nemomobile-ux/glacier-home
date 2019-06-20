import QtQuick 2.6
import MeeGo.Connman 0.2

StatusbarItem {
    id: wifiStatus
    iconSize: statusbar.height
    visible: wifimodel.powered
    source: {
        if (wlan.connected) {
            if (networkManager.defaultRoute.strength >= 59) {
                return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_4.png"
            } else if (networkManager.defaultRoute.strength >= 55) {
                return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_3.png"
            } else if (networkManager.defaultRoute.strength >= 50) {
                return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_2.png"
            } else if (networkManager.defaultRoute.strength >= 40) {
                return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_1.png"
            } else {
                return "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_wifi_0.png"
            }
        }
        return "image://theme/icon_wifi_touch"
    }

    NetworkTechnology {
        id: wlan
    }

    TechnologyModel {
        id: wifimodel
        name: "wifi"
        onPoweredChanged: {
            if (powered)
                wifimodel.requestScan()
        }
    }

    NetworkManager {
        id: networkManager
        function updateTechnologies() {
            if (available && technologiesEnabled) {
                wlan.path = networkManager.technologyPathForType("wifi")
            }
        }
        onAvailableChanged: updateTechnologies()
        onTechnologiesEnabledChanged: updateTechnologies()
        onTechnologiesChanged: updateTechnologies()
    }
}
