/*
 * Copyright (C) 2018 Chupligin Sergey <neochapay@gmail.com>
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

import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.configuration 1.0

import "../../components"

Page {
    id:desktopSettingsPage

    headerTools: HeaderToolsLayout { showBackButton: true; title: qsTr("Desktop")}

    ConfigurationValue {
        id: windowedMode
        key: "/home/glacier/windowedMode"
        defaultValue: false
    }

    ConfigurationValue {
        id: alwaysShowSearch
        key: "/home/glacier/appLauncher/alwaysShowSearch"
        defaultValue: true
    }

    SettingsColumn{
        id: windowedModeSettings

        Rectangle{
            id: windowedModeColumn
            width: parent.width
            height: childrenRect.height

            color: "transparent"

            Label{
                id: windowedModeLabel
                text: qsTr("Enable windowed mode");
                anchors{
                    left: parent.left
                    top: parent.top
                }
                width: parent.width-windowedModeCheck.width
                wrapMode: Text.WordWrap
            }

            CheckBox{
                id: windowedModeCheck
                checked: windowedMode.value
                anchors{
                    right: parent.right
                    verticalCenter: differentImagesLabel.verticalCenter
                }
                onClicked: windowedMode.value = checked
            }
        }

        Rectangle{
            id: alwaysShowSearchColumn
            width: parent.width
            height: childrenRect.height

            color: "transparent"

            Label{
                id: alwaysShowSearchLabel
                text: qsTr("Always show search panel");
                anchors{
                    left: parent.left
                    top: parent.top
                }
                width: parent.width-windowedModeCheck.width
                wrapMode: Text.WordWrap
            }

            CheckBox{
                id: alwaysShowSearchCheck
                checked: alwaysShowSearch.value
                anchors{
                    right: parent.right
                    verticalCenter: alwaysShowSearchLabel.verticalCenter
                }
                onClicked: alwaysShowSearch.value = checked
            }
        }
    }
}

