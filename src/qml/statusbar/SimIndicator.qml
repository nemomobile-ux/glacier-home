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
            iconSize: statusbar.height

            ContextProperty {
                id: cellularSignalBars
                key: (model.index == 0) ? "Cellular.SignalBars" : "Cellular_"+model.index+".SignalBars"
                //0-5
                onValueChanged: {
                    cellStatus.recalcIcon();
                }
            }

            ContextProperty {
                id: cellularRegistrationStatus
                key: (model.index == 0) ? "Cellular.RegistrationStatus" : "Cellular_"+model.index+".RegistrationStatus"
                //no-sim
                //home
                //roaming
                onValueChanged: {
                    cellStatus.recalcIcon();
                }
            }

            function recalcIcon() {
                if(!model.enabled) {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/disabled-sim.png"
                } else if(cellularRegistrationStatus.value == "no-sim") {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/nosim.png"
                } else if(cellularSignalBars.value){
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_signal_" + cellularSignalBars.value + ".png"
                } else {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_signal_0.png"
                }
            }

            Component.onCompleted: {
                cellularSignalBars.subscribe()
                cellularRegistrationStatus.subscribe()

                recalcIcon();
            }
        }
    }
}
