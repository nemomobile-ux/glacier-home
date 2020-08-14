/****************************************************************************************
**
** Copyright (C) 2020 Sergey Chupligin <sergey@neochapay.ru>
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
import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Rectangle {
    id: welcome

    color: Theme.backgroundColor

    signal startClicked()

    Rectangle{
        id: accentPoint
        width: Theme.itemHeightLarge
        height: Theme.itemHeightLarge
        color: Theme.accentColor
        radius: (width > height) ? width : height

        visible: false

        Behavior on width{
            NumberAnimation { duration: 600 }
        }

        Behavior on height{
            NumberAnimation { duration: 600 }
        }

        Behavior on x{
            id: xMove
            enabled: false
            NumberAnimation { duration: 600 }
        }

        Behavior on y{
            id: yMove
            enabled: false
            NumberAnimation { duration: 600 }
        }

        Behavior on radius{
            NumberAnimation { duration: 1200 }
        }

        onVisibleChanged: {
            xMove.enabled = true
            yMove.enabled = true
            x = 0
            y = 0
            radius = 0
        }
    }

    Repeater{
        id: helloRepeater
        model: SayMeHello{}
        delegate: Label {
            id: hiText
            text: model.text
            x: Math.random()*parent.width-hiText.width
            y: Math.random()*parent.height-hiText.height
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.fillColor
        }
    }

    Label{
        id: hi
        anchors.centerIn: parent
        text: "NemoMobile"
        font.pixelSize: Theme.fontSizeExtraLarge
    }

    MouseArea{
        id: clickArea
        anchors.fill: parent
        onClicked: {
            accentPoint.x = mouse.x
            accentPoint.y = mouse.y
            accentPoint.visible = true
            accentPoint.width = welcome.width
            accentPoint.height = welcome.height
            clickArea.enabled = false

            welcome.startClicked();
        }
    }
}
