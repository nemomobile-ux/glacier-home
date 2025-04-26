/****************************************************************************************
**
** Copyright (c) 2017, Eetu Kahelin
** Copyright (c) 2018-2025, Chupligin Sergey
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
import Nemo
import Nemo.Controls
import Nemo.DBus

import org.nemomobile.lipstick
import org.nemomobile.glacier

Item {
    id:searchList
    height: calculateHeight()
    anchors.bottomMargin:Theme.itemSpacingHuge
    property alias searchField: searchField
    property alias searchString: searchField.text
    property int oldHeight

    GlacierSearchModel{
        id: searchModel
    }

    DBusInterface{
        id: callingIface
        bus: DBus.SessionBus
    }

    function cleanup(){
        searchField.focus = false
        appLauncher.searchString = ""
        searchField.text = ""

        if(alwaysShowSearch.value == false)
        {
            searchListView.visible = false;
            searchListView.height = 0
        }
    }

    function calculateHeight()
    {
        console.log("calculateHeight")
        if(searchList.visible){
            if(searchField.text.length > 0){
                return  parent.height
            }
            return searchRow.height+Theme.itemSpacingMedium
        }
        else
        {
            return 0;
        }
    }

    onVisibleChanged: {
        if(visible){
            searchList.height = calculateHeight()
            searchField.focus = true
            searchField.forceActiveFocus()
        } else {
            cleanup()
        }
        oldHeight=height
    }

    Row {
        id:searchRow
        spacing: Theme.itemSpacingMedium
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Theme.itemSpacingMedium
            leftMargin: Theme.itemSpacingMedium
            rightMargin: Theme.itemSpacingMedium
            bottomMargin:Theme.itemSpacingMedium
        }

        Image {
            id:searchIcon
            anchors.verticalCenter: parent.verticalCenter
            width:height
            height: searchField.height
            fillMode: Image.PreserveAspectFit
            source: "image://theme/search"

            MouseArea{
                id: hideShowMouseArea
                anchors.fill: parent
                onPressAndHold: {
                    hideShowRow.visible = true
                    searchList.height = searchList.height+hideShowRow.height
                }
            }
        }

        TextField {
            id:searchField
            width:parent.width - searchIcon.width - Theme.itemSpacingMedium
            placeholderText: qsTr("Search")

            onTextChanged: {
                if(searchField.text.length > 0) {
                    searchField.forceActiveFocus()
                    searchModel.search(searchField.text)
                }
            }

            placeholderTextColor: Theme.textColor
        }
    }

    Row{
        id: hideShowRow
        visible: false
        width: parent.width-Theme.itemSpacingMedium*2
        height: visible ? hideShowButton.height+Theme.itemSpacingMedium : 0
        anchors{
            top: searchRow.bottom
            topMargin: visible ? Theme.itemSpacingMedium : 0
        }

        Button{
            id: hideShowButton
            text: alwaysShowSearch.value == true ? qsTr("Hide search panel") : qsTr("Pinup search panel")
            width: parent.width
            onClicked: {
                searchList.height = searchList.height-hideShowRow.height
                hideShowRow.visible = false
                if(alwaysShowSearch.value == true)
                {
                    alwaysShowSearch.value = false
                }
                else
                {
                    alwaysShowSearch.value = true
                }
            }
        }

        InverseMouseArea {
            anchors.fill: parent
            onPressed: {
                searchList.height = searchList.height-hideShowRow.height
                hideShowRow.visible = false
            }
        }
    }

    ListView {
        id: searchResultListView
        clip: true
        width: parent.width
        height:contentHeight
        anchors{
            top: searchRow.bottom
            topMargin: searchModel.count > 0 ? Theme.itemSpacingSmall : 0
        }
        visible: searchModel.count > 0
        section.property: 'category'
        section.delegate: Component{
            id: sectionHeading
            Rectangle {
                width: searchResultListView.width
                height: Theme.itemHeightMedium
                color: "transparent"

                Text {
                    id: sectionText
                    text: section
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textColor
                    anchors{
                        left: parent.left
                        leftMargin: Theme.itemSpacingSmall
                        verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle{
                    id: line
                    height: 1
                    color: Theme.textColor
                    width: searchResultListView.width-sectionText.width-Theme.itemHeightExtraSmall
                    anchors{
                        left: sectionText.right
                        leftMargin: Theme.itemSpacingSmall
                        verticalCenter: sectionText.verticalCenter
                    }
                }
            }
        }

        Behavior on height {
            NumberAnimation{ duration: 300 }
        }

        Connections {
            target: appLauncher
            function onSearchStringChanged() { searchResultListView.update() }
        }


        model: searchModel

        delegate: Item {
            width: searchResultListView.width
            height:Theme.itemHeightExtraLarge*1.2
            Rectangle {
                anchors.fill: parent
                color: "#11ffffff"
                visible: mouse.pressed
            }
            Image {
                id: iconImage
                width: parent.height-Theme.itemSpacingMedium
                height: width
                source:iconSource
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.itemSpacingLarge
                onStatusChanged: {
                    if (iconImage.status == Image.Error) {
                        iconImage.source = "/usr/share/glacier-home/qml/theme/default-icon.png"
                    }
                }
            }
            Spinner {
                id: spinner
                anchors {
                    centerIn:  iconImage
                }
                width: height
                height: parent.height - Theme.itemSpacingHuge
                enabled: false

                Connections {
                    target: Lipstick.compositor
                    function onWindowAdded(window) {
                        if(window.category=="" && window.title !== "Home"){
                            spinner.stop()
                        }
                    }
                }
            }
            Item {
                id: labelWrapper
                anchors {
                    left: iconImage.right
                    leftMargin: Theme.itemSpacingLarge
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: Theme.itemSpacingLarge
                }
                height: labelWrapper.childrenRect.height
                Label {
                    id:mainLabel
                    text:iconTitle
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font.pixelSize:Theme.fontSizeMedium
                    color:Theme.textColor
                    elide:Text.ElideRight
                    verticalAlignment:Text.AlignVCenter
                }
                Label {
                    id:extraLabel
                    text: extraCaption ? extraCaption : category === "Application" ? qsTr("Open" + " " + iconCaption) : ""
                    anchors {
                        top:mainLabel.bottom
                        left:mainLabel.left
                    }
                    font.pixelSize:Theme.fontSizeTiny
                    color:Theme.textColor
                    elide:Text.ElideRight
                    verticalAlignment:Text.AlignVCenter
                }
            }
            MouseArea {
                id:mouse
                anchors.fill: parent
                onClicked: if(action.type == "exec") {
                               var winId = switcher.switchModel.getWindowIdForTitle(iconTitle)
                               if (winId == 0 && !launcherModel.get(action.app_id).isLaunching) {
                                   launcherModel.get(action.app_id).launchApplication()
                               } else {
                                   Lipstick.compositor.windowToFront(winId)
                               }
                           } else if (action.type == "dbus") {
                               callingIface.service = action.dbus_service
                               callingIface.path = action.dbus_path
                               callingIface.iface = action.dbus_iface

                               callingIface.call(action.dbus_call, action.dbus_params)
                           } else {
                               console.warn("Wrong action type:"+action.type)
                           }
            }
        }
    }
}
