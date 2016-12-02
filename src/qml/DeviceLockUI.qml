import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0

Item {
    id: root

    property bool shouldAuthenticate: Lipstick.compositor.visible
                                      && authenticator.availableMethods !== 0
    onShouldAuthenticateChanged: {
        if (shouldAuthenticate) {
            DeviceLock.authorization.requestChallenge()
        } else {
            authenticator.cancel()
            DeviceLock.authorization.relinquishChallenge()
        }
    }

    Component.onCompleted: {
        DeviceLock.authorization.requestChallenge()
    }

    Connections {
        target: DeviceLock.authorization
        onChallengeIssued: {
            authenticator.authenticate(
                        DeviceLock.authorization.challengeCode,
                        DeviceLock.authorization.allowedMethods)
        }
    }


    Authenticator {
        id: authenticator
        onAuthenticated: {
            DeviceLock.unlock(authenticationToken)
        }
        onFeedback: {
            console.log('### still locked', feedback, attemptsRemaining)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 40

        TextField {
            id: lockCodeField
            readOnly: true
            echoMode: TextInput.PasswordEchoOnEdit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        GridLayout {
            height: parent.height
            width: parent.width
            columns: 3
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","Ca","0","OK"]
                delegate:
                    Button {
                    style: ButtonStyle {}
                    Layout.fillWidth: true
                    text: modelData
                    onClicked: {
                        if (text !== "Ca" && text !== "OK") {
                            lockCodeField.insert(lockCodeField.cursorPosition, text)
                        } else {
                            if (text === "OK") {
                                authenticator.enterLockCode(lockCodeField.text)
                                lockCodeField.text = ""
                            } else if (text === "Ca"){
                                lockCodeField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
