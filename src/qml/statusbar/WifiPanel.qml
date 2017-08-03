/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2017 Sergey Chupligin <mail@neochapay.ru>
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
import MeeGo.Connman 0.2

Component {
    CommonPanel {
        id: wifiPanel
        name: "Wifi"
        switcherEnabled: true
        switcherChecked: wifimodel.powered

        onSwitcherCheckedChanged: {
             wifimodel.setPowered(switcherChecked)
        }

        property list<QtObject> _data: [
            TechnologyModel {
                id: wifimodel
                name: "wifi"
            }
        ]

        Repeater {
            model: wifimodel
            delegate: Item {
                width: wifiPanel.width
                height: Theme.itemHeightSmall
                function getStrengthIndex(strength) {
                    var strengthIndex = "0"
                    if (strength >= 59) {
                        strengthIndex = "4"
                    } else if (strength >= 55) {
                        strengthIndex = "3"
                    } else if (strength >= 50) {
                        strengthIndex = "2"
                    } else if (strength >= 40) {
                        strengthIndex = "1"
                    }
                    return strengthIndex
                }
                Row {
                    spacing: Theme.itemSpacingSmall
                    Image {
                        id: statusImage
                       source: (getStrengthIndex(modelData.strength) === "0")? "image://theme/icon_wifi_0" : (modelData.state === "online" ? "image://theme/icon_wifi_focused" : "image://theme/icon_wifi_normal")+ getStrengthIndex(modelData.strength)
                    }

                    Label {
                        anchors{
                            leftMargin: Theme.itemSpacingLarge
                            verticalCenter: statusImage.verticalCenter
                        }
                        width: root.width
                        font.pixelSize: Theme.fontSizeMedium
                        text: modelData.name
                        wrapMode: Text.Wrap
                        color: modelData.state === "online" ? Theme.accentColor : Theme.textColor
                    }
                }
            }
        }
    }
}
