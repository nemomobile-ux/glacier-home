
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

import QtQuick 2.0
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

MouseArea {
    id: switcherItemRoot

    property bool rotateWindowContent: desktop.isPortrait

    WindowPixmapItem {
        id: windowPixmap
        width: rotateWindowContent ? parent.width : parent.height
        height: rotateWindowContent ? parent.height : parent.width
        windowId: model.window
        transform: Rotation {
            angle: rotateWindowContent ? 0 : 90
            origin.x: windowPixmap.height / 2
            origin.y: windowPixmap.height / 2
        }
        smooth: true
        radius: 5
        opacity: switcherRoot.closeMode ? .6 : 1
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
    }

    function close() {
        Lipstick.compositor.closeClientForWindowId(model.window)
    }

    onClicked: {
        if (!switcherRoot.closeMode) {
            Lipstick.compositor.windowToFront(model.window);
        }
    }

    onPressAndHold: {
        switcherRoot.closeMode = true;
    }

    SequentialAnimation {
        id: closeAnimation
        ParallelAnimation {
            NumberAnimation {
                target: switcherItemRoot
                property: "scale"
                duration: 200
                to: 0.0
            }

            NumberAnimation {
                target: switcherItemRoot
                property: "opacity"
                duration: 150
                to: 0.0
            }
        }
        ScriptAction {
            script: switcherItemRoot.close()
        }
    }
    Label {
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 30
        }
        font.pointSize: 8
        text: Lipstick.compositor.windowForId(model.window).title
    }

    CloseButton {
        id: closeButton
        width: parent.width/4
        height: width
        Behavior on scale { PropertyAnimation { duration: 300; easing.type: Easing.OutBack } }
        scale: switcherRoot.closeMode ? 1 : 0
        opacity: scale
        enabled: !closeAnimation.running
        anchors {
            bottom: parent.bottom
            bottomMargin: height*0.5
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: closeAnimation.start()
    }
}
