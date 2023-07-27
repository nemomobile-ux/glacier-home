/****************************************************************************************
**
** Copyright (C) 2020-2023 Chupligin Sergey <neochapay@gmail.com>
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
import Nemo.Controls

import org.nemomobile.mpris 1.0

Item {
    id: mediaControls
    visible: mprisManager.currentService

    MprisManager {
        id: mprisManager
        onCurrentServiceChanged: {
            if(currentService) {
                mediaControls.visible = true
            } else {
                mediaControls.visible = false
            }
        }

        onMetadataChanged: {
            var artistTag = Mpris.metadataToString(Mpris.Artist)
            var titleTag = Mpris.metadataToString(Mpris.Title)

            artistLabel.text = (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() : qsTr("Unknown artist")
            songLabel.text = (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() : qsTr("Unknown track")
        }
    }

    property bool isPlaying: mprisManager.currentService && mprisManager.playbackStatus == Mpris.Playing

    height: childrenRect.height
    width: parent.width

    Column {
        id: column
        width: parent.width
        height: childrenRect.height

        Label {
            id: artistLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: songLabel
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }


        Rectangle {
            id: controls
            width: parent.width
            height: Theme.itemHeightExtraLarge
            color: "transparent"
            visible: mprisManager.canPause || mprisManager.canPause

            Image{
                id: playPauseBtn
                width: height
                height: Theme.itemHeightExtraLarge*0.9

                anchors.centerIn: parent;

                source: (mediaControls.isPlaying) ?
                            "image://theme/pause" :
                            "image://theme/play"

                MouseArea{
                    anchors.fill: parent
                    //bool MprisController::playPause() The method is not allowed
                    onClicked: mediaControls.isPlaying ? mprisManager.pause() : mprisManager.play()
                }
            }

            Image{
                id: forwBtn
                width: playPauseBtn.width*0.6
                height: width
                visible: mprisManager.canGoNext

                anchors{
                    left: playPauseBtn.right
                    leftMargin: width/2
                    verticalCenter: playPauseBtn.verticalCenter
                }

                source: "image://theme/forward"

                MouseArea{
                    anchors.fill: parent
                    onClicked: mprisManager.next()
                }
            }

            Image{
                id: backBtn
                width: playPauseBtn.width*0.6
                height: width
                visible: mprisManager.canGoPrevious

                anchors{
                    right: playPauseBtn.left
                    rightMargin: width/2
                    verticalCenter: playPauseBtn.verticalCenter
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: mprisManager.previous()
                }

                source: "image://theme/backward"
            }
        }
    }
}

