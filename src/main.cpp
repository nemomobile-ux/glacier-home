
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
// Copyright (c) 2018, Chupligin Sergey <neochapay@gmail.com>

#include <QFont>
#include <QQmlEngine>
#include <QQmlContext>
#include <QScreen>
#include <QTranslator>

#include <homewindow.h>
#include <homeapplication.h>
#include <lipstickqmlpath.h>

#include "glacierwindowmodel.h"


int main(int argc, char **argv)
{
    HomeApplication app(argc, argv, QString());

    QTranslator myappTranslator;
    myappTranslator.load(QStringLiteral("/usr/share/lipstick-glacier-home-qt5/translations/glacer-home_%1.qm").arg(QLocale::system().name()));
    app.installTranslator(&myappTranslator);

    QmlPath::append("/usr/share/lipstick-glacier-home-qt5/qml");
    QGuiApplication::setFont(QFont("Open Sans"));
    app.setCompositorPath("/usr/share/lipstick-glacier-home-qt5/qml/compositor.qml");
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
    if (nativeOrientation == Qt::PrimaryOrientation)
        nativeOrientation = app.primaryScreen()->primaryOrientation();
    app.engine()->rootContext()->setContextProperty("nativeOrientation", nativeOrientation);
    qmlRegisterType<GlacierWindowModel>("org.nemomobile.glacier", 1, 0 ,"GlacierWindowModel");
    app.setQmlPath("/usr/share/lipstick-glacier-home-qt5/qml/MainScreen.qml");
    // Give these to the environment inside the lipstick homescreen
    // Fixes a bug where some applications wouldn't launch, eg. terminal or browser
    setenv("EGL_PLATFORM", "wayland", 1);
    setenv("QT_QPA_PLATFORM", "wayland", 1);
    setenv("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1", 1);
    app.mainWindowInstance()->showFullScreen();
    return app.exec();
}

