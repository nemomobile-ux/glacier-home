import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0

import "scripts/desktop.js" as Desktop

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
            Desktop.instance.setLockScreen(false)
            Desktop.instance.codepadVisible = false
        }
        onFeedback: {
            console.log('### still locked', feedback, attemptsRemaining)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.itemSpacingExtraSmall

        TextField {
            id: lockCodeField
            anchors.horizontalCenter: parent.horizontalCenter
            readOnly: true
            echoMode: TextInput.PasswordEchoOnEdit
            font.pixelSize: Theme.fontSizeMedium
        }

        GridLayout {
            height: parent.height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 3
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","Ca","0","OK"]
                delegate:
                    Button {
                    id:button
                    Layout.maximumWidth: Theme.itemWidthSmall
                    Layout.maximumHeight: Theme.itemHeightHuge * 2
                    Layout.minimumHeight: Theme.itemHeightHuge * 1.5
                    text: modelData
                    onClicked: {
                        if (button.text !== "Ca" && button.text !== "OK") {
                            lockCodeField.insert(lockCodeField.cursorPosition, button.text)
                        } else {
                            if (button.text === "OK") {
                                authenticator.enterLockCode(lockCodeField.text)
                                lockCodeField.text = ""
                            } else if (button.text === "Ca"){
                                lockCodeField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
