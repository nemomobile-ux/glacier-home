import QtQuick 2.6
import Nemo.DBus 2.0

StatusbarItem {
    id: nfcIndicator
    iconSize:       parent.height * 0.671875
    iconSizeHeight: parent.height
    source: "/usr/share/lipstick-glacier-home-qt5/qml/theme/icon_nfc.png"
    visible: nfcIndicator.enabled

    property bool enabled

    property QtObject nfcSettingsDbus: DBusInterface {
        bus: DBus.SystemBus
        service: 'org.sailfishos.nfc.settings'
        path: '/'
        iface: 'org.sailfishos.nfc.Settings'
        signalsEnabled: true

        function enabledChanged(enabled) {
            nfcIndicator.enabled = enabled
        }

        function getEnabled() {
            call("GetEnabled", undefined, function (enabled) {
                // Success state
                nfcIndicator.enabled = enabled
            }, function() {
                // Failure state
                nfcIndicator.enabled = false
            })
        }
    }

    Component.onCompleted: {
        nfcSettingsDbus.getEnabled()
    }
}
