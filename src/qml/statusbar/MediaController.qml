/****************************************************************************************
**
** Copyright (C) 2017 Sergey Chupligin <mail@neochapay.ru>
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
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0
import QtQuick.Layouts 1.0

import org.nemomobile.mpris 1.0

Component {
    id: mediaPanelItem
    CommonPanel {
        id: mediaPanelcommon
        switcherEnabled: false
        settingsIconEnabled: false

        property bool isPlaying: mprisManager.currentService && mprisManager.playbackStatus == Mpris.Playing

        Item{
            width: parent.width
            height: parent.height

            Label{
                id: trackName
                width: parent.width
                text: if (mprisManager.currentService) {
                          var artistTag = Mpris.metadataToString(Mpris.Artist)
                          var titleTag = Mpris.metadataToString(Mpris.Title)

                          var artistLabel = (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() : "";
                          var titleLabel = (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() : ""

                          return artistLabel+" - "+titleLabel

                      }else{
                          return qsTr("Player not start")
                      }
                horizontalAlignment: Text.AlignHCenter
            }


            Image{
                id: backBtn
                width: playPause.width*0.6
                height: width
                visible: mprisManager.currentService

                anchors{
                    right: playPause.left
                    rightMargin: width/2
                    verticalCenter: playPause.verticalCenter
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: if (mprisManager.canGoPrevious) mprisManager.previous()
                }

                source: "image://theme/backward"
            }

            Image{
                id: playPause
                width: Theme.itemHeightHuge
                height: width
                visible: mprisManager.currentService

                anchors{
                    horizontalCenter: parent.horizontalCenter
                    top: trackName.bottom
                    topMargin: Theme.itemSpacingLarge
                }

                source: isPlaying ?
                            "image://theme/pause" :
                            "image://theme/play"

                MouseArea{
                    anchors.fill: parent
                     onClicked: if ((isPlaying && mprisManager.canPause) ||
                                    (!controls.isPlaying && mprisManager.canPlay)){
                                        mprisManager.playPause()
                                    }
                }
            }

            Image{
                id: forwBtn
                width: playPause.width*0.6
                height: width
                visible: mprisManager.currentService

                anchors{
                    left: playPause.right
                    leftMargin: width/2
                    verticalCenter: playPause.verticalCenter
                }

                source: "image://theme/forward"

                MouseArea{
                    anchors.fill: parent
                    onClicked: if (mprisManager.canGoNext) mprisManager.next()
                }
            }
        }
    }
}
