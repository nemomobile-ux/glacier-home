
// Copyright (C) 2013 Jolla Ltd.
// Copyright (C) 2013 John Brooks <john.brooks@dereferenced.net>
// This file is part of colorful-home, a nice user experience for touchscreens.
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
import org.nemomobile.lipstick 0.1

import org.nemomobile.devicelock 1.0

import "compositor"
import "scripts/desktop.js" as Desktop

Item {
    id: root
    property bool isShaderUsed: false
    Connections {
        target: comp.quickWindow
        onActiveFocusItemChanged: {
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
            visible: comp.appActive
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

        property real swipeThreshold: 0.15
        property real lockThreshold: 0.25
        property int lockscreenX
        property int lockscreenY
        enabled: true //DeviceLock.state != DeviceLock.Locked

        onGestureStarted: {
            swipeAnimation.stop()
            cancelAnimation.stop()
            lockAnimation.stop()
            if (comp.appActive) {
            gestureOnGoing = true
                state = "swipe"
            } else if (comp.homeActive) {
                lockscreenX = Desktop.instance.lockscreen.x
                lockscreenY = Desktop.instance.lockscreen.y
                state = "lock"
            }
        }

        onGestureFinished: {
            if (comp.appActive) {
                if (gestureArea.progress >= swipeThreshold) {
                    swipeAnimation.valueTo = inverted ? -max : max
                    swipeAnimation.start()
                    if (gesture == "down") {
                        Lipstick.compositor.closeClientForWindowId(
                                    comp.topmostWindow.window.windowId)
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
                        // Locks, unlocks or brings up codepad to enter security code
                        // Locks
                        if (!Desktop.instance.lockscreenVisible()) {
                            Desktop.instance.setLockScreen(true)
                            if(gesture == "down") {
                                setDisplayOff()
                            }
                        }
                        // Brings up codepad, only left and right swipes allowed for it for now
                        else if (Desktop.instance.lockscreenVisible() && !Desktop.instance.codepad.visible && DeviceLock.state == DeviceLock.Locked && (gesture !== "down" && gesture !== "up")) {
                            Desktop.instance.codepadVisible = true
                        }
                        // Hides codepad but does not unlock the code, only left and right swipes allowed for now
                        else if (Desktop.instance.lockscreenVisible() && Desktop.instance.codepad.visible && DeviceLock.state == DeviceLock.Locked && gesture !== "down" && gesture !== "up") {
                            Desktop.instance.codepadVisible = false
                        }
                        // Unlocks if no security code required
                        else if (DeviceLock.state !== DeviceLock.Locked && Desktop.instance.lockscreenVisible()) {
                            Desktop.instance.setLockScreen(false)
                        }
                    } else {
                        Desktop.instance.setLockScreen(false)
                    }
                } else {
                    cancelAnimation.start()
                }
           gestureOnGoing = false
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
                when: DeviceLock.state == DeviceLock.Locked
                PropertyChanges {
                    target: Desktop.instance.lockscreen
                    visible: true
                }
                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }
                PropertyChanges {
                    target: Desktop.instance.lockscreen

                    x: gestureArea.lockscreenX + ((gestureArea.horizontal) ? (Desktop.instance.lockscreenVisible()?(gestureArea.value) :
                                                                                       (gestureArea.gesture == "right" ?
                                                                                       ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                            -Desktop.instance.lockscreen.width :
                                                                                            -Desktop.instance.lockscreen.height)+Math.abs(gestureArea.value) :
                                                                                       ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                            Desktop.instance.lockscreen.width :
                                                                                            Desktop.instance.lockscreen.height)+gestureArea.value) ) : 0 )
                    y: gestureArea.lockscreenY + ((gestureArea.horizontal) ? 0 : (Desktop.instance.lockscreenVisible()?(gestureArea.value) :
                                                                                       (gestureArea.gesture == "down" ?
                                                                                       ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                            -Desktop.instance.lockscreen.height :
                                                                                            -Desktop.instance.lockscreen.width)+Math.abs(gestureArea.value) :
                                                                                       ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                            Desktop.instance.lockscreen.height :
                                                                                            Desktop.instance.lockscreen.width)+gestureArea.value) ) )
                }
            },
            // pullCodepad is when you are pulling codepad into view to enter security code
            State {
                name: "pullCodepad"
                when: Desktop.instance.codepadVisible
                PropertyChanges {
                    target: Desktop.instance
                    codepadVisible: true
                }

                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }

                PropertyChanges {
                    target: Desktop.instance.codepad
                    // Confusing logic and math to get the codepad follow your finger
                    x: gestureArea.lockscreenX + (gestureArea.value < 0 ? Desktop.instance.lockscreen.width : -Desktop.instance.lockscreen.width) +
                       ((gestureArea.horizontal) ? (Desktop.instance.lockscreenVisible()?(gestureArea.value) :
                                                                                          (gestureArea.gesture == "right" ?
                                                                                               ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                                    -Desktop.instance.lockscreen.width :
                                                                                                    -Desktop.instance.lockscreen.height)+Math.abs(gestureArea.value) :
                                                                                               ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                                    Desktop.instance.lockscreen.width :
                                                                                                    Desktop.instance.lockscreen.height)+gestureArea.value) ) : 0 )
                    // Bringing up the codepad opacity from 0 to 1
                    opacity: gestureArea.horizontal ? (gestureArea.value < 0 ? (gestureArea.value / -Desktop.instance.lockscreen.width) :
                                                                               gestureArea.value / Desktop.instance.lockscreen.width) : 0
                }
            },
            // pushCodepad is when you are pushing the codepad away without entering a security code
            State {
                name: "pushCodepad"
                when: Desktop.instance.lockscreenVisible() && DeviceLock.state === DeviceLock.Locked && Desktop.instance.codepadVisible

                PropertyChanges {
                    target: gestureArea
                    delayReset: true
                }
                PropertyChanges {
                    target: Desktop.instance.codepad
                    // Confusing logic for the codepad to follow your swipe
                    x: gestureArea.lockscreenX +
                       ((gestureArea.horizontal) ? (Desktop.instance.lockscreenVisible()?(gestureArea.value) :
                                                                                          (gestureArea.gesture == "right" ?
                                                                                               ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                                    -Desktop.instance.lockscreen.width :
                                                                                                    -Desktop.instance.lockscreen.height)+Math.abs(gestureArea.value) :
                                                                                               ((Desktop.instance.lockscreen.width === topmostWindow.width) ?
                                                                                                    Desktop.instance.lockscreen.width :
                                                                                                    Desktop.instance.lockscreen.height)+gestureArea.value) ) : 0 )
                    // Hiding the codepad with opacity fading from 1 to 0
                    opacity: 1 - (gestureArea.horizontal ? (gestureArea.value < 0 ? (gestureArea.value / -Desktop.instance.lockscreen.width) :
                                                                                    gestureArea.value / Desktop.instance.lockscreen.width) : 0)
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
                target: Desktop.instance.lockscreen
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
                script: setCurrentWindow(comp.homeWindow)
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
        WindowWrapperAlpha {
        }
    }

    Component {
        id: mysticWrapper
        WindowWrapperMystic {
        }
    }
    Compositor {
        id: comp
        property Item homeWindow
        // Set to the item of the current topmost window
        property Item topmostWindow

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
            if (isAlarmWindow){
                comp.topmostAlarmWindow = window
                wi = mysticWrapper.createObject(parent, {window: window})
                window.userData = wi
                setCurrentWindow(wi)
            } else {
                if (!comp.topmostAlarmWindow) {
                    wi = mysticWrapper.createObject(parent, {window: window})
                }
            }
        }

        function setCurrentWindow(w, skipAnimation) {
            if (w == null)
                w = homeWindow

            topmostWindow = w

            if (topmostWindow == homeWindow || topmostWindow == null) {
                clearKeyboardFocus()
            } else {
                if (topmostApplicationWindow)
                    topmostApplicationWindow.visible = false
                topmostApplicationWindow = topmostWindow
                topmostApplicationWindow.visible = true
                if (!skipAnimation)
                    topmostApplicationWindow.animateIn()
                w.window.takeFocus()
            }
        }
        onSensorOrientationChanged: {
            screenOrientation = sensorOrientation
        }

        onDisplayOff: if (comp.topmostAlarmWindow == null)
                          setCurrentWindow(comp.homeWindow)

        onWindowAdded: {
            console.log("Compositor: Window added \"" + window.title + "\""
                        + " category: " + window.category)

            var isHomeWindow = window.isInProcess && comp.homeWindow == null
                    && window.title === "Home"
            var isDialogWindow = window.category === "dialog"
            var isNotificationWindow = window.category == "notification"
            var isOverlayWindow = window.category == "overlay"
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
                parent = appLayer
            }

            var w
            if (isOverlayWindow)
                w = alphaWrapper.createObject(parent, {
                                                  window: window
                                              })
            else
                w = windowWrapper.createObject(parent, {
                                                   window: window
                                               })

            window.userData = w

            if (isHomeWindow) {
                comp.homeWindow = w
                setCurrentWindow(homeWindow)
            } else if (isNotificationWindow || isOverlayWindow) {

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
        }
    }
}
