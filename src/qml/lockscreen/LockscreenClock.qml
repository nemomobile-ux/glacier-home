import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtGraphicalEffects 1.0

import org.nemomobile.devicelock 1.0

Rectangle {
    id: lockscreenClock
    height: dateDisplay.height+timeDisplay.height+Theme.itemSpacingHuge
    width: parent.width

    gradient: Gradient {
        GradientStop { position: 0.0; color: '#b0000000' }
        GradientStop { position: 1.0; color: '#00000000' }
    }

    Item {
        id: clockColumn

        anchors.fill: parent
        anchors.topMargin: Theme.itemSpacingHuge

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

            font.pixelSize: Theme.fontSizeSmall
            font.capitalization: Font.AllUppercase
            color: Theme.textColor

            anchors {
                right: timeDisplay.right
                bottom: timeDisplay.top
                bottomMargin: -Theme.itemSpacingHuge
            }

            text: Qt.formatDateTime(wallClock.time, "<b>ddd</b>, MMM d")
        }
    }
}
