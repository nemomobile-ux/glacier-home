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
        height: 100
        width: height

        anchors{
            left: parent.left
            leftMargin: 20
        }

        source: {
            if (modelData.icon)
                return "image://theme/" + modelData.icon
            else
                return "/usr/share/lipstick-glacier-home-qt5/qml/images/glacier.svg"
        }
    }

    Label {
        id: appSummary
        text: modelData.summary
        width: (rootitem.width-appIcon.width)-40
        font.pointSize: 12
        font.bold :true
        font.capitalization: Font.AllUppercase

        anchors{
            left: appIcon.right
            leftMargin: 20
            top: parent.top
        }
        wrapMode: Text.Wrap
    }

    Label {
        id: appBody
        width: (rootitem.width-appIcon.width)-40
        text: modelData.body
        font.pointSize: 14
        anchors{
            left: appSummary.left
            top: appSummary.bottom
        }
        wrapMode: Text.Wrap
    }
}
