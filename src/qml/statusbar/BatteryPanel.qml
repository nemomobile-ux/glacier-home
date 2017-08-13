/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
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

import QtQuick 2.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0
import org.nemomobile.dbus 2.0

Component {
    CommonPanel {
        name: qsTr("Battery");
        switcherEnabled: false
        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.itemSpacingSmall
            Label {
                id:percentageLabel
                text: qsTr("Level")+ ": " + batteryChargePercentage.value + "%"
                font.pixelSize: Theme.fontSizeSmall
                anchors.leftMargin: Theme.itemSpacingSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Item {
                id:powerSaveWrapper
                //Copyright  Andrey Kozhevnikov https://github.com/CODeRUS/jolla-settings-powersave/blob/master/settings/mainpage.qml
                Layout.fillWidth: true
                Layout.fillHeight: true

                property string key_threshold_value: "/system/osso/dsm/energymanagement/psm_threshold"
                property string key_powersave_enable: "/system/osso/dsm/energymanagement/enable_power_saving"
                property string key_powersave_force: "/system/osso/dsm/energymanagement/force_power_saving"

                property variant threshold_value
                property variant powersave_enable
                property variant powersave_force

                property var values: {
                    "/system/osso/dsm/energymanagement/psm_threshold": 50,
                            "/system/osso/dsm/energymanagement/enable_power_saving": true,
                            "/system/osso/dsm/energymanagement/force_power_saving": true
                }

                DBusInterface {
                    id: mceRequestIface
                    service: 'com.nokia.mce'
                    path: '/com/nokia/mce/request'
                    iface: 'com.nokia.mce.request'
                    bus: DBus.SystemBus

                    function setValue(key, value) {
                        typedCall('set_config', [{"type":"s", "value":key}, {"type":"v", "value":value}])
                    }

                    function getValue(key) {
                        typedCall('get_config', [{"type":"s", "value":key}], function (value) {
                            var temp = powerSaveWrapper.values
                            temp[key] = value
                            powerSaveWrapper.values = temp
                        })
                    }

                    Component.onCompleted: {
                        getValue(powerSaveWrapper.key_threshold_value)
                        getValue(powerSaveWrapper.key_powersave_enable)
                        getValue(powerSaveWrapper.key_powersave_force)
                    }
                }

                DBusInterface {
                    id: mceSignalIface
                    service: 'com.nokia.mce'
                    path: '/com/nokia/mce/signal'
                    iface: 'com.nokia.mce.signal'
                    bus: DBus.SystemBus

                    signalsEnabled: true

                    function config_change_ind(key, value) {
                        if (key in powerSaveWrapper.values) {
                            var temp = powerSaveWrapper.values
                            temp[key] = value
                            powerSaveWrapper.values = temp
                        }
                    }
                }
                CheckBox {
                    id:enablePowerSave

                    property string entryPath: "system_settings/info/powersave/powersave_enable"

                    checked: powerSaveWrapper.values[powerSaveWrapper.key_powersave_enable]
                    text: qsTr("Enable powersave mode")
                    onClicked: mceRequestIface.setValue(powerSaveWrapper.key_powersave_enable, checked)
                }
                Slider {
                    id: powerSaveSlider
                    width: parent.width -Theme.itemHeightMedium
                    anchors.top:enablePowerSave.bottom
                    anchors.topMargin: Theme.itemSpacingSmall

                    property string entryPath: "system_settings/info/powersave/powersave_threshold"

                    minimumValue: 1
                    maximumValue: 99
                    //label: "Battery threshold"
                    showValue: true
                    stepSize: 1

                    value: powerSaveWrapper.values[powerSaveWrapper.key_threshold_value] ? powerSaveWrapper.values[powerSaveWrapper.key_threshold_value] : 0
                    onPressedChanged: if(!pressed) mceRequestIface.typedCall('set_config', [{"type": "s", "value": powerSaveWrapper.key_threshold_value},
                                                                                            {"type": "v", "value": parseInt(value)}])
                }

                CheckBox {
                    id:forcePowerSave
                    anchors.top:powerSaveSlider.bottom
                    anchors.topMargin: Theme.itemSpacingSmall

                    property string entryPath: "system_settings/info/powersave/powersave_force"

                    checked: powerSaveWrapper.values[powerSaveWrapper.key_powersave_force]
                    onClicked: mceRequestIface.setValue(powerSaveWrapper.key_powersave_force, checked)
                    text: qsTr("Force powersave mode")
                }
            }
        }
    }
}
