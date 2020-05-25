/*
 * Copyright (C) 2018-2020 Chupligin Sergey <neochapay@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

import QtQuick 2.6
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import MeeGo.Connman 0.2


ControlButton {
    id: wifiButton

    image: "image://theme/wifi"
    textLabel: qsTr("Wi-Fi")
    assignedSettingsPage: "wifi"

    TechnologyModel {
        id: wifiNetworkingModel
        name: "wifi"

        onTechnologiesChanged: {
            wifiButton.activated = wifiNetworkingModel.powered
        }

        onPoweredChanged: {
            wifiButton.activated = wifiNetworkingModel.powered
        }
    }

    onClicked: wifiNetworkingModel.powered = !wifiButton.activated;
}
