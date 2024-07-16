/****************************************************************************************
**
** Copyright (C) 2019-2024 Sergey Chupligin <neochapay@gmail.com>
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
import Nemo.Controls

import Connman
import QOfono

StatusbarItem{
    id: dataStatus
    iconSize: statusbarRight.height
    visible: false
    transparent: !cellularNetworkTechnology.connected
    source: "/usr/share/glacier-home/qml/theme/data_unknown.png"

    OfonoManager {
        id: manager
    }

    OfonoNetworkRegistration{
        id: cellularDataTechnology
        modemPath: manager.defaultModem
        onTechnologyChanged: {
            formatValue()
        }
    }

    NetworkTechnology {
        id: cellularNetworkTechnology
        path: "/net/connman/technology/cellular"
    }

    Component.onCompleted: {
        formatValue()
    }

    function formatValue() {
        if(cellularDataTechnology.technology == "2" || cellularDataTechnology.technology == "gsm") {
            dataStatus.source = "/usr/share/glacier-home/qml/theme/data_gprs.png"
        }else if(cellularDataTechnology.technology == "2.5" || cellularDataTechnology.technology == "gprs") {
            dataStatus.source = "/usr/share/glacier-home/qml/theme/data_egprs.png"
        }else if(cellularDataTechnology.technology == "3" || cellularDataTechnology.technology == "umts") {
            dataStatus.source = "/usr/share/glacier-home/qml/theme/data_utms.png"
        }else if(cellularDataTechnology.technology == "3.5" || cellularDataTechnology.technology == "hspa") {
            dataStatus.source = "/usr/share/glacier-home/qml/theme/data_hspa.png"
        }else if(cellularDataTechnology.technology == "4" || cellularDataTechnology.technology == "lte") {
            dataStatus.source = "/usr/share/glacier-home/qml/theme/data_lte.png"
        }

        if(cellularDataTechnology.technology == "unknown" || cellularDataTechnology.technology == "") {
            dataStatus.visible = false
        }else {
            dataStatus.visible = true
        }
    }
}
