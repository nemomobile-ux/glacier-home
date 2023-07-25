.pragma library

var defaultIcon = "/usr/share/lipstick-glacier-home-qt6/qml/images/glacier.svg"

function iconAlias(icon) {

    var aliases = {
        'icon-system-charging' : 'plug',
        'icon-system-usb' : 'usb'
    }
    if (aliases[icon] !== undefined) {
        return aliases[icon];
    }
    return icon

}

function notificationImage(icon, appIcon) {
    if (icon) {
        if(icon.indexOf("/") === 0) {
            return "file://" + icon
        } else {
            return "image://theme/" + iconAlias(icon)
        }
    } else if (appIcon) {
        if(appIcon.indexOf("/") === 0) {
            return "file://" + appIcon
        } else {
            return "image://theme/" + iconAlias(appIcon)
        }
    } else {
        return defaultIcon
    }

}
