// Copyright (C) 2013 Jolla Ltd.
// Copyright (C) 2013 John Brooks <john.brooks@dereferenced.net>
// Copyright (C) 2017 Aleksi Suomalainen
// Copyright (C) 2020 Eetu Kahelin
// Copyright (C) 2021-2024 Chupligin Sergey (NeoChapay) <neochapay@gmail.com>
// This file is part of Glacier Home, a nice user experience for touchscreens.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
import QtQuick
import QtQuick.Window
import Nemo

import org.nemomobile.lipstick
import org.nemomobile.devicelock
import Nemo.Configuration

import "compositor"

Item {
    id: root
    anchors.fill: parent
    property bool isShaderUsed: false
    property bool isAlarmWindow: false
    property alias wrapperMystic: mysticWrapper
    property alias applicationLayer: appLayer
    // Qt::WindowType enum has no option for an Input Method window type. This is a magic value
    // used by ubuntumirclient QPA for special clients to request input method windows from Mir.

    property int inputMethodWindowType: 2;

    ConfigurationValue {
        id: windowAnimation
        key: "/home/glacier/homeScreen/windowAnimation"
        defaultValue: true
    }

    ConfigurationValue {
        id: windowedMode
        key: "/home/glacier/windowedMode"
        defaultValue: false
    }

    Connections {
        target: comp.quickWindow
        function onActiveFocusItemChanged() {
            // Search for the layer of the focus item
            var focusedLayer = comp.activeFocusItem
            while (focusedLayer && focusedLayer.parent !== layersParent)
                focusedLayer = focusedLayer.parent

            // reparent the overlay to the found layer
            overlayLayer.parent = focusedLayer ? focusedLayer : overlayLayer.parent
        }
    }

    Connections{
        target: mceConnect
        function onRebootDialogVisibleChanged() {
            if(mceConnect.rebootDialogVisible) {
                comp.hideAllWindows()
            }
        }
    }

    Item {
        id: layersParent
        anchors.fill: parent

        Item {
            id: homeLayer
            z: comp.homeActive ? 4 : 1
            anchors.fill: parent
        }

        Item {
            id: appLayer
            z: 2

            width: parent.width
            height: parent.height
            visible: comp.appActive && !LipstickSettings.lockscreenVisible
        }

        Rectangle {
            id: resizeBorder
            color: "transparent"
            border.width: 2
            border.color: Theme.accentColor
            visible: false
            z: 3
        }

        Item {
            id: windowedLayer
            z: 4
            property Item activeWindow: null
        }

        Item {
            id: overlayLayer
            z: 5
            visible: comp.appActive
        }

        Item {
            id: notificationLayer
            z: 6
        }
        Item {
            id: alarmsLayer
            z: 3
        }
    }

    ScreenGestureArea {
        id: gestureArea
        z: 7
        anchors.fill: parent

        property real swipeThreshold: 0.15*Math.min(Screen.width, Screen.height)
        property real lockThreshold: 0.25*Math.min(Screen.width, Screen.height)
        property int lockscreenX
        property int lockscreenY
        enabled: DeviceLock.state != DeviceLock.Locked

        onPositionChanged: function(gesture){
            if (root.appActive && diagonal && gestureArea.progress >= swipeThreshold) {
                if (diagonal == "left") {
                    resizeBorder.x = mouseX
                    resizeBorder.y = mouseY
                    resizeBorder.width = width - mouseX
                    resizeBorder.height = height - mouseY
                } else {
                    resizeBorder.x = 0
                    resizeBorder.y = mouseY
                    resizeBorder.width = mouseX
                    resizeBorder.height = height - mouseY
                }
                resizeBorder.visible = true
//                console.log("performing diagonal gesture:", resizeBorder.x, resizeBorder.y, resizeBorder.width, resizeBorder.height, diagonal)
            }
            if (comp.appActive) {
                comp.topmostWindow.opacity = 1.0 - gestureArea.progress / (Math.min(Screen.width, Screen.height))
            }

            comp.lastClick = null
        }

        onGestureStarted: function(gesture) {
            swipeAnimation.stop()
            cancelAnimation.stop()
            lockAnimation.stop()
            comp.gestureOnGoing = true
            if (comp.appActive && !diagonal) {
                state = "swipe"
            }
        }

        onGestureFinished: function(gesture) {
            resizeBorder.visible = false
            if (comp.appActive) {
                if (diagonal && gestureArea.progress >= swipeThreshold) {
//                    console.log("finished diagonal gesture:", mouseX, mouseY)
                    comp.topmostWindow.window.userData.x = resizeBorder.x
                    comp.topmostWindow.window.userData.y = resizeBorder.y
                    comp.topmostWindow.window.resize(Qt.size(resizeBorder.width, resizeBorder.height))
                    comp.topmostWindow.parent = windowedLayer
                    comp.topmostWindow = comp.homeWindow
                    comp.topmostApplicationWindow = null
                    comp.clearKeyboardFocus()
                } else if (gestureArea.progress >= swipeThreshold) {
                    swipeAnimation.valueTo = inverted ? -max : max
                    swipeAnimation.start()
                    if (gesture == "up") {
                        Lipstick.compositor.closeClientForWindowId(comp.topmostWindow.window.windowId)
                    }
                } else {
                    comp.topmostWindow.opacity = 1.0
                    cancelAnimation.start()
                }
            } else if (comp.homeActive){
                if (gestureArea.progress >= lockThreshold) {

                    lockAnimation.start()

                    if (gesture == "down") {
                        // swipe down on lockscreen to turn off display
                        if (LipstickSettings.lockscreenVisible === true) {
                            LipstickSettings.lockScreen(true)
                            comp.setDisplayOff()
                        }
                    }
                    // Unlocks if no security code required
                    else if (DeviceLock.state !== DeviceLock.Locked && LipstickSettings.lockscreenVisible === true) {
                        LipstickSettings.lockscreenVisible = false
                    }
                } else {
                    cancelAnimation.start()
                }
            }

            comp.gestureOnGoing = false
        }
        // States are for the animations that follow your finger during swipes
        states: [
            State {
                name: "swipe"
                when: DeviceLock.state != DeviceLock.Locked
                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }

                PropertyChanges {
                    target: comp.topmostAlarmWindow == null ? appLayer : alarmsLayer
                    x: gestureArea.horizontal ? gestureArea.value : 0
                    y: gestureArea.horizontal ? 0 : gestureArea.value
                }
            },
            State {
                name: "lock"
                when: LipstickSettings.lockscreenVisible === true
                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }
            }
        ]

        SequentialAnimation {
            id: cancelAnimation

            NumberAnimation {
                target: gestureArea
                property: "value"
                to: 0
                duration: 200
                easing.type: Easing.OutQuint
            }

            PropertyAction {
                target: gestureArea
                property: "state"
                value: ""
            }
        }

        SequentialAnimation {
            id: lockAnimation
            property alias valueTo: valueAnimationLock.to

            SmoothedAnimation {
                id: valueAnimationLock
                property: "x"
                easing.type: Easing.OutQuint
            }

            ScriptAction {
                script: if (LipstickSettings.lockscreenVisible === true) {
                    LipstickSettings.lockScreen(true)
                } else {
                    LipstickSettings.lockscreenVisible = false
                }
            }

            PropertyAction {
                target: gestureArea
                property: "state"
                value: ""
            }
        }

        SequentialAnimation {
            id: swipeAnimation

            property alias valueTo: valueAnimation.to

            ParallelAnimation {
                NumberAnimation {
                    id: valueAnimation
                    target: gestureArea
                    property: "value"
                    duration: 200
                    easing.type: Easing.OutQuint
                }
                NumberAnimation {
                    id: wOpacityAnimation
                    target: comp.topmostWindow
                    property: "opacity"
                    to: 0
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }

            ScriptAction {
                script: {
                    comp.topmostWindow.opacity = 1.0
                    comp.setCurrentWindow(comp.homeWindow)
                }
            }

            PropertyAction {
                target: gestureArea
                property: "state"
                value: ""
            }
        }
    }

    Component {
        id: windowWrapper
        WindowWrapperBase {
        }
    }

    Component {
        id: alphaWrapper
        Item {
        }
    }

    Component {
        id: mysticWrapper
        WindowWrapperMystic {
            id: innerMystic
        }
    }

    Compositor {
        id: comp
        property Item homeWindow
        // Set to the item of the current topmost window
        property Item topmostWindow

        property bool gestureOnGoing

        // True if the home window is the topmost window
        homeActive: topmostWindow == comp.homeWindow
        property bool appActive: !homeActive

        // The application window that was most recently topmost
        property Item topmostApplicationWindow
        property Item topmostAlarmWindow: null

        property Item gestureArea: gestureArea
        property var lastClick: []

        function setClickCoordinate(coord) {
            lastClick = [ coord.x , coord.y ]
        }

        function windowToFront(winId) {
            var o = comp.windowForId(winId)
            var window = null
            var wi = null
            if (o) {
                window = o.userData
            }
            if (window == null) {
                window = homeWindow
            }

            setCurrentWindow(window)

        }

        function setCurrentWindow(w, skipAnimation) {
            if (w == null)
                w = homeWindow
            
            if (w.window.title !== "maliit-server") {
                topmostWindow = w
            }

            if (topmostWindow == homeWindow || topmostWindow == null) {
                comp.clearKeyboardFocus()
            } else if (w.window.title !== "maliit-server") {
                if (topmostApplicationWindow) {
                    topmostApplicationWindow.visible = false
                }
                topmostApplicationWindow = topmostWindow
                topmostApplicationWindow.visible = true
                if (!skipAnimation && windowAnimation.value) {
                    topmostApplicationWindow.animateIn()
                    lastClick = null
                }
                if (w.window) w.window.takeFocus()
            }
        }

        onSensorOrientationChanged: recalcOrientation()
        onOrientationLockChanged: recalcOrientation()

        onDisplayOff: function() {
            if (root.topmostAlarmWindow == null) {
                setCurrentWindow(root.homeWindow)
            }
            lastClick = null
        }

        onWindowAdded: function(window){
            console.log("Compositor: Window added \"" + window.title + "\""
                        + " category: " + window.category)

            var isHomeWindow = window.isInProcess && comp.homeWindow == null
                    && window.title === "Home"
            var isDialogWindow = window.category === "dialog"
            var isNotificationWindow = window.category == "notification"
            var isOverlayWindow = window.category == "overlay" || window.title === "maliit-server"
            var isAlarmWindow = window.category == "alarm"
            var parent = null
            if (window.category == "cover" || window.title == "_CoverWindow") {
                window.visible = false
                return
            }
            if (isHomeWindow) {
                parent = homeLayer
            } else if (isNotificationWindow) {
                parent = notificationLayer
            } else if (isOverlayWindow) {
                parent = overlayLayer
            } else if (isAlarmWindow) {
                parent = alarmsLayer
            } else {
                // If not windowed mode make app fullscreen
                if(windowedMode.value === false) {
                    window.resize(Qt.size(root.width, root.height))
                }

                parent = appLayer
            }

            var w
            if (isOverlayWindow) {
                console.debug("Have overlay")
                w = alphaWrapper.createObject(parent, {
                                                  window: window
                                              })

                console.log("owerlay height: " + window.height)
            }
            else {
                w = windowWrapper.createObject(parent, {
                                                   window: window
                                               })
            }

            window.userData = w

            if (isHomeWindow) {
                comp.homeWindow = w
                setCurrentWindow(homeWindow)
            } else if (isNotificationWindow) {
            } else if (isOverlayWindow) {
                setCurrentWindow(window)
            } else if (isDialogWindow) {
                setCurrentWindow(window)
            } else if (isAlarmWindow) {
                comp.topmostAlarmWindow = window
                w = isShaderUsed ? mysticWrapper.createObject(parent, {
                                                                  window: window
                                                              }) : w
                window.userData = w
                setCurrentWindow(w)
            } else {
                if (!comp.topmostAlarmWindow) {
                    parent=appLayer
                    w = isShaderUsed ? mysticWrapper.createObject(parent, {
                                                                      window: window
                                                                  }) : w
                    window.userData = w
                    setCurrentWindow(w)
                }
            }

            lastClick = null
        }

        onWindowRaised: function(window) {
            console.log("Compositor: Raising window: " + window.title
                        + " category: " + window.category)
            windowToFront(window.windowId)
        }

        onWindowRemoved: function(window) {
            console.log("Compositor: Window removed \"" + window.title + "\""
                        + " category: " + window.category)
            var w = window.userData
            if (window.category == "alarm") {
                comp.topmostAlarmWindow = null
                setCurrentWindow(comp.homeWindow)
            }
            if (comp.topmostWindow == w)
                setCurrentWindow(comp.homeWindow)

            if (window.userData)
                window.userData.destroy()
        }

        screenOrientation: {
            switch(orientationLock) {
            case "portrait":
                return Qt.PortraitOrientation
            case "portrait-inverted":
                return Qt.InvertedPortraitOrientation
            case "landscape":
                return Qt.LandscapeOrientation
            case "landscape-inverted":
                return Qt.InvertedLandscapeOrientation
            default:
                return nativeOrientation
            }
        }

        function recalcOrientation() {
            switch(orientationLock) {
            case "portrait":
                return Qt.PortraitOrientation
            case "portrait-inverted":
                return Qt.InvertedPortraitOrientation
            case "landscape":
                return Qt.LandscapeOrientation
            case "landscape-inverted":
                return Qt.InvertedLandscapeOrientation
            default:
                return screenOrientation
            }
        }

        function hideAllWindows() {
            setCurrentWindow(root.homeWindow)
            lastClick = null
        }
    }
}
