import QtQuick 2.6
import QtSensors 5.2

import org.nemomobile.lipstick 0.1
import org.nemomobile.devicelock 1.0
import Nemo.Configuration 1.0

import QtGraphicalEffects 1.15

import "../scripts/desktop.js" as Desktop

Item {
    id: wallpaper

    property double maxX: desktop.width*0.1
    property double maxY: desktop.height*0.1

    ConfigurationValue {
        id: wallpaperSource
        key: "/home/glacier/homeScreen/wallpaperImage"
        defaultValue: "/usr/share/lipstick-glacier-home-qt5/qml/images/wallpaper-portrait-bubbles.png"
    }

    ConfigurationValue {
        id: enableParallax
        key: "/home/glacier/homeScreen/enableParallax"
        defaultValue: true
        onValueChanged: {
            if(!Desktop.instance.lockscreenVisible() && value) {
                accelerometer.active = true
            } else {
                accelerometer.active = false
            }
        }
    }

    Accelerometer {
        id: accelerometer
        active: (enableParallax.value === true && !LipstickSettings.lockscreenVisible === true)
        skipDuplicates: true

        onReadingChanged: {
            var calculateX = -maxX+maxX*accelerometer.reading.x*0.1
            var calculateY = -maxY+maxY*accelerometer.reading.y*0.1
            if(calculateX > maxX) {
                calculateX = maxX
            } else if  (calculateX < -maxX) {
                calculateX = -maxX
            }

            if(calculateY > maxY) {
                calculateY = maxY
            } else if  (calculateY < -maxY) {
                calculateX = -maxY
            }

            wallpaperImage.x = calculateX
            wallpaperImage.y = calculateY
        }
    }

    Image {
        id:wallpaperImage
        width: wallpaper.width+maxX*4
        height: wallpaper.height+maxY*4

        x: -maxX
        y: -maxY

        source: wallpaperSource.value
        fillMode: Image.PreserveAspectCrop

        Behavior on x {
            NumberAnimation { duration: 200 }
        }

        Behavior on y {
            NumberAnimation { duration: 200 }
        }
    }

/*Disable accelerometer when device locked */
    Connections {
        target: LipstickSettings
        function onLockscreenVisibleChanged() {
            if(!LipstickSettings.lockscreenVisible === true && enableParallax.value == true) {
                accelerometer.active = true
            } else {
                accelerometer.active = false
            }
        }
    }

    FastBlur {
        anchors.fill: wallpaperImage
        source: wallpaperImage
        radius: 100
        visible: Lipstick.compositor.topmostWindow !== Lipstick.compositor.homeWindow
    }
}
