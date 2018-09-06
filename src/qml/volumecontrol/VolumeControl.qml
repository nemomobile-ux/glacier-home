/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2018 Chupligin Sergey <neochapay@gmail.com>
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
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.lipstick 0.1


import "../scripts/desktop.js" as Desktop


Rectangle{
    id: volumeControlWindow

    width: Desktop.instance.width
    height: Theme.itemHeightHuge

    color: Theme.backgroundColor

    property int pressedKey

    visible: false

    Slider {
        id: volumeSlider
        width: parent.width*0.8

        anchors.centerIn: parent

        minimumValue: 0
        value: volumeControl.volume
        maximumValue: volumeControl.maximumVolume

        onValueChanged:{
            volumeControlWindow.visible = true
            voltimer.restart()

            volumeControl.volume = volumeSlider.value
        }
    }

    Timer {
        id: voltimer
        interval: 2000
        onTriggered: volumeControlWindow.visible = false
    }

    Connections {
        target: volumeControl
        onVolumeKeyPressed: {
            volumeControlWindow.pressedKey = key;

            volumeControl.windowVisible = true

            volumeChange()
            keyPressTimer.start()
            maxMinTimer.start()

            if (volumeControl.windowVisible) {
                voltimer.restart()
            }
        }

        onVolumeKeyReleased: {
            keyPressTimer.stop()
            maxMinTimer.stop()
            volumeControlWindow.pressedKey = ""
        }

        onWindowVisibleChanged: {
            if (volumeControl.windowVisible) {
                volumeControlWindow.visible = true
                voltimer.restart()
            }
        }
    }

    Timer{
        id: keyPressTimer
        interval: 500
        onTriggered: {
            volumeChange()
            voltimer.restart()
        }
        repeat: true
    }

    Timer{
        id: maxMinTimer
        interval: 1900
        onTriggered: {
            if(volumeControlWindow.pressedKey == Qt.Key_VolumeUp) {
                volumeControl.volume = volumeSlider.maximumValue
            } else if(volumeControlWindow.pressedKey == Qt.Key_VolumeDown) {
                volumeControl.volume = 0
            }
        }
    }

    function volumeChange()
    {
        if(volumeControlWindow.pressedKey == Qt.Key_VolumeUp) {
            //up volume
            if(volumeControl.volume < volumeSlider.maximumValue) {
                volumeControl.volume = volumeControl.volume+1
            }
        } else if(volumeControlWindow.pressedKey == Qt.Key_VolumeDown) {
            //down volume
            if(volumeControl.volume > 0) {
                volumeControl.volume = volumeControl.volume-1
            }
        }
    }
}
