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
import Nemo.DBus
import Nemo.Ngf

import org.nemomobile.systemsettings

StatusbarItem {
    id: nfcIndicator
    iconSize:       parent.height * 0.671875
    iconSizeHeight: parent.height
    source: "/usr/share/lipstick-glacier-home-qt6/qml/theme/icon_nfc.png"
    visible: nfcSettings.enabled

    NfcSettings{
        id: nfcSettings
    }

    NonGraphicalFeedback {
        id: getNfc
        event: "nfc_touch"
    }

    DBusInterface {
        bus: DBus.SystemBus
        service: 'org.sailfishos.nfc.daemon'
        path: '/nfc0'
        iface: 'org.sailfishos.nfc.Adapter'
        signalsEnabled: true

        function tagsChanged(tagPath) {
            if(tagPath != "") {
                getNfc.play()
            }
        }
    }
}
