/****************************************************************************************
**
** Copyright (C) 2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
** Copyright (C) 2020-2024 Chupligin Sergey <neochapay@gmail.com>
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

import QtQuick
import QtQml.Models
import Nemo
import Nemo.Controls
import Nemo.Time
import Nemo.Configuration
import Nemo.DBus
import org.nemomobile.lipstick
import org.nemomobile.devicelock
import org.nemomobile.statusnotifier
import org.nemomobile.systemsettings
import org.nemomobile.glacier

import "mainscreen"
import "dialogs"
import "volumecontrol"
import "system"

Item {
    id: desktop
    focus: true
    anchors.fill: parent

    ConfigurationValue {
        id: infinityPager
        key: "/home/glacier/homeScreen/infinityPager"
        defaultValue: false
    }

    // This is used in the favorites page and in the lock screen
    WallClock {
        id: wallClock
        enabled: true
        updateFrequency: WallClock.Minute
    }

    Loader{
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

    //USB mode selector connections
    Connections{
        target: usbModeSelector
        function onWindowVisibleChanged() {
            if(usbModeSelector.windowVisible) {
                usbModedDialog.mustBeShowed = true
            } else {
                usbModedDialog.mustBeShowed = false
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

    readonly property int isUiPortrait: Lipstick.compositor.screenOrientation == Qt.PortraitOrientation || Lipstick.compositor.screenOrientation == Qt.InvertedPortraitOrientation

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

    onParentChanged: {
        glacierRotation.rotationParent = desktop.parent
        glacierRotation.rotateRotationParent(orientationCalc())
        glacierRotation.rotateObject(desktop.parent, orientationCalc(), true)
    }

    Component.onCompleted: {
        glacierRotation.rotationParent = desktop.parent
        setLockScreen(true)
        Lipstick.compositor.screenOrientation = orientationCalc()
        LipstickSettings.lockScreen(true)

        if(usegeoclue2) {
            geoAgent.source = "system/GeoClue2Agent.qml"
        }
    }

    Connections {
        target: LipstickSettings
        function onLockscreenVisibleChanged(visible) {
            glacierRotation.rotateRotationParent(orientationCalc())
        }
    }

    function setLockScreen(enabled) {
        if (enabled) {
            LipstickSettings.lockScreen(true)
        } else {
            LipstickSettings.lockscreenVisible = false
        }
    }

    ObjectModel {
        id: visualItemsModel

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


    Component{
        id: infinityPagerView
        Pager {
            id: pager
            anchors.fill: parent
            enabled: Lipstick.compositor.state != "controlCenter"
            model: visualItemsModel
            // Initial view should be the AppLauncher
            currentIndex: 1

            Connections {
                target: pager
                function onOffsetChanged() {
                    var opacityCalc = 0

                    if (offset >= 0 && offset <= 1) {
                        opacityCalc = 1 - offset
                    } else if (offset >= 2 && offset <= 3) {
                        opacityCalc = offset - 2
                    }

                    statusbar.opacityStart = opacityCalc
                }

            }
        }
    }

    Component {
        id: listPagerView

        ListView {
            id: pager
            anchors.fill: parent
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            boundsBehavior: Flickable.StopAtBounds

            model: visualItemsModel

            // Initial view should be the AppLauncher
            currentIndex: 1

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

        }
    }

    Loader{
        id: pager
        anchors.topMargin: statusbar.height
        anchors.fill: parent
        sourceComponent: infinityPager.value ? infinityPagerView : listPagerView
    }

    Wallpaper{
        id: wallpaper
        anchors.fill: parent

        z: -100
    }

    Lockscreen {
        id: lockScreen
        visible: LipstickSettings.lockscreenVisible

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
        function onDisplayAboutToBeOn() {
            wallClock.enabled = false
            wallClock.enabled = true
        }
        function onScreenOrientationChanged(){
            glacierRotation.rotateRotationParent(Lipstick.compositor.screenOrientation)
        }
    }

    function orientationCalc() {
        if (Lipstick.compositor.orientationLock == "portrait") {
            return Qt.PortraitOrientation
        } else if (Lipstick.compositor.orientationLock == "landscape") {
            return Qt.LandscapeOrientation
        }
        return nativeOrientation
    }
}
