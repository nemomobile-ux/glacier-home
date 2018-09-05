import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

Item {
    id: contolButton
    property string image: "image://theme/image"
    property string buttonColor: "#1f1f1f"
    property string textLabel: "Toggle"

    signal clicked();

    height: parent.height
    Layout.fillWidth: true
    Button{
        anchors.horizontalCenter: parent.horizontalCenter

        width: size.dp(86)
        height: width
        Image {
            anchors.centerIn: parent
            source: image
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

        onClicked: {
            contolButton.clicked()
        }
    }
}
