/****************************************************************************************
**
** Copyright (C) 2019 Chupligin Sergey <neochapay@gmail.com>
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
import QtQuick.Controls 1.0 //needed for the Stack attached property
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import Nemo.Dialogs 1.0


SelectionDialog{
    id: selectionDialog
    visible: false

    property var inModel

    ListModel{
        id: exModel
    }

    cancelText: qsTr("Cancel")
    acceptText: qsTr("Ok")
    headingText: qsTr("Select USB mode")

    model: exModel

    onInModelChanged: {
        for(var i=0; i <= inModel.length; i++) {
            exModel.append({
                               "name": formatMode(inModel[i]),
                               "mode": inModel[i]
                           })
        }
    }

    function formatMode(mode) {
        switch(mode) {
        case "ask":
            return qsTr("Always ask")
        case "mtp_mode":
            return qsTr("MTP")
        case "charging_only":
            return qsTr("Chagring only")
        case "connection_sharing":
            return qsTr("Connection sharing")
        case "developer_mode":
            return qsTr("Developer mode")
        case "busy":
            return qsTr("Busy")
        default:
            return mode
        }
    }
}
