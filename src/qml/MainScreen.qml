/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2020 Chupligin Sergey <neochapay@gmail.com>
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

import "scripts/desktop.js" as Desktop
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

    //force refresh
    Connections {
        target: Lipstick.compositor
        onDisplayAboutToBeOn: {
            wallClock.enabled = false
            wallClock.enabled = true
        }
    }

    //USB mode selector connections
    Connections{
        target: usbModeSelector
        onWindowVisibleChanged: {
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
    GlacierBluetoothAgent{
        id: btAgent

        onAdapterAdded: {
            btAgent.registerAgent()
        }

        onShowRequiesDialog: {
            btRequestConfirmationDialog.deviceCode = code
            btRequestConfirmationDialog.deviceName = name
            btRequestConfirmationDialog.open();
        }
    }

    BtRequestConfirmationDialog{
        id: btRequestConfirmationDialog
    }

    DBusAdaptor {
        id: btDbusAdapter
        service: "org.glacier.lipstick"
        path: "/bluetooth"
        iface: "org.glacier.lipstick"

        signal pair(string address)
        signal unPair(string address)

        signal connectDevice(string address)

        signal replyToAgentRequest(int requestId, int error, string passkey)

        onPair: btAgent.pair(address)
        onUnPair: btAgent.unPair(address)
        onConnectDevice: btAgent.connectDevice(address)
    }

    UsbModeDialog{
        id: usbModedDialog
    }

    property alias lockscreen: lockScreen
    property alias switcher: switcher
    property alias statusbar: statusbar

    readonly property int isUiPortrait: orientation == Qt.PortraitOrientation || orientation == Qt.InvertedPortraitOrientation

    property bool codepadVisible: false
    property alias displayOn: lockScreen.displayOn
    property bool deviceLocked: DeviceLock.state >= DeviceLock.Locked

    // Implements back key navigation

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            if (pageStack.depth > 1) {
                pageStack.pop();
                event.accepted = true;
            } else { Qt.quit(); }
        }
    }

    //Todo: Property to set statusbar on top or bottom
    //Also todo: Make this a window?
    Statusbar {
        id: statusbar
        enabled: DeviceLock.state !== DeviceLock.Locked
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
        Desktop.instance = desktop
        Desktop.compositor.mainReady();
        Lipstick.compositor.screenOrientation = nativeOrientation
        LipstickSettings.lockScreen(true)
    }

    Connections {
        target: LipstickSettings
        onLockscreenVisibleChanged: {
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

    function makeScreenshot() {
        screenshot.capture()
    }

    Pager {
        id: pager
        anchors.topMargin: statusbar.height
        anchors.fill: parent
        model: VisualItemModel {
            AppLauncher {
                id: launcher
                height: pager.height
                switcher: switcher
            }
            AppSwitcher {
                id: switcher
                width: pager.width
                height: pager.height
                visibleInHome: x > -width && x < desktop.width
                launcher: launcher
            }
            FeedsPage {
                id: feeds
                width: pager.width
                height: pager.height
            }
        }

        // Initial view should be the AppLauncher
        currentIndex: 0
    }

    Wallpaper{
        id: wallpaper
        anchors.fill: parent

        z: -100
    }

    Lockscreen {
        id: lockScreen
        visible: lockscreenVisible()

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

    Screenshot{
        id: screenshot
    }

    Connections{
        target: feeds
        onXChanged: {
            var opacityCalc
            if(feeds.x < 0){
                opacityCalc = (desktop.width+feeds.x)/desktop.width
            }else{
                opacityCalc = (desktop.width-feeds.x)/desktop.width
            }

            if(opacityCalc < 0) {
                opacityCalc = 0
            }

            if(opacityCalc > 1) {
                opacityCalc = 1
            }

            statusbar.opacityStart = opacityCalc
        }
    }

    Connections {
        target: volumeControl
        onShowAudioWarning: {
            audioWarnigDialog.open();
        }
    }
}
