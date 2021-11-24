// This file is part of glacier-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2021, Chipligin Sergey <neochapay@gmail.com>

import QtQuick 2.6
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
// Feeds page:
// the place for an event feed.

import "feedspage"
import "notifications"

Item {
    id: feedsPage
    width: desktop.width
    height: desktop.height-statusbar.height

    Rectangle{
        id: bg
        anchors.fill: parent
        color: Theme.backgroundColor
        opacity: 0.6
    }

    // Day of week
    Item {
        id: dateRow
        height: Theme.itemHeightLarge
        width: parent.width

        anchors{
            top: parent.top
            horizontalCenter: parent.rootitemhorizontalCenter
            topMargin: Theme.itemSpacingLarge
            bottomMargin: Theme.itemSpacingLarge
        }

        Label {
            id: displayDayOfWeek
            text: Qt.formatDateTime(wallClock.time, "dddd")
            color: Theme.textColor
            font.pixelSize: Theme.fontSizeLarge
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
        }

        // Current date
        Label {
            id: displayCurrentDate
            text: Qt.formatDate(wallClock.time, "d MMMM yyyy")
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.textColor
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: displayDayOfWeek.bottom
            }
        }
    }

    ControlCenter{
        id: controlCenter
        anchors{
            top: dateRow.bottom
            topMargin: Theme.itemHeightLarge*1.5
        }
    }

    Item {
        id: mainFlickable
        width: parent.width
        height: parent.height-dateRow.height-controlCenter.height-Theme.itemSpacingLarge*3

        anchors{
            top: controlCenter.bottom
            topMargin: Theme.itemSpacingMedium
        }

        clip: true

        Item {
            id: rootitem
            width: parent.width
            height: childrenRect.height

            Timer {
                id: timestampTimer
                interval: 60000
                running: true
                repeat: true
            }

            Column {
                id: notificationColumn
                width: parent.width

                spacing: Theme.itemSpacingExtraSmall
                Repeater {
                    model: NotificationListModel {
                        id: notifmodel
                    }
                    delegate: NotificationItem{
                        id: notifItem
                        Connections {
                            target: timestampTimer
                            function onTriggered() {
                                notifItem.refreshTimestamp()
                            }

                            function onRunningChanged(running) {
                                if (timestampTimer.running) {
                                    notifItem.refreshTimestamp()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
