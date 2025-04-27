
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

#include <QFont>
#include <QQmlContext>
#include <QQmlEngine>
#include <QScreen>
#include <QTranslator>

#include <QtCore/qmath.h>

#include <homeapplication.h>
#include <homewindow.h>
#include <lipstickqmlpath.h>

#include "models/controlcenterbuttonsmodel.h"
#include "models/glacierwindowmodel.h"
#include "models/searchmodel.h"

#ifdef USE_GEOCLUE2
#include "geoclueagent.h"
#endif

#include "fileutils.h"
#include "logging.h"
#include "mceconnect.h"

#include "audiocontrol/audioroutemanager.h"

int main(int argc, char** argv)
{
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

    AudioRouteManager* audioRouteManager = new AudioRouteManager();
    FileUtils* fileUtils = new FileUtils();
    MceConnect* mceConnect = new MceConnect();

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
    app.engine()->rootContext()->setContextProperty("audioRouteManager", audioRouteManager);
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

    app.setCompositorPath("/usr/share/glacier-home/qml/GlacierCompositor.qml");
    app.setQmlPath("/usr/share/glacier-home/qml/MainScreen.qml");

    // Give these to the environment inside the lipstick homescreen
    // Fixes a bug where some applications wouldn't launch, eg. terminal or browser
    setenv("EGL_PLATFORM", "wayland", 1);
    setenv("QT_QPA_PLATFORM", "wayland", 1);
    setenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1", 1);
    setenv("QT_VIRTUALKEYBOARD_STYLE", "Nemo", 1);
    setenv("QT_IM_MODULE", "Maliit", 1);

    app.mainWindowInstance()->showFullScreen();
    return app.exec();
}
