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
import org.nemomobile.gallery 1.0

import "../../components"

Page {
    id: wallpaperSelectPage

    headerTools: HeaderToolsLayout { showBackButton: true; title: qsTr("Select wallpaper")}

    property string valueKey: ""

    ConfigurationValue {
        id: wallpaper
        key: wallpaperSelectPage.valueKey
    }

    GalleryView {
        anchors{
            fill: parent
            topMargin: Theme.itemSpacingLarge
        }
        baseThumbnailSize: (parent.height>parent.width) ? parent.width/4 : parent.height/4
        model: GalleryModel {
            id: gallery
        }

        delegate: GalleryDelegate {
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    wallpaper.value = url
                    pageStack.pop();
                }
            }
        }
    }

    Component.onCompleted: {
        gallery.createFilter(gallery, "imagesfilter", "GalleryStartsWithFilter", "mimeType", "image/")
    }
}
