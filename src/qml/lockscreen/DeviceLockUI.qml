/****************************************************************************************
**
** Copyright (C) 2020-2025 Chupligin Sergey <neochapay@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick
import Nemo
import Nemo.Controls

import org.nemomobile.lipstick
import org.nemomobile.devicelock
import Nemo.DBus

Item {
    id: deviceLockUi

    width: codePad.width
    height: visible ? messagesRow.height + lockCode.height + Theme.itemWidthSmall*4 + Theme.itemSpacingSmall * 6 : 0

    property int remainingAttempts
    property AuthenticationInput authenticationInput
    signal authOK()


    onVisibleChanged: lockCodeField.text = ""

    Column {
        id: codePadColumn
        anchors.bottom: deviceLockUi.bottom

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
            id: messagesRow
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

        Item{
            id: lockCode
            width: codePad.width
            height: Theme.itemHeightExtraLarge

            anchors.horizontalCenter: parent.horizontalCenter

            TextField {
                id: lockCodeField
                width: parent.width - Theme.itemSpacingSmall*2
                anchors{
                    left: parent.left
                    leftMargin: Theme.itemSpacingSmall
                    verticalCenter: parent.verticalCenter
                }
                horizontalAlignment: TextInput.AlignHCenter
                background: Item {}
                readOnly: true
                echoMode: TextInput.PasswordEchoOnEdit
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }

        Grid {
            id: codePad
            width: Theme.itemWidthSmall*3 + Theme.itemSpacingSmall*4
            height: childrenRect.height
            anchors.horizontalCenter: parent.horizontalCenter
            padding: Theme.itemSpacingSmall
            spacing: Theme.itemSpacingSmall
            columns: 3
            Repeater {
                model: ["1","2","3","4","5","6","7","8","9","<","0","OK"]
                delegate: NumPadButton {}
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
        target: deviceLockUi.authenticationInput

        function onFeedback(feedback, data) { deviceLockUi.displayFeedback(feedback, data) }
        function onAuthenticationEnded(confirmed) {
            if(confirmed) {
                authOK()
            }
        }
    }

}
