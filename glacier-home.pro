# Main project file for Glacier home

TEMPLATE = app
TARGET = lipstick
VERSION = 0.1

INSTALLS = target
target.path = /usr/bin

styles.path = /usr/share/lipstick-glacier-home-qt5
styles.files = src/nemovars.conf

qml.path = /usr/share/lipstick-glacier-home-qt5/
qml.files = src/qml/

settingswallpaperplugin.files = src/settings-plugins/wallpaper/wallpaper.qml \
                       src/settings-plugins/wallpaper/selectImage.qml \
                       src/settings-plugins/wallpaper/wallpaper.svg

settingswallpaperplugin.path = /usr/share/glacier-settings/qml/plugins/wallpaper

settingsnotificationsplugin.files = src/settings-plugins/notifications/notifications.qml \
                       src/settings-plugins/notifications/notifications.svg

settingsnotificationsplugin.path = /usr/share/glacier-settings/qml/plugins/notifications


settingsdesktopplugin.files = src/settings-plugins/desktop/desktop.qml \
                       src/settings-plugins/desktop/desktop.svg

settingsdesktopplugin.path = /usr/share/glacier-settings/qml/plugins/desktop

settingspluginconfig.files = src/settings-plugins/wallpaper/wallpaper.json \
                             src/settings-plugins/notifications/notifications.json \
                             src/settings-plugins/desktop/desktop.json

settingspluginconfig.path = /usr/share/glacier-settings/plugins

systemd.files = src/data/lipstick.service
systemd.path = /usr/lib/systemd/user

privileges.files = src/data/glacier-home.privileges
privileges.path = /usr/share/mapplauncherd/privileges.d/

mce.files = src/data/90-glacier-powerkey.conf \
            src/data/90-glacier-devlock.conf
mce.path = /etc/mce

INSTALLS += styles \
            qml \
            settingswallpaperplugin\
            settingsnotificationsplugin\
            settingspluginconfig \
            settingsdesktopplugin \
            systemd \
            privileges \
            mce

CONFIG += qt link_pkgconfig
QT += quick dbus
equals(QT_MAJOR_VERSION, 5):lessThan(QT_MINOR_VERSION, 7) {
QT += compositor
}
equals(QT_MAJOR_VERSION, 5):greaterThan(QT_MINOR_VERSION,7) {
QT += waylandcompositor
}
DEFINES += QT_COMPOSITOR_QUICK
HEADERS += \
    src/bluetooth/bluetoothagent.h \
    src/fileutils.h \
    src/glacierwindowmodel.h

LIBS += -lnemodevicelock
MOC_DIR = .moc

SOURCES += \
    src/bluetooth/bluetoothagent.cpp \
    src/fileutils.cpp \
    src/main.cpp \
    src/glacierwindowmodel.cpp

PKGCONFIG += lipstick-qt5 \
    nemodevicelock \
    KF5BluezQt

OTHER_FILES += src/nemovars.conf

TRANSLATIONS += translations/glacer-home.ts \
                translations/glacer-home_ru.ts \
                translations/glacer-home_cs.ts

i18n_files.files = translations
i18n_files.path = /usr/share/lipstick-glacier-home-qt5/

INSTALLS += i18n_files

DISTFILES += \
    src/data/90-glacier-devlock.conf \
    src/qml/dialogs/BtRequestConfirmationDialog.qml \
    src/qml/lockscreen/AngleAnimation.qml \
    translations/*.ts \
    settings-plugins/*/*.qml \
    settings-plugins/*/*.json \
    settings-plugins/*/*.svg \
    rpm/*
