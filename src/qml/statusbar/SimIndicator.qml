import QtQuick 2.6
import QtQuick.Layouts 1.0

import MeeGo.QOfono 0.2

import org.freedesktop.contextkit 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.ofono 1.0

Item {
    id: simIndicator
    property int modemCount: 0

    width: childrenRect.width
    height: parent.height

    OfonoModemListModel{
        id: modemModel
    }

    Layout.fillWidth: true
    Layout.fillHeight: true

    Repeater{
        id: simRepeater
        model: modemModel
        delegate: StatusbarItem {
            id: cellStatus
            source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/nosim.png"
            iconSize: statusbar.height

            OfonoNetworkRegistration{
                id: cellularRegistrationStatus
                modemPath: path

                onStatusChanged: {
                    recalcIcon()
                }

                onStrengthChanged: {
                    recalcIcon()
                }
            }

            function recalcIcon() {
                if(!model.enabled) {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/disabled-sim.png"
                } else if(!cellularRegistrationStatus.status) {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/nosim.png"
                } else if(cellularRegistrationStatus.strength > 20){
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_signal_" + Math.ceil(cellularRegistrationStatus.strength/20) + ".png"
                } else {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_signal_0.png"
                }
            }
        }
    }
}
