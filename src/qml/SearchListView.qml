/****************************************************************************************
**
** Copyright (c) 2017, Eetu Kahelin
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
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Item {
    height: (searchField.text.length > 0 ?  listView.height+searchField.height : searchField.height) + (visible ? Theme.itemSpacingHuge + margin.height : 0)
    visible: false
    anchors.bottomMargin:Theme.itemSpacingHuge
    property alias searchField: searchField
    property int oldHeight

    Behavior on height {
        enabled:!visible
        NumberAnimation{ duration: 300 }
    }


    onVisibleChanged: {
        if( visible) searchField.focus = true
        else searchField.focus = false
        oldHeight=height
    }

    Item {
        id:margin
        height: Theme.itemSpacingSmall
    }

    TextField {
        id:searchField
        anchors {
            top:margin.bottom
            left: parent.left
            right: parent.right
            topMargin: Theme.itemSpacingHuge
            leftMargin: Theme.itemSpacingMedium
            rightMargin: Theme.itemSpacingMedium
            bottomMargin:Theme.itemSpacingHuge
        }
        Binding {
            target: gridview
            property: "searchString"
            value: searchField.text.toLowerCase().trim()
        }


    }
    ListView {
        id:listView
        clip: true
        width: parent.width
        height:contentHeight
        anchors.top: searchField.bottom
        anchors.topMargin: Theme.itemSpacingSmall
        visible: searchString.length>0
        section.property: 'category'

        Behavior on height {
            NumberAnimation{ duration: 300 }
        }

        Connections {
            target: gridview
            onSearchStringChanged: listView.update()
        }


        model: ListModel {
            id: listModel
        }

        LauncherFolderModel { id: searchLauncherModel }

        function update() {
            if(searchString.length<1) {
                listModel.clear()
            } else {
                var iconTitle
                var iconId
                var found
                var i

                var titles = []
                for (i = 0; i < searchLauncherModel.itemCount; ++i) {
                    titles.push({'iconTitle':searchLauncherModel.get(i).title, 'iconSource':searchLauncherModel.get(i).iconId, 'id':i, 'category':qsTr("Application")})
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
                    var category = filteredTitles[i].category
                    found = existingTitleObject.hasOwnProperty(iconTitle)
                    if (!found) {
                        // for simplicity, just adding to end instead of corresponding position in original list
                        console.log(iconTitle)
                        listModel.append({'title':iconTitle, 'iconSource':iconId, 'id':id, 'category':category})
                    }
                }
            }
        }

        delegate: Item {
            property string iconCaption: model.title
            property string iconSource: model.iconSource== "" ? "/usr/share/lipstick-glacier-home-qt5/qml/theme/default-icon.png" : ( model.iconSource.indexOf("/") == 0 ? "file://" : "image://theme/") + model.iconSource
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
            }
            Spinner {
                id: spinner
                anchors {
                    centerIn:  iconImage
                    top: iconImage.top
                    topMargin: Theme.itemSpacingExtraSmall
                }
                width: iconImage.width
                height: width
                enabled: (searchLauncherModel.get(model.id).type === LauncherModel.Application) ? searchLauncherModel.get(model.id).isLaunching ? switcher.switchModel.getWindowIdForTitle(model.title) == 0 : false : false

                Connections {
                    target: Lipstick.compositor
                    onWindowAdded: {
                        if(window.category=="" && window.title !== "Home"){
                            spinner.stop()
                        }
                    }
                }
            }
            Label {
                text:iconCaption
                anchors.left: iconImage.right
                anchors.leftMargin: Theme.itemSpacingLarge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: Theme.itemSpacingLarge
                font.pixelSize:Theme.fontSizeLarge
                height:parent.height
                color:Theme.textColor
                elide:Text.ElideRight
                horizontalAlignment:Text.AlignHCenter
                verticalAlignment:Text.AlignVCenter
            }
            width: parent.width
            height:Theme.itemHeightExtraLarge*1.2
            MouseArea {
                id:mouse
                anchors.fill: parent
                onClicked: {
                    if (searchLauncherModel.get(model.id).type !== LauncherModel.Folder) {
                        var winId = switcher.switchModel.getWindowIdForTitle(model.title)
                        if (winId == 0 || !searchLauncherModel.get(model.id).isLaunching)
                            searchLauncherModel.get(model.id).launchApplication()
                        else
                            Lipstick.compositor.windowToFront(winId)
                    }
                }
            }
        }
    }

}
