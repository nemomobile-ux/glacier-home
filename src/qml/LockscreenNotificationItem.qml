/****************************************************************************************
**
** Copyright (C) 2017 Samuel Pavlovic <sam@volvosoftware.com>
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

import QtQuick 2.1
import QtQuick.Window 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtGraphicalEffects 1.0
import org.freedesktop.contextkit 1.0
import MeeGo.Connman 0.2
import org.nemomobile.lipstick 0.1
import QtFeedback 5.0
import QtMultimedia 5.0

//Make this sort of a slider
MouseArea{
    width: parent.width; 
    height: 192;
    Rectangle {
    	id: lockscreenNotification
        width: parent.width; 
        height: parent.height;
        color: "#C0000000"
        radius: 32

        //Icon
        Item{
            id: notificationIconPadding
            width: parent.height
            height: parent.height

            Image {
                id: notificationIcon
                width: parent.width*0.666
                height: width
                anchors.centerIn: parent
                source: "images/notification-circle.png"
            }
        }
        Item{
            width:  parent.width 
            height: notificationIcon.height

            anchors {
                top: notificationIcon.top
                left: notificationIconPadding.right
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            //Notification Summary
            Text {
                id: notificationHeader
                width:  parent.width
                font {
                    pointSize: 7
                    bold: true
                }
                
                text: modelData.summary
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            //Notification Summary
            Text {
                id: notificationSummary
                font {
                    pointSize: 6
                    bold: false
                }
                anchors {
                    top: notificationHeader.bottom
                    left: notificationHeader.left
                    right: notificationHeader.right
                }
                text: modelData.body
                color: "white"
                clip: true
                elide: Text.ElideRight
            }
            //Notification Time
            Text {
                id: notificationTime
                width:  parent.width
                font {
                    pointSize: 6
                    bold: false
                }
                anchors {
                    top: notificationSummary.bottom
                    left: notificationSummary.left
                    right: notificationSummary.right
                }
                text: "4:20"
                color: "white"
                clip: true
                elide: Text.ElideRight
            }
        }

        //Popping animation when the notification appears
        transform: Scale {
            id: scaleTransform
            property real scale: 0.1
            origin.x: parent.width /2
            origin.y: parent.height /2
            xScale: scale
            yScale: scale
        }

        SequentialAnimation {
	        id: popIn
	        running: true
	        NumberAnimation { 
	        	target: scaleTransform
	        	property: "scale" 
	        	to: 1 
	        	duration: 500
	        	easing.type: Easing.OutBack
	        	easing.amplitude:2
	        }
	    }

    }
}