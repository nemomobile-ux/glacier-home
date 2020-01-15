import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtGraphicalEffects 1.0

import org.freedesktop.contextkit 1.0
import org.nemomobile.devicelock 1.0
import org.nemomobile.ofono 1.0

Rectangle {
    id: lockscreenClock
    height: parent.height/3
    width: parent.width

    OfonoModemListModel{
        id: modemModel
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: '#b0000000' }
        GradientStop { position: 1.0; color: '#00000000' }
    }

    Item {
        id: clockColumn

        anchors.fill: parent

        Text {
            id: timeDisplay
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeExtraLarge*3
            lineHeight: 0.85
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
            color: Theme.textColor
            text: Qt.formatDateTime(wallClock.time, "hh:mm")
        }

        Text {
            id: dateDisplay

            font.pointSize: 9
            font.capitalization: Font.AllUppercase
            color: Theme.textColor

            anchors {
                right: timeDisplay.right
                bottom: timeDisplay.top
                bottomMargin: -Theme.itemSpacingHuge
            }

            text: Qt.formatDateTime(wallClock.time, "<b>ddd</b>, MMM d")
        }
        Row{
            anchors{
                top: timeDisplay.bottom
                bottomMargin: -Theme.itemSpacingHuge
                horizontalCenter: parent.horizontalCenter
            }

            Repeater{
                id: simRepeater
                model: modemModel

                delegate: Text{
                    id: operatorText
                    font.pointSize: 9
                    color: Theme.textColor
                    horizontalAlignment: Text.AlignHCenter

                    ContextProperty {
                        id: cellularNetworkName
                        key: (model.index == 0) ? "Cellular.NetworkName" : "Cellular_"+model.index+".NetworkName"
                        onValueChanged: (model.index == 0) ? operatorText.text = value : operatorText.text = " | "+value
                    }
                }
            }
        }
    }
}
