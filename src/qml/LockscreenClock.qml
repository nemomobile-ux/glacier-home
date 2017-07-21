
import QtQuick 2.1
import org.nemomobile.devicelock 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Rectangle {
    id: lockscreenClock
    height: (timeDisplay.height + dateDisplay.height) * 1.5

    gradient: Gradient {
        GradientStop { position: 0.0; color: '#b0000000' }
        GradientStop { position: 1.0; color: '#00000000' }
    }

    Column {
        id: clockColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Text {
            id: timeDisplay

            font.pixelSize: Theme.fontSizeExtraLarge * 2
            font.weight: Font.Light
            lineHeight: 0.85
            color: Theme.textColor
            horizontalAlignment: Text.AlignHCenter

            anchors {
                left: parent.left
                right: parent.right
            }

            text: Qt.formatDateTime(wallClock.time, "hh:mm")
        }
        Rectangle {
            id: dateRow
            height: childrenRect.height
            width: weekdayDisplay.width + dateDisplay.width
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            color: "transparent"

            Label {
                id: weekdayDisplay

                font.pixelSize: Theme.fontSizeLarge
                color: Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.Bold
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                text: Qt.formatDateTime(wallClock.time, "dddd")
            }

            Label {
                id: dateDisplay

                font.pixelSize: Theme.fontSizeLarge
                color: Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                font.weight: Font.Light
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: weekdayDisplay.bottom
                }

                text: Qt.formatDate(wallClock.time, "d MMMM yyyy")
            }
        }

    }
}

