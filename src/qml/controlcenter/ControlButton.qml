import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import "../scripts/fontawesome.js" as FontAwesome
import "../scripts/ionicons.js" as Ionicons



Item {
    property string fontFamily : "IonIcons"
    property var glyph : Ionicons.Icon.person_add
    property string buttonColor: "#1f1f1f"
    property string textLabel: "Toggle"

    height: parent.height
    Layout.fillWidth: true
    Button{
        anchors.horizontalCenter: parent.horizontalCenter

        width: size.dp(86)
        height: width
        Text {
            anchors.centerIn: parent
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
            font.family: fontFamily
            text: glyph
            color: "white"
            opacity: 0.5
        }
        Text{
            anchors{
                top: parent.bottom
                topMargin: size.dp(8)
            }
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 6
            text: textLabel
            color: "white"
            opacity: 0.5
        }
    }
}
