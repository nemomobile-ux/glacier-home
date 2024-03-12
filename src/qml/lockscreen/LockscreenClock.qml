/****************************************************************************************
**
** Copyright (C) 2023-2024 Chupligin Sergey <neochapay@gmail.com>
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
import Nemo.Controls

import org.nemomobile.devicelock

Rectangle {
    id: lockscreenClock
    height: dateDisplay.height+timeDisplay.height+Theme.itemSpacingHuge
    width: parent.width

    gradient: Gradient {
        GradientStop { position: 0.0; color: '#b0000000' }
        GradientStop { position: 1.0; color: '#00000000' }
    }

    Item {
        id: clockColumn

        anchors.fill: parent
        anchors.topMargin: Theme.itemSpacingHuge

        Text {
            id: timeDisplay
            anchors.centerIn: parent
            font.pixelSize: Theme.fontSizeExtraLarge*3
            lineHeight: 0.85
            font.weight: Font.Light
            horizontalAlignment: Text.AlignHCenter
            color: Theme.textColor
            text: Qt.formatDateTime(wallClock.time, "hh:mm")
        }

        Text {
            id: dateDisplay

            font.pixelSize: Theme.fontSizeSmall
            font.capitalization: Font.AllUppercase
            color: Theme.textColor

            anchors {
                right: timeDisplay.right
                bottom: timeDisplay.top
                bottomMargin: -Theme.itemSpacingHuge
            }

            text: Qt.formatDateTime(wallClock.time, "<b>ddd</b>, MMM d")
        }
    }
}
