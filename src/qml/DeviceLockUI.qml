import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import org.nemomobile.glacierauthentication 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0

import "scripts/desktop.js" as Desktop

Item {
    id: root

    property bool shouldAuthenticate: Lipstick.compositor.visible //&& asd.availableMethods !== 0
    property int remainingAttempts
    property AuthenticationInput authenticationInput
    signal codeEntered(string code)

    onShouldAuthenticateChanged: {
        if (shouldAuthenticate) {
            //console.log("Requesting security code "+ authenticationInput.status)
            //authenticationInput.requestSecurityCode()
            //DeviceLock.authorization.requestChallenge()
        } else {
            //authenticator.cancel()
            //DeviceLock.authorization.relinquishChallenge()
        }
    }

    /*Component.onCompleted: {
        console.log("Requesting security code "+ authenticationInput.Status)
        authenticationInput.requestSecurityCode()
    }*/

    /*Connections {
        target: DeviceLock.authorization
        onChallengeIssued: {
            authenticator.authenticate(
                        DeviceLock.authorization.challengeCode,
                        DeviceLock.authorization.allowedMethods)
        }
    }*/

    Authenticator {
        id: auth
        Component.onCompleted: {
            console.log("Requesting challenge")
            Authorization.requestChallege()
        }

        onAuthenticated: {
            console.log("Authenticated: "+DeviceLock.state)
        }
    }

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
        Label {
            font.pixelSize: Theme.fontSizeMedium
            width: parent.width
            text:  remainingAttempts > 0 ? qsTr("Attempts remaining:") + " " + remainingAttempts : ""
            anchors.horizontalCenter: parent.horizontalCenter
        }
        TextField {
            id: lockCodeField
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
                        if (numLabel.text !== "Ca" && numLabel.text !== "OK") {
                            //console.log(authenticationInput.Status)
                            lockCodeField.insert(lockCodeField.cursorPosition, numLabel.text)
                        } else {
                            if (numLabel.text === "OK") {
                                console.log("DeviceLockUI: "+auth.availableMethods)
                                auth.authenticate(Authorization.challengeCode, auth.availableMethods)
                                //authenticationInput.enterSecurityCode(lockCodeField.text)
                                //codeEntered(lockCodeField.text)
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
        console.log("DisplayFeedBack "+feedback+" "+data)
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
