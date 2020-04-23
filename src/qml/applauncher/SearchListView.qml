/****************************************************************************************
**
** Copyright (c) 2017, Eetu Kahelin
** Copyright (c) 2018, Chupligin Sergey
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
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.contacts 1.0

Item {
    id:rootItem
    height: calculateHeight()
    anchors.bottomMargin:Theme.itemSpacingHuge
    property alias searchField: searchField
    property int oldHeight

    function cleanup(){
        searchField.focus = false
        appLauncher.searchString = ""
        searchField.text = ""

        if(!alwaysShowSearch.value)
        {
            searchListView.visible = false;
        }
    }

    function calculateHeight()
    {
        if(rootItem.visible){
            if(searchField.text.length > 0){
               return  parent.height
            }
            return searchRow.height+Theme.itemSpacingHuge
        }
        else
        {
            return 0;
        }
    }

    onVisibleChanged: {
        if(!alwaysShowSearch.value)
        {
            if(visible){
                rootItem.height = calculateHeight()
                searchField.focus = true
                searchField.forceActiveFocus()
            } else {
                searchField.focus = false
            }
            oldHeight=height
        }
    }

    Row {
        id:searchRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Theme.itemSpacingHuge
            leftMargin: Theme.itemSpacingMedium
            rightMargin: Theme.itemSpacingMedium
            bottomMargin:Theme.itemSpacingHuge
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
                    rootItem.height = rootItem.height+hideShowRow.height
                }
            }
        }

        TextField {
            id:searchField
            width:parent.width - searchIcon.width - Theme.itemSpacingMedium
            placeholderText: qsTr("Search")
            Binding {
                target: appLauncher
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
            onTextChanged: {
                if(text.lenght>0) {
                    searchField.forceActiveFocus()
                }
            }
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
                rootItem.height = rootItem.height-hideShowRow.height
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
                rootItem.height = rootItem.height-hideShowRow.height
                hideShowRow.visible = false
            }
        }
    }

    ListView {
        id:listView
        clip: true
        width: parent.width
        height:contentHeight
        anchors{
            top: searchRow.bottom
            topMargin: listModel.count > 0 ? Theme.itemSpacingSmall : 0
        }
        visible: searchString.length>0
        section.property: 'category'
        section.delegate: Component{
            id: sectionHeading
            Rectangle {
                width: listView.width
                height: Theme.itemHeightMedium
                color: "transparent"

                Text {
                    id: sectionText
                    text: {
                        switch (section) {
                        case 'Application':
                            return qsTr("Application")
                        case 'Contact':
                            return qsTr("Contact")
                        default:
                            return qsTr("Content")
                        }
                    }

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
                    width: listView.width-sectionText.width-Theme.itemHeightExtraSmall
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
            onSearchStringChanged: listView.update()
        }


        model: ListModel {
            id: listModel
        }

        LauncherFolderModel { id: searchLauncherModel }
        PeopleModel {
            id: peopleModel
            filterType: PeopleModel.FilterAll
            filterPattern: searchString
            requiredProperty: PeopleModel.PhoneNumberRequired
        }

        //Orginal function ** Copyright (C) 2013 Jolla Ltd. ** Contact: Joona Petrell <joona.petrell@jollamobile.com> **BSD
        //Function has been modified
        function update() {
            if(searchString.length<1) {
                listModel.clear()
            } else {
                var iconTitle
                var category
                var extraCaption
                var iconId
                var found
                var i

                var titles = []
                var contacts = []
                for (i = 0; i < searchLauncherModel.itemCount; ++i) {
                    if (searchLauncherModel.get(i).type === LauncherModel.Folder) {
                        for(var j = 0; j< searchLauncherModel.get(i).itemCount; ++j ) {
                            titles.push({
                                            'iconTitle':searchLauncherModel.get(i).get(j).title,
                                            'iconSource':searchLauncherModel.get(i).get(j).iconId,
                                            'id':i,
                                            'folderId':j,
                                            'category':qsTr("Application"),
                                            'extraCaption': qsTr("installed on your device")
                                        })
                        }
                    } else {
                        titles.push({
                                        'iconTitle':searchLauncherModel.get(i).title,
                                        'iconSource':searchLauncherModel.get(i).iconId,
                                        'id':i,
                                        'folderId':-1,
                                        'category':qsTr("Application"),
                                        'extraCaption': qsTr("installed on your device")
                                    })
                    }
                }
                for (i = 0; i < peopleModel.count; ++i) {
                    if(peopleModel.get(i).firstName && peopleModel.get(i).lastName) {
                        contacts.push({
                                          'title':(peopleModel.get(i).firstName + " " + peopleModel.get(i).lastName),
                                          'iconSource':peopleModel.get(i).avatarUrl.toString(),
                                          'extraCaption':peopleModel.get(i).phoneNumbers,
                                          'category':qsTr("Contact")
                                      })
                    }
                }
                var filteredTitles = titles.filter(function (icon) {
                    return icon.iconTitle.toLowerCase().indexOf(searchString) !== -1
                })
                // helper objects that can be quickly accessed
                var filteredTitleObject = new Object
                for (i = 0; i < filteredTitles.length; ++i) {
                    filteredTitleObject[filteredTitles[i].iconTitle] = true
                }
                var existingTitleObject = new Object
                for (i = 0; i < count; ++i) {
                    iconTitle = listModel.get(i).title
                    existingTitleObject[iconTitle] = true
                }

                // remove items no longer in filtered set
                i = 0
                while (i < count) {
                    iconTitle = listModel.get(i).title
                    found = filteredTitleObject.hasOwnProperty(iconTitle)
                    if (!found) {
                        listModel.remove(i)
                    } else {
                        i++
                    }
                }
                // add new items
                for (i = 0; i < filteredTitles.length; ++i) {
                    iconTitle = filteredTitles[i].iconTitle
                    iconId =  filteredTitles[i].iconSource
                    var id = filteredTitles[i].id
                    var folderId = filteredTitles[i].folderId
                    category = filteredTitles[i].category
                    found = existingTitleObject.hasOwnProperty(iconTitle)
                    if (!found) {
                        // for simplicity, just adding to end instead of corresponding position in original list
                        listModel.append({'title':iconTitle, 'iconSource':iconId, 'id':id, 'folderId':folderId, 'category':category, 'extraCaption': ""})
                    }
                }
                for (i = 0; i < contacts.length; ++i) {
                    iconTitle = contacts[i].title
                    iconId =  contacts[i].iconSource
                    extraCaption = contacts[i].extraCaption[0]
                    category = contacts[i].category
                    listModel.append({'title':iconTitle, 'iconSource':iconId, 'extraCaption':extraCaption, 'category':category})
                }
            }
        }

        delegate: Item {
            width: parent.width
            height:Theme.itemHeightExtraLarge*1.2
            property string iconCaption: model.title
            property string iconSource: {
                if(model.iconSource) {
                    if(model.iconSource.indexOf("file:///") == 0) {
                        return model.iconSource
                    }else {
                        if( model.iconSource.indexOf("/") == 0) {
                            return "file://" + model.iconSource
                        } else return "image://theme/" + model.iconSource
                    }
                } else return "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png"
            }

            Rectangle {
                anchors.fill: parent
                color: "#11ffffff"
                visible: mouse.pressed
            }
            Image {
                id: iconImage
                width: Math.min(Theme.iconSizeLauncher, parent.height-Theme.itemSpacingMedium)
                height: width
                source:iconSource
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.itemSpacingLarge
                onStatusChanged: {
                    if (iconImage.status == Image.Error) {
                        iconImage.source = "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png"
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
                enabled: {
                    if(searchLauncherModel.get(model.id).type === LauncherModel.Application) {
                        if(searchLauncherModel.get(model.id).isLaunching)
                            return switcher.switchModel.getWindowIdForTitle(model.title) == 0
                    } else if (searchLauncherModel.get(model.id).type === LauncherModel.Folder && model.folderId > -1) {
                        if (searchLauncherModel.get(model.id).get(model.folderId).isLaunching)
                            return switcher.switchModel.getWindowIdForTitle(model.title) == 0
                    }
                    return false
                }
                Connections {
                    target: Lipstick.compositor
                    onWindowAdded: {
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
                    text:iconCaption
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
                onClicked: {
                    switch (category ) {
                    case "Application":
                        var winId
                        if (searchLauncherModel.get(model.id).type !== LauncherModel.Folder) {
                            winId = switcher.switchModel.getWindowIdForTitle(model.title)
                            if (winId == 0 && !searchLauncherModel.get(model.id).isLaunching)
                                searchLauncherModel.get(model.id).launchApplication()
                            else
                                Lipstick.compositor.windowToFront(winId)
                        } else  if (searchLauncherModel.get(model.id).type === LauncherModel.Folder && model.folderId > -1) {
                            winId = switcher.switchModel.getWindowIdForTitle(model.title)
                            if (winId == 0 && !searchLauncherModel.get(model.id).get(model.folderId).isLaunching)
                                searchLauncherModel.get(model.id).get(model.folderId).launchApplication()
                            else
                                Lipstick.compositor.windowToFront(winId)
                        }

                        break
                    case "Contact":
                        console.log("Call to person. Or open contextmenu where sms and call")
                        break
                    }
                }
            }
        }
    }
}
