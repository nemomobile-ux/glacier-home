/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2017 Sergey Chupligin <mail@neochapay.ru>
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
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import org.nemomobile.lipstick 0.1

Rectangle {
    id: commonPanel

    property alias switcherEnabled: columnCheckBox.enabled
    property bool settingsIconEnabled: true

    property alias switcherChecked: columnCheckBox.checked
    property string name: ""
    signal click
    onClick: {
        panel_loader.sourceComponent = parent.panel
        panel_loader.visible = !panel_loader.visible
        row.currentChild._reopenTimer.start()
        row.currentChild=null
    }

    height: Theme.itemWidthMedium
    width: root.width
    color: "transparent"

    Rectangle{
        anchors.fill: parent
        color: Theme.fillDarkColor
        opacity: 0.3

    }

    InverseMouseArea {
        anchors.fill: parent
        enabled: parent.visible
        parent:commonPanel
        onPressed: {
            parent.click()
        }
    }

    clip: true

    default property alias contentItem: dataColumn.children

    Column{
        id: actionColumn
        anchors{
            top: commonPanel.top
            topMargin: Theme.itemSpacingLarge
        }
        height: nameLabel.height
        width: parent.width
        Label{
            id: nameLabel
            text: name
            anchors{
                left: actionColumn.left
                leftMargin: Theme.itemSpacingLarge
            }
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.textColor
        }

        CheckBox {
            id: columnCheckBox
            visible: enabled
            anchors{
                right: actionColumn.right
                rightMargin: Theme.itemSpacingLarge
                verticalCenter: nameLabel.verticalCenter
            }
        }
    }

    Column{
        id: dataColumn
        width: parent.width-settingsIcon.width
        anchors{
            left: parent.left
            leftMargin: Theme.itemSpacingLarge
            top: actionColumn.bottom
            topMargin: Theme.itemSpacingMedium
        }
    }

    Image {
        id:settingsIcon
        fillMode: Image.PreserveAspectFit
        height: Theme.itemHeightMedium
        visible: settingsIconEnabled && parent.height > Theme.itemSpacingMedium
        source: "image://theme/icon-app-settings" //maybe better icon? settings.png from statusbar spec
        anchors{
            right: parent.right
            rightMargin: Theme.itemSpacingLarge
            bottom:parent.bottom
            bottomMargin: Theme.itemSpacingLarge
        }
        MouseArea {
            anchors.fill:parent
            onClicked: console.log("open right settings page...")
        }
    }
    Connections {
        target: lockScreen
        onVisibleChanged: {
            if(lockscreenVisible()) {
               panel_loader.visible = false
            }
        }
    }
    Connections {
        target: Lipstick.compositor
        onDisplayOff: {
            panel_loader.visible = false
        }
        onWindowAdded: {
            if(window.category=="" && window.title !== "Home"){
                panel_loader.visible = false
            }
        }
        onWindowRaised: {
            if(window.category=="" && window.title !== "Home"){
               panel_loader.visible = false
            }
        }
    }
}
