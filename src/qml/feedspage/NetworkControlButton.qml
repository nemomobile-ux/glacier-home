/*
 * Copyright (C) 2018-2024 Chupligin Sergey <neochapay@gmail.com>
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


ControlButton {
    id: networkControlButton
    property alias networkingModel: networkingModel.name

    TechnologyModel {
        id: networkingModel

        onTechnologiesChanged: {
            networkControlButton.enabled = networkingModel.powered
        }

        onPoweredChanged: {
            networkControlButton.enabled = networkingModel.powered
        }

        onConnectedChanged: {
            networkControlButton.activated = networkingModel.connected
        }
    }

    Image {
        width: parent.width*0.4
        height: width
        source: "image://theme/times"

        fillMode: Image.PreserveAspectFit

        anchors{
            top: parent.top
            topMargin: width*0.1
            left: parent.left
            leftMargin: width*0.1
        }

        visible: !networkingModel.available
    }

    enabled: networkingModel.powered
    activated: networkingModel.connected

    onClicked: {
        if(networkingModel.powered) {
            networkingModel.powered = false
        } else {
            networkingModel.powered = true
        }
    }
}
