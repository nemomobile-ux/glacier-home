/*
 * Copyright (C) 2018-2023 Chupligin Sergey <neochapay@gmail.com>
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

Item {
    id: contolButton
    property alias image: icon.source

    property bool activated: false
    property bool connected: false

//propertys for settings application
    property string assignedSettingsPage: ""
    property string assignedSettingsPageParams: ""

    signal clicked();
    signal pressed();

    width: Theme.itemHeightExtraLarge
    height: Theme.itemHeightExtraLarge

    Rectangle{
        id: button
        width: contolButton.width
        height: contolButton.height

        radius: parent.height*0.5

        color: activated ? Theme.accentColor : Theme.textColor

        NemoIcon {
            id: icon
            anchors.centerIn: parent

            width: parent.width*0.6
            height: parent.height*0.6

            sourceSize.width: size.dp(86)
            sourceSize.height: size.dp(86)

            color: activated ? Theme.textColor : Theme.fillColor
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            contolButton.clicked()
        }

        onPressAndHold: {
            contolButton.pressed()

//if we have assignet settings page close controlCenter
//and show settings application
            if(assignedSettingsPage != "") {
                controlCenterArea.openSettingsPage(assignedSettingsPage,assignedSettingsPageParams)
            }
        }
    }
}

