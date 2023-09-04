/*
 * Copyright (C) 2018-2022 Chupligin Sergey <neochapay@gmail.com>
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

import Nemo.Configuration 1.0

import Glacier.Controls.Settings 1.0

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

    ConfigurationValue {
        id: infinityPager
        key: "/home/glacier/homeScreen/infinityPager"
        defaultValue: false
    }

    ConfigurationValue {
        id: windowAnimation
        key: "/home/glacier/homeScreen/windowAnimation"
        defaultValue: true
    }

    SettingsColumn{
        id: windowedModeSettings
        spacing: Theme.itemSpacingLarge


        RightCheckBox{
            id: windowedModeCheck
            checked: windowedMode.value
            onClicked: windowedMode.value = checked
            label: qsTr("Enable windowed mode");
        }

        RightCheckBox{
            id: alwaysShowSearchCheck
            checked: alwaysShowSearch.value
            onClicked: alwaysShowSearch.value = checked
            label: qsTr("Always show search panel");
        }

        RightCheckBox{
            id: infinityPagerCheck
            checked: infinityPager.value
            onClicked: infinityPager.value = checked
            label: qsTr("Infinite scrolling main screen");
        }

        RightCheckBox{
            id: windowAnimationCheck
            checked: windowAnimation.value
            onClicked: windowAnimation.value = checked
            label: qsTr("Window animation");
        }

    }
}

