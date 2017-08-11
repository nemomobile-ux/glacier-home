import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import "js/fontawesome.js" as FontAwesome
import "js/ionicons.js" as Ionicons

Button{
    property string fontFamily : "IonIcons"
    property var glyph : Ionicons.Icon.person_add
    property string buttonColor: "#1f1f1f"
    style: ButtonStyle {
        roundedButton: true
        bgColor: buttonColor
    }
    width: size.dp(86)
    height: width
    Text {
        anchors.centerIn: parent
        font.pointSize: 32
        font.family: fontFamily
        text: glyph
        color: "white"
        opacity: 0.5
    }
}
