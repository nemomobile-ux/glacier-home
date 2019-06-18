/****************************************************************************************
**
** Copyright (C) 2019 Sergey Chupligin <neochapay@gmail.com>
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
import QtQuick.Layouts 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.freedesktop.contextkit 1.0

StatusbarItem{
    id: dataStatus
    iconSize: statusbar.height
    visible: cellularDataTechnology.value != "unknown"

    property alias cellularDataTechnology: cellularDataTechnology

    Component.onCompleted: {
        formatValue()
    }

    ContextProperty {
        id: cellularDataTechnology
        key: "Cellular.DataTechnology"
        onValueChanged: {
            dataStatus.formatValue()
        }
    }

   function formatValue() {
       if(cellularDataTechnology.value == "2") {
           dataStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_gprs.png"
       }else if(cellularDataTechnology.value == "2.5" || cellularDataTechnology.value == "gprs") {
           dataStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_egprs.png"
       }else if(cellularDataTechnology.value == "3" || cellularDataTechnology.value == "umts") {
           dataStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_utms.png"
       }else if(cellularDataTechnology.value == "3.5" || cellularDataTechnology.value == "hspa") {
           dataStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_hspa.png"
       }else if(cellularDataTechnology.value == "4" || cellularDataTechnology.value == "lte") {
           dataStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_lte.png"
       }else {
           dataStatus.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/data_unknown.png"
       }
   }
}
