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
    property int remainingAttempts

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
            remainingAttempts = 0
        }
        onFeedback: {
            console.log('### still locked', feedback, attemptsRemaining)
            remainingAttempts = attemptsRemaining
            animation.start()
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
            font.pixelSize: Theme.fontSizeExtraLarge
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
                    height: Theme.itemHeightHuge
                    width: Theme.itemHeightHuge
                    Layout.maximumWidth: Theme.itemHeightHuge * 1.5
                    Layout.maximumHeight: Theme.itemHeightHuge * 1.5
                    Label {
                        id: btnLabel
                        text: modelData
                        font.pixelSize: Theme.fontSizeExtraLarge * 1.5
                        anchors {
                            centerIn: parent
                        }
                    }

                    onClicked: {
                        if (btnLabel.text !== "Ca" && btnLabel.text !== "OK") {
                            lockCodeField.insert(lockCodeField.cursorPosition, btnLabel.text)
                        } else {
                            if (btnLabel.text === "OK") {
                                authenticator.enterLockCode(lockCodeField.text)
                                lockCodeField.text = ""
                            } else if (btnLabel.text === "Ca"){
                                lockCodeField.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
