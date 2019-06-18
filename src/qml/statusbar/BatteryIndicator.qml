import QtQuick 2.6
import org.freedesktop.contextkit 1.0

StatusbarItem {
    id: batteryIndicator
    property int chargeValue: 0
    property alias batteryChargePercentage: batteryChargePercentage

    width: statusbar.height*2
    iconSize: statusbar.height * 2
    iconSizeHeight: statusbar.height


    ContextProperty {
        id: batteryChargePercentage
        key: "Battery.ChargePercentage"
        value: "100"
        onValueChanged: {
            if(batteryStateContextProperty.value != "charging") {
                chargeIcon();
            }
        }
    }

    ContextProperty {
        id: batteryStateContextProperty
        key: "Battery.State"
        onValueChanged: {
            if(batteryStateContextProperty.value == "charging")
            {
                if (batteryChargePercentage.value === 100) {
                    chargingTimer.stop()
                    chargeIcon()
                }else {
                    chargingTimer.start()
                }
            }
            else
            {
                chargingTimer.stop()
                chargeIcon();
            }
        }
    }

    source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/battery"+chargeValue+".png"

    Image {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/battery_grid.png"
    }

    Timer{
        id: chargingTimer
        interval: 500
        repeat: true
        running: false
        onTriggered: {
            if(batteryIndicator.chargeValue == 6)
            {
                batteryIndicator.chargeValue = 0
            }
            else
            {
                batteryIndicator.chargeValue++
            }
        }
    }

    Component.onCompleted: {
        chargeIcon();
    }

    function chargeIcon()
    {
        if(batteryChargePercentage.value > 85) {
            batteryIndicator.chargeValue = 6
        } else if (batteryChargePercentage.value <= 5) {
            batteryIndicator.chargeValue = 0
        } else if (batteryChargePercentage.value <= 10) {
            batteryIndicator.chargeValue = 1
        } else if (batteryChargePercentage.value <= 25) {
            batteryIndicator.chargeValue = 2
        } else if (batteryChargePercentage.value <= 40) {
            batteryIndicator.chargeValue = 3
        } else if (batteryChargePercentage.value <= 65) {
            batteryIndicator.chargeValue = 4
        } else if (batteryChargePercentage.value <= 80) {
            batteryIndicator.chargeValue = 5
        } else {
            batteryIndicator.chargeValue = 6
        }
    }

}
