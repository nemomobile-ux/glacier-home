
// This file is part of colorful-home, a nice user experience for touchscreens.
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

import QtQuick 2.1
import org.nemomobile.lipstick 0.1
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
// Feeds page:
// the place for an event feed.

import "notifications"

Flickable {
    id: mainFlickable
    clip: true
    contentHeight: rootitem.height
    contentWidth: parent.width
    Item {
        id: rootitem
        width: parent.width
        height: childrenRect.height
        // Day of week
        Rectangle {
            id: daterow
            height: Theme.itemHeightMedium
            width: parent.width

            anchors{
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: Theme.itemSpacingLarge
                bottomMargin: Theme.itemSpacingLarge
            }

            color: "transparent"

            Label {
                id: displayDayOfWeek
                text: Qt.formatDateTime(wallClock.time, "dddd")
                color: Theme.textColor
                font.pixelSize: Theme.fontSizeExtraLarge
                font.weight: Font.Bold
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
            }

            // Current date
            Label {
                id: displayCurrentDate
                text: Qt.formatDate(wallClock.time, "d MMMM yyyy")
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.textColor
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: displayDayOfWeek.bottom
                }
            }
        }

        Column {
            id: notificationColumn
            width: parent.width
            anchors{
                top: daterow.bottom
                topMargin: Theme.itemSpacingHuge
            }
            spacing: Theme.itemSpacingHuge
            Repeater {
                model: NotificationListModel {
                    id: notifmodel
                }
                delegate: NotificationItem{}
                }
            }
        }
}

