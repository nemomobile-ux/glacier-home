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
// Copyright (c) 2020-2021, Chupligin Sergey <neochapay@gmail.com>

#include "fileutils.h"

#include <QDateTime>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QTextStream>

FileUtils::FileUtils(QObject* parent)
    : QObject(parent)
{
    if (!QFile::exists(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/lipstick/applications.menu")) {
        makeDefaultMenu();
    }
}

QString FileUtils::getScreenshotPath()
{
    QString screenshotDir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + "/Screenshots";

    QDir scrDir;

    if (!scrDir.exists(screenshotDir)) {
        scrDir.mkpath(screenshotDir);
    }

    QString path = screenshotDir + "/" + tr("Screenshot") + "_" + QDateTime::currentDateTime().toString("ddMMyyyy-hhmmss") + ".png";

    return path;
}

QStringList FileUtils::getBlacklistedApplications()
{
    QStringList blackListedApplications;

    QByteArray blackListFilePath = qgetenv("GLACIER_BLACKLISTAPP_FILE");
    if (blackListFilePath.isEmpty()) {
        qDebug() << "GLACIER_BLACKLISTAPP_FILE env is empty - use default file";
        blackListFilePath = "/etc/glacier/blacklistapp";
    }

    QFile systemBlackListedFile(blackListFilePath);
    if (systemBlackListedFile.exists()) {
        if (systemBlackListedFile.open(QIODevice::ReadOnly)) {
            while (!systemBlackListedFile.atEnd()) {
                QString line = systemBlackListedFile.readLine().replace("\n", "");

                if (line.isEmpty()) {
                    continue;
                }

                if (QFile::exists(line) && line.contains(".desktop")) {
                    blackListedApplications.append(line);
                } else {
                    qWarning() << "Wrong line" << line;
                }
            }
        } else {
            qWarning() << "Can't open blacklist app file" << blackListFilePath;
        }
    } else {
        qDebug() << "Blacklist app file" << blackListFilePath << "not exist";
    }

    return blackListedApplications;
}

void FileUtils::makeDefaultMenu()
{
    QDir lipctickConfigDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/lipstick");
    if (!lipctickConfigDir.exists()) {
        lipctickConfigDir.mkpath(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/lipstick");
    }

    QFile menu(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/lipstick/applications.menu");
    menu.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&menu);
    out << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    out << "<Menu>\n";
    out << "    <Filename>glacier-dialer.desktop</Filename>\n";
    out << "    <Filename>glacier-messages.desktop</Filename>\n";
    out << "    <Filename>glacier-contacts.desktop</Filename>\n";
    out << "    <Filename>glacier-settings.desktop</Filename>\n";
    out << "    <Filename>glacier-camera.desktop</Filename>\n";
    out << "</Menu>\n";
    menu.close();
}
