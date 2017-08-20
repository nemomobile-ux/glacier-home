import QtQuick 2.6
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

MouseArea {
    id: notifyArea

    height: childrenRect.height
    width: parent.width

    property alias appIcon: appIcon
    property alias appBody: appBody
    property alias appName: appName
    property alias appSummary: appSummary
    property int iconSize: Theme.itemHeightExtraLarge


    drag.target: notifyArea
    drag.axis: Drag.XAxis
    drag.minimumX: 0-Theme.itemHeightMedium
    drag.maximumX: notifyArea.width
    drag.onActiveChanged: {
        if(!drag.active ) {
            if((notifyArea.x > notifyArea.width/3)) {
                slideAnimation.start()
            }else slideBackAnimation.start()
        }
    }

    onClicked: {
        if (modelData.userRemovable) {
            slideAnimation.start()
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
        id:slideBackAnimation
        target: notifyArea
        property: "x"
        duration: 200
        from: notifyArea.x
        to: 0
        easing.type: Easing.InOutQuad
    }

    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: notifyArea.pressed
        radius: Theme.itemSpacingMedium
    }

    Image {
        id: appIcon
        property string defaultIcon: "/usr/share/lipstick-glacier-home-qt5/qml/images/glacier.svg"

        height: iconSize
        width: iconSize
        anchors{
            left: parent.left
            leftMargin: Theme.itemSpacingLarge
        }

        source: {
            if (modelData.icon)
                return "image://theme/" + modelData.icon
            else
                return defaultIcon
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
        width: (parent.width-appIcon.width)-Theme.itemSpacingHuge
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeMedium
        font.capitalization: Font.AllUppercase
        font.bold: true
        anchors {
            left: appIcon.right
            top: parent.top
            leftMargin: Theme.itemSpacingLarge
        }
    }

    Label {
        id: appSummary
        text: modelData.summary
        width: (parent.width-appIcon.width)-Theme.itemSpacingHuge
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeSmall
        //font.bold :true
        //font.capitalization: Font.AllUppercase

        anchors{
            left: appName.left
            top: appName.bottom
            topMargin: Theme.itemSpacingSmall
        }
        elide: Text.ElideRight
    }

    Label {
        id: appBody
        width: (parent.width-appIcon.width)-Theme.itemSpacingHuge
        text: modelData.body
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeSmall
        anchors{
            left: appName.left
            top: appSummary.bottom
        }
        elide: Text.ElideRight
    }
}
