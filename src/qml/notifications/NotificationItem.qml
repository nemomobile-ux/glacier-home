import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

import "../scripts/desktop.js" as Desktop

Item {
    id: notifyArea

    height: Theme.itemHeightExtraLarge
    width: parent.width-Theme.itemSpacingSmall*2
    anchors{
        left: parent.left
        leftMargin: Theme.itemSpacingSmall
    }

    clip: true

    property alias appIcon: appIcon
    property alias appBody: appBody
    property alias appName: appName
    property alias appSummary: appSummary

    property alias appTimestamp: appTimestamp
    property alias pressBg: pressBg
    property int iconSize:Math.min(Theme.iconSizeLauncher, height-Theme.itemSpacingMedium)
    property string timeAgo
    property int swipeTreshold: notifyArea.width/3

    MouseArea{
        id: notifyMouseArea
        anchors.fill: parent

        drag.target: modelData.userRemovable ? notifyArea : null
        drag.axis: Drag.XAxis
        drag.minimumX: -notifyArea.width
        drag.maximumX: notifyArea.width
        drag.onActiveChanged: {
            if(!drag.active ) {
                if((notifyArea.x > swipeTreshold)) {
                    slideAnimation.start()
                }else if (notifyArea.x < -swipeTreshold){
                    slideReverseAnimation.start()
                } else {
                    slideBackAnimation.start()
                }
            }
        }

        onClicked: {
            if (Desktop.instance.lockscreenVisible()) {
                return
            }

            if (modelData.userRemovable) {
                slideAnimation.start()
            } else {
                modelData.actionInvoked("default")
            }

            Desktop.instance.setLockScreen(false)
        }
    }

    function refreshTimestamp() {
        var seconds = Math.floor((new Date() - modelData.timestamp) / 1000)
        var years = Math.floor(seconds / (365*24*60*60))
        var months = Math.floor(seconds / (30*24*60*60))
        var days = Math.floor(seconds / (24*60*60))
        var hours = Math.floor(seconds / (60*60))
        var minutes = Math.floor(seconds / 60)

        if (years >= 1) {
            timeAgo = qsTr("%n year(s) ago", "notifications", years)
        }else if (months >= 1) {
            timeAgo = qsTr("%n months(s) ago", "notifications", months)
        }else if (days >= 1) {
            timeAgo = qsTr("%n day(s) ago", "notifications", days)
        }else if (hours >= 1) {
            timeAgo = qsTr("%n hours(s) ago", "notifications", hours)
        } else if (minutes >= 1) {
            timeAgo = qsTr("%n minutes(s) ago", "notifications", minutes)
        } else {
            timeAgo = qsTr("Just now")
        }
    }

    NumberAnimation {
        id:slideAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: notifyArea.width
        easing.type: Easing.InOutQuad
        onStopped: modelData.actionInvoked("default")
    }
    NumberAnimation {
        id:slideReverseAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: -notifyArea.width
        easing.type: Easing.InOutQuad
        onStopped: modelData.removeRequested()
    }
    NumberAnimation {
        id:slideBackAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: 0
        easing.type: Easing.InOutQuad
    }

    Rectangle {
        id:pressBg
        anchors.fill: parent
        color: Theme.fillColor
        visible: notifyMouseArea.pressed
        radius: Theme.itemSpacingMedium
        opacity: 0.5
    }

    Rectangle{
        id: progressBar
        width: notifyArea.width * modelData.progress
        height: notifyArea.height
        color: Theme.accentColor
        radius: Theme.itemSpacingMedium
        opacity: 0.75
        anchors{
            top: parent.top
            left: parent.left
        }
        visible: modelData.progress != 0

        Behavior on width{
            NumberAnimation { duration: 333 }
        }
    }

    Image {
        id: appIcon
        property string defaultIcon: "/usr/share/lipstick-glacier-home-qt5/qml/images/glacier.svg"

        height: iconSize
        width: iconSize
        anchors{
            left: parent.left
            leftMargin: Theme.itemSpacingLarge
            verticalCenter:parent.verticalCenter
        }

        source: {
            if (modelData.icon) {
                if(modelData.icon.indexOf("/") == 0)
                    return "file://" + modelData.icon
                else
                    return "image://theme/" + modelData.icon
            } else if (modelData.appIcon) {
                if(modelData.appIcon.indexOf("/") == 0)
                    return "file://" + modelData.appIcon
                else
                    return "image://theme/" + modelData.appIcon
            } else return defaultIcon
        }
        onStatusChanged: {
            if (appIcon.status == Image.Error) {
                appIcon.source = defaultIcon
            }
        }
    }

    Label {
        id: appName
        text: modelData.appName
        width: Math.min(implicitWidth,  parent.width-appTimestamp.width-Theme.itemSpacingSmall)
        color: Theme.textColor
        elide: Text.ElideRight
        font.pixelSize: Theme.fontSizeSmall
        anchors {
            left: appIcon.right
            leftMargin: Theme.itemSpacingSmall
            top: parent.top
            topMargin: Theme.itemSpacingSmall
        }
    }

    Label {
        id:appTimestamp
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeTiny
        text: if(timeAgo) timeAgo
        horizontalAlignment: Text.AlignRight
        anchors {
            top: parent.top
            topMargin: Theme.itemSpacingSmall
            right:parent.right
            rightMargin: Theme.itemSpacingSmall

        }
        Component.onCompleted: refreshTimestamp()
    }

    Label {
        id: appSummary
        text: modelData.summary || modelData.previewSummary
        width: parent.width-Theme.itemSpacingHuge
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeTiny
        anchors{
            left: appIcon.right
            leftMargin: Theme.itemSpacingSmall
            top: appName.bottom
            topMargin: Theme.itemSpacingSmall
        }
        maximumLineCount: 1
        elide: Text.ElideRight
    }

    Label {
        id: appBody
        width: parent.width-Theme.itemSpacingHuge
        text: modelData.body || modelData.previewBody
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeTiny
        anchors{
            left: appIcon.right
            leftMargin: Theme.itemSpacingSmall
            top: appSummary.bottom
            topMargin: Theme.itemSpacingSmall
        }
        maximumLineCount: 1
        elide: Text.ElideRight
    }
}
