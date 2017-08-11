
# Main project file for Glacier home

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

styles.path = /usr/share/lipstick-glacier-home-qt5
styles.files = nemovars.conf

images.path = /usr/share/lipstick-glacier-home-qt5/qml/images
images.files = qml/images/*.png \
               qml/images/*.jpg \
               qml/images/*.svg

theme.path = /usr/share/lipstick-glacier-home-qt5/qml/theme
theme.files = qml/theme/*.png

qml.path = /usr/share/lipstick-glacier-home-qt5/qml
qml.files = qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/Lockscreen.qml \
    qml/LockscreenClock.qml \
    qml/AppSwitcher.qml \
    qml/AppLauncher.qml \
    qml/ToolBarLayoutExample.qml \
    qml/SwitcherItem.qml \
    qml/CloseButton.qml \
    qml/NotificationPreview.qml \
    qml/FeedsPage.qml \
    qml/Statusbar.qml \
    qml/StatusbarItem.qml \
    qml/WifiPanel.qml \
    qml/SimPanel.qml \
    qml/NumButton.qml \
    qml/USBModeSelector.qml \
    qml/Pager.qml \
    qml/VolumeControl.qml \
    qml/BatteryPanel.qml \
    qml/CommonPanel.qml \
    qml/ShutdownScreen.qml \
    qml/GlacierRotation.qml \
    qml/DeviceLockUI.qml

qmlcompositor.path = /usr/share/lipstick-glacier-home-qt5/qml/compositor
qmlcompositor.files = qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/compositor/ScreenGestureArea.qml

scripts.path = /usr/share/lipstick-glacier-home-qt5/qml/scripts
scripts.files =  qml/scripts/desktop.js \
                qml/scripts/rotation.js

system.path = /usr/share/lipstick-glacier-home-qt5/qml/system
system.files = qml/ShutdownScreen.qml

volumecontrol.path = /usr/share/lipstick-glacier-home-qt5/qml/volumecontrol
volumecontrol.files = qml/VolumeControl.qml

connectivity.path = /usr/share/lipstick-glacier-home-qt5/qml/connectivity
connectivity.files = qml/connectivity/USBModeSelector.qml \
                     qml/connectivity/ConnectionSelector.qml

notifications.path = /usr/share/lipstick-glacier-home-qt5/qml/notifications
notifications.files = qml/notifications/NotificationItem.qml\
                      qml/notifications/NotificationPreview.qml

statusbar.path = /usr/share/lipstick-glacier-home-qt5/qml/statusbar
statusbar.files = qml/statusbar/BatteryPanel.qml\
                qml/statusbar/BatteryIndicator.qml \
                qml/statusbar/CommonPanel.qml\
                qml/statusbar/SimPanel.qml\
                qml/statusbar/WifiPanel.qml\
                qml/statusbar/StatusbarItem.qml\
                qml/statusbar/NumButton.qml

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
            statusbar

CONFIG += qt link_pkgconfig
QT += quick compositor
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    glacierwindowmodel.h

MOC_DIR = .moc

SOURCES += \
    main.cpp \
    glacierwindowmodel.cpp

PKGCONFIG += lipstick-qt5

OTHER_FILES += qml/*.qml \
    qml/MainScreen.qml \
    qml/compositor.qml \
    qml/LauncherItemDelegate.qml \
    qml/Lockscreen.qml \
    qml/LockscreenClock.qml \
    qml/AppSwitcher.qml \
    qml/AppLauncher.qml \
    qml/ToolBarLayoutExample.qml \
    qml/SwitcherItem.qml \
    qml/CloseButton.qml \
    qml/compositor/WindowWrapperMystic.qml \
    qml/compositor/WindowWrapperBase.qml \
    qml/compositor/WindowWrapperAlpha.qml \
    qml/compositor/ScreenGestureArea.qml \
    qml/NotificationPreview.qml \
    qml/scripts/desktop.js \
    qml/FeedsPage.qml \
    qml/Statusbar.qml \
    qml/StatusbarItem.qml \
    qml/WifiPanel.qml \
	nemovars.conf \
    qml/SimPanel.qml \
    qml/NumButton.qml \
    qml/USBModeSelector.qml \
    qml/VolumeControl.qml \
    qml/BatteryPanel.qml \
    qml/CommonPanel.qml \
    qml/ShutdownScreen.qml \
    qml/GlacierRotation.qml

TRANSLATIONS += i18n/glacer-home.ts

DISTFILES += \
    i18n/glacer-home.ts \
    qml/connectivity/ConnectionSelector.qml \
    qml/statusbar/BatteryIndicator.qml \
    qml/scripts/fontawesome.js \
    qml/scripts/ionicons.js \
    qml/theme/fonts/FiraSansCondensed-Light.otf \
    qml/theme/fonts/FiraSansCondensed-Regular.otf \
    qml/theme/fonts/FiraSansCondensed-SemiBold.otf \
    qml/theme/fonts/FiraSans-Hair.ttf \
    qml/theme/fonts/FiraSans-Light.ttf \
    qml/theme/fonts/FiraSans-Regular.ttf \
    qml/theme/fonts/FiraSans-Thin.ttf \
    qml/theme/fonts/fontawesome-webfont.ttf \
    qml/theme/fonts/ionicons.ttf \
    qml/theme/button_down.wav \
    qml/theme/button_up.wav \
    qml/theme/battery0.png \
    qml/theme/battery1.png \
    qml/theme/battery2.png \
    qml/theme/battery3.png \
    qml/theme/battery4.png \
    qml/theme/battery5.png \
    qml/theme/battery6.png \
    qml/theme/battery_grid.png \
    qml/theme/data_egprs.png \
    qml/theme/data_gprs.png \
    qml/theme/data_hspa.png \
    qml/theme/data_lte.png \
    qml/theme/data_unknown.png \
    qml/theme/data_utms.png \
    qml/theme/default-icon.png \
    qml/theme/icon-m-framework-close-thumbnail.png \
    qml/theme/icon_bluetooth.png \
    qml/theme/icon_gps.png \
    qml/theme/icon_music.png \
    qml/theme/icon_nfc.png \
    qml/theme/icon_signal_0.png \
    qml/theme/icon_signal_1.png \
    qml/theme/icon_signal_2.png \
    qml/theme/icon_signal_3.png \
    qml/theme/icon_signal_4.png \
    qml/theme/icon_signal_5.png \
    qml/theme/icon_wifi_0.png \
    qml/theme/icon_wifi_1.png \
    qml/theme/icon_wifi_2.png \
    qml/theme/icon_wifi_3.png \
    qml/theme/icon_wifi_4.png \
    qml/theme/mask_multitask_shadow.png \
    qml/theme/fonts/OFL.txt \
    qml/controlcenter/ControlButton.qml
