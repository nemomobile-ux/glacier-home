// This file is part of glacier-home, a nice user experience for NemoMobile.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>
// Copyright (c) 2018-2024, Chupligin Sergey <neochapay@gmail.com>

#include <QFile>
#include <QFont>
#include <QQmlContext>
#include <QQmlEngine>
#include <QScreen>
#include <QQuickWindow>
#include <QTranslator>

#include <QtCore/qmath.h>

#include <homeapplication.h>
#include <homewindow.h>
#include <lipstickqmlpath.h>
#include <lipstickcompositor.h>

#include "models/controlcenterbuttonsmodel.h"
#include "models/glacierwindowmodel.h"
#include "models/searchmodel.h"

#ifdef USE_GEOCLUE2
#include "geoclueagent.h"
#endif

#include "fileutils.h"
#include "logging.h"
#include "mceconnect.h"

void loadEnvironmentFile(const QString& fileName)
{
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    QTextStream in(&file);

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();

        if (line.isEmpty() || line.startsWith('#'))
            continue;

        int pos = line.indexOf('=');
        if (pos == -1)
            continue;

        QString key = line.left(pos).trimmed();
        QString value = line.mid(pos + 1).trimmed();

        setenv(key.toUtf8().constData(), value.toUtf8().constData(), 1);
    }
}

int main(int argc, char** argv)
{
    bool desktopMode = false;
    for (int i = 1; i < argc; i++) {
        if (QString::fromLocal8Bit(argv[i]) == QStringLiteral("--desktop") ||
            QString::fromLocal8Bit(argv[i]) == QStringLiteral("--app")) {
            desktopMode = true;
        }
    }
    if (!desktopMode) {
        QByteArray env = qgetenv("GLACIER_DESKTOP");
        if (env == "1" || env.toLower() == "true" || env.toLower() == "yes") {
            desktopMode = true;
        }
        env = qgetenv("GLACIER_APP_MODE");
        if (env == "1" || env.toLower() == "true" || env.toLower() == "yes") {
            desktopMode = true;
        }
    }

    HomeApplication app(argc, argv, QString());

    QTranslator* myappTranslator = new QTranslator(&app);
    if (myappTranslator->load(QLocale(), QLatin1String("glacier-home"), QLatin1String("_"), QLatin1String("/usr/share/glacier-home/translations/"))) {
        qCDebug(lcGlacierHomeCoreLog) << "translation.load() success" << QLocale::system().name();
        if (app.installTranslator(myappTranslator)) {
            qCDebug(lcGlacierHomeCoreLog) << "installTranslator() success" << QLocale::system().name();
        } else {
            qCDebug(lcGlacierHomeCoreLog) << "installTranslator() failed" << QLocale::system().name();
        }
    } else {
        qCDebug(lcGlacierHomeCoreLog) << "translation.load() failed" << QLocale::system().name();
    }

    QmlPath::append("/usr/share/glacier-home/qml");
    QGuiApplication::setFont(QFont("Open Sans"));

    FileUtils* fileUtils = new FileUtils();
    MceConnect* mceConnect = new MceConnect(nullptr, !desktopMode);

    Qt::ScreenOrientation nativeOrientation = app.primaryScreen()->nativeOrientation();
    QByteArray v = qgetenv("GLACIER_NATIVEORIENTATION");
    if (!v.isEmpty()) {
        switch (v.toInt()) {
        case 1:
            nativeOrientation = Qt::PortraitOrientation;
            break;
        case 2:
            nativeOrientation = Qt::LandscapeOrientation;
            break;
        case 4:
            nativeOrientation = Qt::InvertedPortraitOrientation;
            break;
        case 8:
            nativeOrientation = Qt::InvertedLandscapeOrientation;
            break;
        default:
            nativeOrientation = app.primaryScreen()->nativeOrientation();
        }
    }
    if (nativeOrientation == Qt::PrimaryOrientation) {
        nativeOrientation = app.primaryScreen()->primaryOrientation();
    }

    app.engine()->rootContext()->setContextProperty("nativeOrientation", nativeOrientation);
    app.engine()->rootContext()->setContextProperty("fileUtils", fileUtils);
    app.engine()->rootContext()->setContextProperty("mceConnect", mceConnect);
    app.engine()->addImportPath("/usr/lib/qt6/qml");

    qmlRegisterType<GlacierWindowModel>("org.nemomobile.glacier", 1, 0, "GlacierWindowModel");
    qmlRegisterType<MceConnect>("org.nemomobile.glacier", 1, 0, "GlacierMceConnect");
    qmlRegisterType<ControlCenterButtonsModel>("org.nemomobile.glacier", 1, 0, "ControlCenterButtonsModel");
    qmlRegisterType<SearchModel>("org.nemomobile.glacier", 1, 0, "GlacierSearchModel");
#ifdef USE_GEOCLUE2
    app.engine()->rootContext()->setContextProperty("usegeoclue2", true);
    qmlRegisterType<GeoclueAgent>("org.nemomobile.glacier", 1, 0, "GlacierGeoAgent");
#else
    app.engine()->rootContext()->setContextProperty("usegeoclue2", false);
#endif

    if (desktopMode) {
        const QByteArray display = qgetenv("GLACIER_WAYLAND_DISPLAY");
        if (!display.isEmpty()) {
            setenv("WAYLAND_DISPLAY", display.constData(), 1);
        } else {
            setenv("WAYLAND_DISPLAY", "wayland-glacier", 1);
        }
    }

    app.setCompositorPath("/usr/share/glacier-home/qml/GlacierCompositor.qml");
    app.setQmlPath("/usr/share/glacier-home/qml/MainScreen.qml");

    // Give these to the environment inside the lipstick homescreen
    // Fixes a bug where some applications wouldn't launch, eg. terminal or browser
    if (!desktopMode) {
        setenv("EGL_PLATFORM", "wayland", 1);
        setenv("QT_QPA_PLATFORM", "wayland", 1);
        setenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1", 1);
    }
    setenv("QT_VIRTUALKEYBOARD_STYLE", "Nemo", 1);
    setenv("QT_IM_MODULE", "Maliit", 1);

    loadEnvironmentFile("/etc/glacier-home/enveroment.conf");

    if (desktopMode) {
        QByteArray sizeEnv = qgetenv("GLACIER_SIZE");
        if (!sizeEnv.isEmpty()) {
            QStringList parts = QString::fromLocal8Bit(sizeEnv).split('x');
            if (parts.size() == 2) {
                app.mainWindowInstance()->resize(QSize(parts.at(0).toInt(), parts.at(1).toInt()));
            }
        } else {
            app.mainWindowInstance()->resize(QSize(480, 640));
        }
        app.mainWindowInstance()->show();
        if (LipstickCompositor::instance()) {
            QQuickWindow* compWindow = LipstickCompositor::instance()->quickWindow();
            compWindow->hide();
            compWindow->setVisible(false);
            compWindow->setOpacity(0.0);
            compWindow->resize(1, 1);
            compWindow->setPosition(-10000, -10000);
        }
    } else {
        const QByteArray raw(qgetenv("DEBUG_COMPOSITOR_IS_WINDOW"));
        if (raw.startsWith("y")) {
            app.mainWindowInstance()->show();
        } else {
            app.mainWindowInstance()->showFullScreen();
        }
    }

    return app.exec();
}