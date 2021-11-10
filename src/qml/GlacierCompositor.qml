// Copyright (C) 2013 Jolla Ltd.
// Copyright (C) 2013 John Brooks <john.brooks@dereferenced.net>
// Copyright (C) 2017 Aleksi Suomalainen
// Copyright (C) 2020 Eetu Kahelin
// Copyright (C) 2021 Chupligin Sergey (NeoChapay) <neochapay@gmail.com>
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
import QtQuick 2.0
import QtQuick.Window 2.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0

import "compositor"
import "scripts/desktop.js" as Desktop


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

    function mainReady() {
        windowedLayer.visible = !Desktop.instance.lockscreen.visible
        valueAnimationLock.target = Desktop.instance.lockscreen
    }

    Component.onCompleted: {
        Desktop.compositor = root;
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
            visible: comp.appActive && !Desktop.instance.lockscreen.visible
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

        onPositionChanged: {
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
        }

        onGestureStarted: {
            swipeAnimation.stop()
            cancelAnimation.stop()
            lockAnimation.stop()
            comp.gestureOnGoing = true
            if (comp.appActive && !diagonal) {
                state = "swipe"
            }
        }

        onGestureFinished: {
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
                    cancelAnimation.start()
                }
            } else if (comp.homeActive){
                if (gestureArea.progress >= lockThreshold) {
                    lockAnimation.valueTo = (gesture == "left" ?
                                                 Desktop.instance.lockscreen.width :
                                                 -Desktop.instance.lockscreen.width)
                    lockAnimation.start()

                    if (gesture == "down") {
                        // swipe down on lockscreen to turn off display
                        if (Desktop.instance.lockscreenVisible()) {
                            Desktop.instance.setLockScreen(true)
                            comp.setDisplayOff()
                        }
                    }
                    // Unlocks if no security code required
                    else if (DeviceLock.state !== DeviceLock.Locked && Desktop.instance.lockscreenVisible()) {
                        Desktop.instance.setLockScreen(false)
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
                when: Desktop.instance.state === "locked"
                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }
                PropertyChanges {
                    target: Desktop.instance.lockscreen

                    y: gestureArea.lockscreenY + ((gestureArea.horizontal) ? 0 : (Desktop.instance.lockscreenVisible()?(gestureArea.value) :
                                                                                       (gestureArea.gesture == "down" ?
                                                                                       ((Desktop.instance.lockscreen.width === comp.topmostWindow.width) ?
                                                                                            -Desktop.instance.lockscreen.height :
                                                                                            -Desktop.instance.lockscreen.width)+Math.abs(gestureArea.value) :
                                                                                       ((Desktop.instance.lockscreen.width === comp.topmostWindow.width) ?
                                                                                            Desktop.instance.lockscreen.height :
                                                                                            Desktop.instance.lockscreen.width)+gestureArea.value) ) )
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
                script: Desktop.instance.setLockScreen(
                            Desktop.instance.lockscreenVisible())
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

            NumberAnimation {
                id: valueAnimation
                target: gestureArea
                property: "value"
                duration: 200
                easing.type: Easing.OutQuint
            }

            ScriptAction {
                script: comp.setCurrentWindow(comp.homeWindow)
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

        function windowToFront(winId) {
            var o = comp.windowForId(winId)
            var window = null
            var wi = null
            if (o)
                window = o.userData
            if (window == null)
                window = homeWindow

            setCurrentWindow(window)

        }

        function setCurrentWindow(w, skipAnimation) {
            if (w == null)
                w = homeWindow

            topmostWindow = w

            if (topmostWindow == homeWindow || topmostWindow == null || w.window.title === "maliit-server") {
                comp.clearKeyboardFocus()
            } else {
                if (topmostApplicationWindow)
                    topmostApplicationWindow.visible = false
                topmostApplicationWindow = topmostWindow
                topmostApplicationWindow.visible = true
                if (w.window) w.window.takeFocus()
            }
        }

        onSensorOrientationChanged: recalcOrientation()
        onOrientationLockChanged: recalcOrientation()

        onDisplayOff: {
            if (root.topmostAlarmWindow == null) {
                setCurrentWindow(root.homeWindow)
            }
            Desktop.instance.displayOn = false
        }

        onDisplayOn: {
            Desktop.instance.displayOn = true
        }

        onWindowAdded: {
            console.log("Compositor: Window added \"" + window.title + "\""
                        + " category: " + window.category)

            var isHomeWindow = window.isInProcess && comp.homeWindow == null
                    && window.title === "Home"
            var isDialogWindow = window.category === "dialog"
            var isNotificationWindow = window.category == "notification"
            var isOverlayWindow = window.category == "overlay" || window.title === "maliit-server"
            isAlarmWindow = window.category == "alarm"
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
                parent = appLayer
            }

            var w
            if (isOverlayWindow) {
                console.debug("Have overlay")
                w = alphaWrapper.createObject(parent, {
                                                  window: window
                                              })
            }
            else
                w = windowWrapper.createObject(parent, {
                                                   window: window
                                               })

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
        }

        onWindowRaised: {
            console.log("Compositor: Raising window: " + window.title
                        + " category: " + window.category)
            windowToFront(window.windowId)
        }

        onWindowRemoved: {
            console.log("Compositor: Window removed \"" + window.title + "\""
                        + " category: " + window.category)
            Desktop.instance.switcher.switchModel.removeWindowForTitle(
                        window.title)
            var w = window.userData
            if (window.category == "alarm") {
                comp.topmostAlarmWindow = null
                setCurrentWindow(comp.homeWindow)
            }
            if (comp.topmostWindow == w)
                setCurrentWindow(comp.homeWindow)

            if (window.userData)
                window.userData.destroy()
            Desktop.instance.focus = true
        }

        screenOrientation: {
            if (orientationLock == "portrait") {
                return Qt.PortraitOrientation
            } else if (orientationLock == "landscape") {
                return Qt.LandscapeOrientation
            }
            return nativeOrientation
        }


        function recalcOrientation() {
            if (orientationLock == "portrait") {
                screenOrientation = (sensorOrientation & Qt.PortraitOrientation)|| Qt.PortraitOrientation
            } else if (orientationLock == "landscape") {
                screenOrientation = (sensorOrientation & Qt.LandscapeOrientation) || Qt.LandscapeOrientation
            } else {
                screenOrientation = sensorOrientation
            }
        }
    }
}
