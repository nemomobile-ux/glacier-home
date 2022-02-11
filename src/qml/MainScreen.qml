/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2020-2022 Chupligin Sergey <neochapay@gmail.com>
** Copyright (C) 2020 Eetu Kahelin
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
import QtQuick.Window 2.1

import Nemo.Time 1.0
import Nemo.Configuration 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import org.nemomobile.statusnotifier 1.0

import org.nemomobile.systemsettings 1.0

import Nemo.DBus 2.0

import org.nemomobile.glacier 1.0

import "mainscreen"
import "dialogs"
import "volumecontrol"
import "system"

Page {
    id: desktop
    focus: true

    // This is used in the favorites page and in the lock screen
    WallClock {
        id: wallClock
        enabled: true
        updateFrequency: WallClock.Minute
    }

    GlacierMceConnect{
        id: mceConnect

        onPowerKeyPressed: {
            if(!rebootDialog.visible) {
                rebootDialog.visible = true
            } else {
                rebootDialog.visible = false
            }
        }
    }

    GlacierGeoAgent{
        id: geoAgent
    }

    DBusAdaptor {
        id: btDbusAdapter
        service: "org.nemomobile.lipstick"
        path: "/org/nemomobile/lipstick/bluetoothagent"
        iface: "org.nemomobile.lipstick"

        signal pair(string address)
        signal unPair(string address)

        signal connectDevice(string address)

        signal replyToAgentRequest(int requestId, int error, string passkey)

        onPair: bluetoothAgent.pair(address)
        onUnPair: bluetoothAgent.unPair(address)
        onConnectDevice: bluetoothAgent.connectDevice(address)
    }

    //force refresh
    Connections {
        target: Lipstick.compositor
        function onDisplayAboutToBeOn() {
            wallClock.enabled = false
            wallClock.enabled = true
        }
    }

    //USB mode selector connections
    Connections{
        target: usbModeSelector
        function onWindowVisibleChanged() {
            if(usbModeSelector.windowVisible) {
                usbModedDialog.visible = true
            } else {
                usbModedDialog.visible = false
            }
        }
    }

    StatusNotifierModel {
        id: statusNotiferModel
    }

    /*Bluetooth section */
    Connections{
        target: bluetoothAgent

        function onShowRequiesDialog(btMacAddres, name, code) {
            btRequestConfirmationDialog.deviceCode = code
            btRequestConfirmationDialog.deviceName = name
            btRequestConfirmationDialog.mac = btMacAddres
            btRequestConfirmationDialog.open();
        }
    }

    Connections{
        target: bluetoothObexAgent

        function onShowRequiesDialog(deviceName, fileName) {
            btObexRequestConfirmationDialog.deviceName = deviceName
            btObexRequestConfirmationDialog.fileName = fileName
            btObexRequestConfirmationDialog.open()
        }

        function onTransferError() {
            btObexRequestConfirmationDialog.close()
        }

        function transferFinished(resultPath) {
            btObexRequestConfirmationDialog.close()
        }
    }

    BtRequestConfirmationDialog{
        id: btRequestConfirmationDialog
    }

    BtObexRequestConfirmationDialog{
        id: btObexRequestConfirmationDialog
    }

    UsbModeDialog{
        id: usbModedDialog
    }

    property alias lockscreen: lockScreen
    property alias switcher: switcher
    property alias statusbar: statusbar

    readonly property int isUiPortrait: orientation == Qt.PortraitOrientation || orientation == Qt.InvertedPortraitOrientation

    property alias displayOn: lockScreen.displayOn
    property bool deviceLocked: DeviceLock.state >= DeviceLock.Locked

    // Implements back key navigation

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            if (pageStack.depth > 1) {
                pageStack.pop();
                event.accepted = true;
            }
        }
    }

    //Todo: Property to set statusbar on top or bottom
    //Also todo: Make this a window?
    Statusbar {
        id: statusbar
        enabled: DeviceLock.state !== DeviceLock.Locked
        opacity: (Lipstick.compositor.topmostWindow == Lipstick.compositor.homeWindow) ? 1.0 : (
            Lipstick.compositor.gestureArea.active ? 
            Lipstick.compositor.gestureArea.progress / (Math.min(Screen.width, Screen.height)) : 0.0)
        NumberAnimation {
            properties: "opacity"
            duration: 200
        }
        z: 201
    }

    GlacierRotation {
        id: glacierRotation
        rotationParent: desktop.parent
    }

    orientation: Lipstick.compositor.screenOrientation

    onOrientationChanged: {
        glacierRotation.rotateRotationParent(orientation)
    }

    onParentChanged: {
        glacierRotation.rotationParent = desktop.parent
        glacierRotation.rotateRotationParent(nativeOrientation)
        glacierRotation.rotateObject(desktop.parent, nativeOrientation, true)
    }

    Component.onCompleted: {
        glacierRotation.rotationParent = desktop.parent
        setLockScreen(true)
        Lipstick.compositor.screenOrientation = nativeOrientation
        LipstickSettings.lockScreen(true)
    }

    Connections {
        target: LipstickSettings
        function onLockscreenVisibleChanged(visible) {
            glacierRotation.rotateRotationParent(desktop.orientation)
        }
    }

    function lockscreenVisible() {
        return LipstickSettings.lockscreenVisible === true
    }

    function setLockScreen(enabled) {
        if (enabled) {
            LipstickSettings.lockScreen(true)
        } else {
            LipstickSettings.lockscreenVisible = false
        }
    }

    ListView {
        id: pager
        anchors.topMargin: statusbar.height
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        boundsBehavior: Flickable.StopAtBounds
        opacity: (Lipstick.compositor.topmostWindow == Lipstick.compositor.homeWindow) ? 1.0 : (
            Lipstick.compositor.gestureArea.active ? 
            Lipstick.compositor.gestureArea.progress / (Math.min(Screen.width, Screen.height)) : 0.0)
        NumberAnimation {
            properties: "opacity"
            duration: 200
        }

        model: VisualItemModel {
            FeedsPage {
                id: feeds
                width: pager.width
                height: pager.height
            }
            AppLauncher {
                id: launcher
                width: pager.width
                height: pager.height
                switcher: switcher
            }
            AppSwitcher {
                id: switcher
                width: pager.width
                height: pager.height
                visibleInHome: x > -width && x < desktop.width
                launcher: launcher
                wallpaper: wallpaper
            }
        }

        // Initial view should be the AppLauncher
        currentIndex: 1
    }

    Wallpaper{
        id: wallpaper
        anchors.fill: parent

        z: -100
    }

    Rectangle {
        color: Theme.backgroundColor
        opacity:  Lipstick.compositor.gestureArea.active ? 0.5 * (1.0 - Lipstick.compositor.gestureArea.progress / (Math.min(Screen.width, Screen.height))) : 0.5
        visible: Lipstick.compositor.topmostWindow !== Lipstick.compositor.homeWindow
        z: 101
        anchors.fill: wallpaper
        NumberAnimation {
            properties: "opacity"
            duration: 200
        }
    }

    Lockscreen {
        id: lockScreen
        visible: lockscreenVisible()

        onVisibleChanged: {
            if(visible) {
                statusbar.opacityStart = 0.0
            }
        }

        width: parent.width
        height: parent.height
        z: 200
    }

    AudioWarningDialog{
        id: audioWarnigDialog
    }

    RebootDialog{
        id: rebootDialog
        focus: true
        z: 400
    }

    Connections {
        target: pager
        function onContentXChanged() {
            var opacityCalc

            if(pager.contentX > desktop.width) {
                opacityCalc = 0
            } else if (pager.contentX <= 0) {
                opacityCalc = 1
            } else {
                opacityCalc = (desktop.width-pager.contentX)/desktop.width
            }

            statusbar.opacityStart = opacityCalc
        }
    }

    Connections {
        target: volumeControl
        function onShowAudioWarning() {
            audioWarnigDialog.open();
        }
    }

    Connections {
        target: Lipstick.compositor
        function onWindowRemoved(window) {
            desktop.focus = true
            switcher.switchModel.removeWindowForTitle(window.title)
        }
        function onDisplayOff() {
            desktop.displayOn = false;
        }
        function onDisplayOn() {
            desktop.displayOn = true;
        }
    }
}
