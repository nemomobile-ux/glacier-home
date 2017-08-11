import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: lockscreenClock
    height: (timeDisplay.height + dateDisplay.height) * 1.5

    FontLoader { id: firaSans; source:       "theme/fonts/FiraSans-Regular.ttf" }
    FontLoader { id: firaSansLight; source:  "theme/fonts/FiraSans-Light.ttf" }


    gradient: Gradient {
        GradientStop { position: 0.0; color: '#b0000000' }
        GradientStop { position: 1.0; color: '#00000000' }
    }

    Column {
        id: clockColumn

        width: timeDisplay.paintedWidth
        height: timeDisplay.paintedHeight + dateDisplay.paintedHeight

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }

        Text {
            id: timeDisplay

            font.pointSize: 40
            font { family: firaSansLight.name }

            lineHeight: 0.85
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter

            visible: false

            anchors {
                left: parent.left
                right: parent.right
            }

            text: Qt.formatDateTime(wallClock.time, "hh:mm")
        }

        LinearGradient  {
            anchors.fill: timeDisplay
            source: timeDisplay
            gradient: Gradient {
                GradientStop { position: 0; color: "white" }
                GradientStop { position: 1; color: "#dcdcdc" }
            }
        }

        Text {
            id: dateDisplay

            font.pointSize: 9
            font.capitalization: Font.AllUppercase
            color: "white"

            anchors {
                
                left: parent.left
                bottom: parent.bottom;
            }

            //text: Qt.formatDateTime(wallClock.time, "<b>d</b>/M | ddd")
            text: Qt.formatDateTime(wallClock.time, "<b>ddd</b>, MMM d")
        }
    }

    DropShadow {
        anchors.fill: clockColumn
        horizontalOffset: 2
        verticalOffset: 4
        radius: 5
        samples: 5
        color: "#50000000"
        source: clockColumn
    }

    
}

