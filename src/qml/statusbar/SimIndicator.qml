/****************************************************************************************
**
** Copyright (C) 2020-2024 Chupligin Sergey <neochapay@gmail.com>
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
import QtQuick.Layouts

import QOfono

import org.nemomobile.lipstick

Row {
    id: simIndicator
    spacing: Theme.itemSpacingExtraSmall

    property var modems: []

    width: childrenRect.width
    height: parent.height

    OfonoManager {
        id: ofonoManager
        onModemsChanged: {
            recalcModel()
        }
        Component.onCompleted: {
            recalcModel()
        }

        function recalcModel() {
            simIndicator.modems = [];
            for(var i = 0; i < ofonoManager.modems.length; i++) {
                simIndicator.modems.push(modems[i]);
            }
            simRepeater.model = simIndicator.modems;
        }
    }


    Layout.fillWidth: true
    Layout.fillHeight: true

    Repeater{
        id: simRepeater

        model: simIndicator.modems

        height: parent.height
        width: parent.height*ofonoManager.modems.length

        delegate: StatusbarItem {
            id: cellStatus
            width: simIndicator.height
            height: simIndicator.height

            source: "/usr/share/lipstick-glacier-home-qt6/qml/theme/nosim.png"
            iconSize:       simIndicator.height
            iconSizeHeight: simIndicator.height

            OfonoNetworkRegistration{
                id: cellularRegistrationStatus
                modemPath: modelData

                onStatusChanged: {
                    recalcIcon()
                }

                onStrengthChanged: {
                    recalcIcon()
                }
            }

            function recalcIcon() {
                // TODO FIXUP enabling/Disabling
                /*if(!model.enabled) {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt6/qml/theme/disabled-sim.png"
                } else */if(!cellularRegistrationStatus.status) {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt6/qml/theme/nosim.png"
                } else if(cellularRegistrationStatus.strength > 20){
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt6/qml/theme/icon_signal_" + Math.ceil(cellularRegistrationStatus.strength/20) + ".png"
                } else {
                    cellStatus.source = "/usr/share/lipstick-glacier-home-qt6/qml/theme/icon_signal_0.png"
                }
            }
        }
    }
}
