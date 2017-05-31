import QtQuick 2.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

MouseArea {
    id: notifyArea

    height: childrenRect.height
    width: rootitem.width

    onClicked: {
        if (modelData.userRemovable) {
            modelData.actionInvoked("default")
        }
    }

    Image {
        id: appIcon
        height: Theme.itemHeightExtraLarge
        width: height

        anchors{
            left: parent.left
            leftMargin: Theme.itemSpacingLarge
        }

        source: {
            if (modelData.icon)
                return "image://theme/" + modelData.icon
            else
                return "/usr/share/lipstick-glacier-home-qt5/qml/images/glacier.svg"
        }
    }
    Label {
        id: appName
        text: modelData.appName
        width: (rootitem.width-appIcon.width)-Theme.itemSpacingHuge
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
        width: (rootitem.width-appIcon.width)-Theme.itemSpacingHuge
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeLarge
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
        width: (rootitem.width-appIcon.width)-Theme.itemSpacingHuge
        text: modelData.body
        color: Theme.textColor
        font.pixelSize: Theme.fontSizeMedium
        anchors{
            left: appName.left
            top: appSummary.bottom
        }
        elide: Text.ElideRight
    }
}
