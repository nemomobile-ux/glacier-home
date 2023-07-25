/****************************************************************************************
**
** Copyright (C) 2021-2023 Chupligin Sergey <neochapay@gmail.com>
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
import Nemo.Controls
import org.nemomobile.lipstick 0.1
import ".."
import "../mainscreen/"

Rectangle {
    id: shutdownWindow
    width: initialSize.width
    height: initialSize.height
    color: Theme.backgroundColor

    property bool shouldVisible
    opacity: shutdownScreen.windowVisible

    GlacierRotation {
        id: glacierRotation
        rotationParent: shutdownWindow.parent
    }

    Connections {
        target: shutdownScreen
        function onWindowVisibleChanged(windowVisible) {
            if (shutdownScreen.windowVisible) {
                glacierRotation.rotateRotationParent(nativeOrientation)
            }
        }
    }

    Image {
        id: logoImage
        anchors.centerIn: parent
        source: shutdownMode ? "" : "image://theme/graphic-nemo-logo"
    }

    Text {
        visible: !shutdownMode
        anchors.top: logoImage.bottom
        anchors.topMargin: Theme.itemSpacingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.textColor
        text: qsTr("Shutting down")
        font.pixelSize:Theme.fontSizeMedium
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 500
            onRunningChanged: if (!running && shutdownWindow.opacity == 0) shutdownScreen.windowVisible = false
        }
    }
}
