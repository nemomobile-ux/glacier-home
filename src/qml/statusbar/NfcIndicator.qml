/*
 * Copyright (C) 2020 Chupligin Sergey <neochapay@gmail.com>
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
import Nemo.DBus 2.0
import Nemo.Ngf 1.0

import org.nemomobile.systemsettings 1.0

StatusbarItem {
    id: nfcIndicator
    iconSize:       parent.height * 0.671875
    iconSizeHeight: parent.height
    source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_nfc.png"
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
