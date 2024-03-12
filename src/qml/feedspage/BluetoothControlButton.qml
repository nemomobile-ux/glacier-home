/*
 * Copyright (C) 2020-2024 Chupligin Sergey <neochapay@gmail.com>
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

import QtQuick
import Nemo.Controls

import Connman
import org.kde.bluezqt as BluezQt

ControlButton {
    id: bluetoothButton

    image: "image://theme/bluetooth-b"
    activated: bluetoothModel.powered

    assignedSettingsPage: "bluez"

    property QtObject _bluetoothManager: BluezQt.Manager
    property QtObject _adapter: _bluetoothManager.usableAdapter

    TechnologyModel {
        id: bluetoothModel
        name: "bluetooth"

        onPoweredChanged: {
            bluetoothButton.activated = bluetoothModel.powered
        }
    }

    onClicked: bluetoothModel.powered = !bluetoothButton.activated;

    Connections{
        target: _bluetoothManager
        function onUsableAdapterChanged() {
            _adapter = _bluetoothManager.usableAdapter
        }
    }
}
