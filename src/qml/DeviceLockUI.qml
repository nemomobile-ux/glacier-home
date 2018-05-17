import QtQuick 2.6
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import org.nemomobile.dbus 1.0

import "scripts/desktop.js" as Desktop

Item {
    id: root

    property bool shouldAuthenticate: Lipstick.compositor.visible
    property int remainingAttempts
    property AuthenticationInput authenticationInput

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.itemSpacingLarge

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
                font.pixelSize: Theme.fontSizeMedium
                text: " "
            }
            Label {
                id: attemptsRemainingLabel
                font.pixelSize: Theme.fontSizeMedium
                text: " "
            }
        }
        TextField {
            id: lockCodeField
            anchors.topMargin: Theme.itemSpacingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            readOnly: true
            echoMode: TextInput.PasswordEchoOnEdit
            font.pixelSize: Theme.fontSizeMedium
        }

        GridLayout {
            id: codePad
            height: parent.height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 3
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","Ca","0","OK"]
                delegate:
                    Button {
                    id:button
                    opacity: 1
                    Layout.maximumWidth: Theme.itemWidthSmall
                    Layout.maximumHeight: Theme.itemHeightHuge * 2
                    Layout.minimumHeight: Theme.itemHeightHuge * 1.5
                    Text {
                        id: numLabel
                        text: modelData
                        font.pixelSize: Theme.fontSizeLarge
                        anchors.centerIn: parent
                        color: "white"
                    }
                    onClicked: {
                        displayOffTimer.restart()
                        feedbackLabel.text = " "
                        attemptsRemainingLabel.text = " "
                        if (numLabel.text !== "Ca" && numLabel.text !== "OK") {
                            lockCodeField.insert(lockCodeField.cursorPosition, numLabel.text)
                        } else {
                            if (numLabel.text === "OK") {
                                authenticationInput.enterSecurityCode(lockCodeField.text)
                                lockCodeField.text = ""
                            } else if (numLabel.text === "Ca"){
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
    function displayError(error) {
        console.log("displayError "+error)
    }

    Connections {
        target: root.authenticationInput

        onFeedback: root.displayFeedback(feedback, data)
        onError: root.displayError(error)
    }

}
