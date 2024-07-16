/****************************************************************************************
**
** Copyright (C) 2020-2024 Chupligin Sergey <neochapay@gmail.com>
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
import QtQuick.Window

import org.nemomobile.lipstick
import org.nemomobile.devicelock
import Nemo.Configuration

Item {
    id: wallpaper

    property double maxX: desktop.width*0.1
    property double maxY: desktop.height*0.1

    ConfigurationValue {
        id: wallpaperSource
        key: "/home/glacier/homeScreen/wallpaperImage"
        defaultValue: "/usr/share/glacier-home/qml/images/wallpaper-portrait-bubbles.png"
    }

    Image {
        id:wallpaperImage
        width: wallpaper.width+maxX*4
        height: wallpaper.height+maxY*4

        x: -maxX
        y: -maxY

        source: wallpaperSource.value
        fillMode: Image.PreserveAspectCrop

        Behavior on x {
            NumberAnimation { duration: 200 }
        }

        Behavior on y {
            NumberAnimation { duration: 200 }
        }
    }

    //TODO: fix this QtGraphicalEffects removed from Qt6
    /*FastBlur {
        anchors.fill: wallpaperImage
        source: wallpaperImage
        radius: 100
        opacity: Lipstick.compositor.gestureArea.active ? 1.0 - Lipstick.compositor.gestureArea.progress / (Math.min(Screen.width, Screen.height)) : 1.0
        visible: Lipstick.compositor.topmostWindow !== Lipstick.compositor.homeWindow
        NumberAnimation {
            properties: "opacity"
            duration: 200
        }
    }*/
}
