# Main project file for Glacier home

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

styles.path = /usr/share/lipstick-glacier-home-qt5
styles.files = src/nemovars.conf

images.path = /usr/share/lipstick-glacier-home-qt5/qml/images
images.files = src/qml/images/*.png \
               src/qml/images/*.jpg \
               src/qml/images/*.svg

theme.path = /usr/share/lipstick-glacier-home-qt5/qml/theme
theme.files = src/qml/theme/*.png

qml.path = /usr/share/lipstick-glacier-home-qt5/qml
qml.files = src/qml/MainScreen.qml \
    src/qml/compositor.qml \
    src/qml/LauncherItemDelegate.qml \
    src/qml/Lockscreen.qml \
    src/qml/LockscreenClock.qml \
    src/qml/AppSwitcher.qml \
    src/qml/AppLauncher.qml \
    src/qml/ToolBarLayoutExample.qml \
    src/qml/SwitcherItem.qml \
    src/qml/CloseButton.qml \
    src/qml/NotificationPreview.qml \
    src/qml/FeedsPage.qml \
    src/qml/Statusbar.qml \
    src/qml/StatusbarItem.qml \
    src/qml/WifiPanel.qml \
    src/qml/SimPanel.qml \
    src/qml/NumButton.qml \
    src/qml/USBModeSelector.qml \
    src/qml/Pager.qml \
    src/qml/VolumeControl.qml \
    src/qml/BatteryPanel.qml \
    src/qml/CommonPanel.qml \
    src/qml/ShutdownScreen.qml \
    src/qml/GlacierRotation.qml \
    src/qml/DeviceLockUI.qml \
    src/qml/LauncherItemWrapper.qml \
    src/qml/LauncherItemFolder.qml \
    src/qml/ControlCenter.qml

qmlcompositor.path = /usr/share/lipstick-glacier-home-qt5/qml/compositor
qmlcompositor.files = src/qml/compositor/WindowWrapperMystic.qml \
    src/qml/compositor/WindowWrapperBase.qml \
    src/qml/compositor/WindowWrapperAlpha.qml \
    src/qml/compositor/ScreenGestureArea.qml

scripts.path = /usr/share/lipstick-glacier-home-qt5/qml/scripts
scripts.files =  src/qml/scripts/desktop.js \
                src/qml/scripts/rotation.js

system.path = /usr/share/lipstick-glacier-home-qt5/qml/system
system.files = src/qml/ShutdownScreen.qml

volumecontrol.path = /usr/share/lipstick-glacier-home-qt5/qml/volumecontrol
volumecontrol.files = src/qml/VolumeControl.qml

connectivity.path = /usr/share/lipstick-glacier-home-qt5/qml/connectivity
connectivity.files = src/qml/connectivity/USBModeSelector.qml \
                     src/qml/connectivity/ConnectionSelector.qml

notifications.path = /usr/share/lipstick-glacier-home-qt5/qml/notifications
notifications.files = src/qml/notifications/NotificationItem.qml\
                      src/qml/notifications/NotificationPreview.qml

statusbar.path = /usr/share/lipstick-glacier-home-qt5/qml/statusbar
statusbar.files = src/qml/statusbar/BatteryPanel.qml\
                src/qml/statusbar/BatteryIndicator.qml \
                src/qml/statusbar/CommonPanel.qml\
                src/qml/statusbar/SimPanel.qml\
                src/qml/statusbar/WifiPanel.qml\
                src/qml/statusbar/StatusbarItem.qml\
                src/qml/statusbar/NumButton.qml \
                src/qml/statusbar/MediaController.qml

applauncher.path = /usr/share/lipstick-glacier-home-qt5/qml/applauncher
applauncher.files = src/qml/applauncher/SearchListView.qml \
                src/qml/applauncher/Deleter.qml

controlcenter.path = /usr/share/lipstick-glacier-home-qt5/qml/controlcenter
controlcenter.files = src/qml/controlcenter/ControlButton.qml

settingswallpaperplugin.files = src/settings-plugins/wallpaper/wallpaper.qml \
                       src/settings-plugins/wallpaper/selectImage.qml \
                       src/settings-plugins/wallpaper/wallpaper.svg

settingswallpaperplugin.path = /usr/share/glacier-settings/qml/plugins/wallpaper

settingsnotificationsplugin.files = src/settings-plugins/notifications/notifications.qml \
                       src/settings-plugins/notifications/notifications.svg

settingsnotificationsplugin.path = /usr/share/glacier-settings/qml/plugins/notifications

settingspluginconfig.files = src/settings-plugins/wallpaper/wallpaper.json \
                             src/settings-plugins/notifications/notifications.json

settingspluginconfig.path = /usr/share/glacier-settings/plugins

systemd.files = rpm/lipstick.service
systemd.path = /usr/lib/systemd/user

desktop.files = rpm/lipstick.desktop
desktop.path = /etc/xdg/autostart

INSTALLS += styles \
            images \
            theme \
            qml \
            qmlcompositor\
            scripts\
            system\
            volumecontrol\
            connectivity\
            notifications\
            statusbar\
            controlcenter \
            settingswallpaperplugin\
            settingsnotificationsplugin\
            settingspluginconfig \
            applauncher \
            systemd \
            desktop

CONFIG += qt link_pkgconfig
QT += quick compositor
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    src/glacierwindowmodel.h
QT += dbus
LIBS += -lnemodevicelock
MOC_DIR = .moc

SOURCES += \
    src/main.cpp \
    src/glacierwindowmodel.cpp

PKGCONFIG += lipstick-qt5 \
    nemodevicelock

OTHER_FILES += src/qml/*.qml \
    src/qml/compositor/*.qml \
    src/qml/scripts/desktop.js \
    src/nemovars.conf \
    src/qml/connectivity/*.qml

TRANSLATIONS += i18n/glacer-home.ts

DISTFILES += \
    i18n/glacer-home.ts \
    qml/*/*.qml \
    settings-plugins/*/*.qml \
    settings-plugins/*/*.json \
    settings-plugins/*/*.svg \
    rpm/*

