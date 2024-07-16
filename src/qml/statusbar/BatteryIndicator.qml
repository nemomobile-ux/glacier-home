/****************************************************************************************
**
** Copyright (C) 2019-2024 Chupligin Sergey <neochapay@gmail.com>
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
import Nemo.Mce

import Nemo
import Nemo.Controls
import Nemo.Configuration

StatusbarItem {
    id: batteryIndicator
    property int chargeValue: 0

    width: statusbarRight.height*2
    iconSize: statusbarRight.height*2
    iconSizeHeight: statusbarRight.height

    MceBatteryLevel {
        id: batteryChargePercentage

        onPercentChanged: {
            chargeIcon();
        }
    }

    MceChargerState{
        onChargingChanged: {
            if(charging) {
                chargingTimer.start()
            } else {
                chargingTimer.stop()
                chargeIcon();
            }
        }
    }

    MceCableState{
        id: cableState
    }

    MceBatteryStatus{
        id: batteryStatus
    }

    source: "/usr/share/glacier-home/qml/theme/battery"+chargeValue+".png"

    NemoIcon {
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        source: "/usr/share/glacier-home/qml/theme/battery_grid.png"

        color: if(batteryStatus.status === MceBatteryStatus.Ok) {
                   Theme.textColor
               } else if (batteryStatus.status === MceBatteryStatus.Full) {
                   Theme.accentColor
               } else {
                   "red"
               }
    }

    NemoIcon {
        id: pluginIndicator
        width: parent.width
        height: parent.height
        anchors.centerIn: parent

        source: "image://theme/plug"
        fillMode: Image.PreserveAspectFit

        visible: cableState.connected

        color:  Theme.backgroundColor
    }

    Timer{
        id: chargingTimer
        interval: 500
        repeat: true
        running: false
        onTriggered: {
            if(batteryIndicator.chargeValue == 6)
            {
                chargeIcon()
            }
            else
            {
                batteryIndicator.chargeValue++
            }
        }
    }

    Component.onCompleted: {
        chargeIcon();
    }

    function chargeIcon()
    {
        if(batteryChargePercentage.percent > 85) {
            batteryIndicator.chargeValue = 6
        } else if (batteryChargePercentage.percent <= 5) {
            batteryIndicator.chargeValue = 0
        } else if (batteryChargePercentage.percent <= 10) {
            batteryIndicator.chargeValue = 1
        } else if (batteryChargePercentage.percent <= 25) {
            batteryIndicator.chargeValue = 2
        } else if (batteryChargePercentage.percent <= 40) {
            batteryIndicator.chargeValue = 3
        } else if (batteryChargePercentage.percent <= 65) {
            batteryIndicator.chargeValue = 4
        } else if (batteryChargePercentage.percent <= 80) {
            batteryIndicator.chargeValue = 5
        } else {
            batteryIndicator.chargeValue = 6
        }
    }

}
