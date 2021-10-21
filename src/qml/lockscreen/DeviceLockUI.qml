import QtQuick 2.6
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import Nemo.DBus 2.0


import "../scripts/desktop.js" as Desktop

Item {
    id: root

    property int remainingAttempts
    property AuthenticationInput authenticationInput
    signal authOK()

    Column {
        id: codePadColumn
        anchors.fill: parent

        SequentialAnimation  {
            id: animation;
            SequentialAnimation  {
                loops: 4
                NumberAnimation { target: codePad; property: "anchors.horizontalCenterOffset"; to: 55; duration: 50 }
                NumberAnimation { target: codePad; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
            }
            NumberAnimation { target: codePad; property: "anchors.horizontalCenterOffset"; to: 0; duration: 100 }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            Label {
                id: feedbackLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeMedium
                text: " "
                horizontalAlignment: Text.AlignHCenter
            }
            Label {
                id: attemptsRemainingLabel
                font.pixelSize: Theme.fontSizeMedium
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: " "
            }
        }

        Rectangle{
            id: lockCode
            width: parent.width*0.85
            height: Theme.itemHeightExtraLarge
            radius: Theme.itemSpacingSmall

            anchors.horizontalCenter: parent.horizontalCenter

            color: "transparent"
            clip: true

            Rectangle{
                anchors.fill: parent
                color: Theme.backgroundColor
                opacity: 0.5
                radius: Theme.itemSpacingSmall
            }

            TextField {
                id: lockCodeField

                anchors{
                    left: parent.left
                    leftMargin: Theme.itemSpacingSmall
                    verticalCenter: parent.verticalCenter
                }

                readOnly: true
                echoMode: TextInput.PasswordEchoOnEdit
                font.pixelSize: Theme.fontSizeMedium
            }

            Image {
                width: parent.height-Theme.itemSpacingSmall*2
                height: width

                anchors{
                    right: parent.right
                    rightMargin: Theme.itemSpacingSmall*2
                    verticalCenter: parent.verticalCenter
                }
                fillMode: Image.PreserveAspectFit
                source:  (lockCodeField.echoMode == TextInput.PasswordEchoOnEdit) ? "image://theme/eye-slash" : "image://theme/eye"

                MouseArea{
                    anchors.fill: parent
                    onPressAndHold: {
                        if(lockCodeField.echoMode == TextInput.PasswordEchoOnEdit) {
                            lockCodeField.echoMode = TextInput.Normal
                        } else {
                            lockCodeField.echoMode = TextInput.PasswordEchoOnEdit
                        }
                    }
                }
            }
        }

        Grid {
            id: codePad
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 3
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","<","0","OK"]
                delegate:
                    Rectangle {
                    id:button
                    width: root.width/3 > root.height/4 ? root.height/4 : root.width/3
                    height: width

                    color: "transparent"

                    Text {
                        id: numLabel
                        text: modelData
                        font.pixelSize: Theme.fontSizeLarge
                        anchors.centerIn: parent
                        color: "white"
                    }

                    MouseArea{
                        anchors.fill: parent

                        onClicked: {
                            feedbackLabel.text = " "
                            attemptsRemainingLabel.text = " "
                            if (numLabel.text !== "<" && numLabel.text !== "OK") {
                                lockCodeField.insert(lockCodeField.cursorPosition, numLabel.text)
                            } else {
                                if (numLabel.text === "OK") {
                                    authenticationInput.enterSecurityCode(lockCodeField.text)
                                    lockCodeField.text = ""
                                } else if (numLabel.text === "<"){
                                    lockCodeField.text = lockCodeField.text.slice(0, -1)
                                }
                            }
                        }

                        onPressAndHold: {
                            if (numLabel.text === "<"){
                                lockCodeField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }

    function displayFeedback(feedback, data) {
        switch(feedback) {

        case AuthenticationInput.EnterSecurityCode:
            feedbackLabel.text = qsTr("Enter security code")
            break

        case AuthenticationInput.IncorrectSecurityCode:
            feedbackLabel.text = qsTr("Incorrect code")
            if(authenticationInput.maximumAttempts !== -1) {
                attemptsRemainingLabel.text = qsTr("("+(authenticationInput.maximumAttempts-data.attemptsRemaining)+
                                                   "/"+authenticationInput.maximumAttempts+")")
            }
            animation.start()
            break
        case AuthenticationInput.TemporarilyLocked:
            feedbackLabel.text = qsTr("Temporarily locked")
        }
    }

    Connections {
        target: root.authenticationInput

        function onFeedback(feedback, data) { root.displayFeedback(feedback, data) }
        function onAuthenticationEnded(confirmed) {
            if(confirmed) {
                authOK()
            }
        }
    }

}
