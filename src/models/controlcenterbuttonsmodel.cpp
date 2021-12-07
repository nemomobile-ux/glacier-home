/****************************************************************************************
**
** Copyright (C) 2021 Chupligin Sergey <neochapay@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

#include "controlcenterbuttonsmodel.h"
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QXmlStreamWriter>

ControlCenterButtonsModel::ControlCenterButtonsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    hash.insert(Qt::UserRole ,QByteArray("path"));
    m_configFilePath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/lipstick/controlcenter.menu";
    if(!QFile::exists(m_configFilePath)) {
        loadDefaultConfig();
    } else {
        loadConfig();
    }
}

int ControlCenterButtonsModel::rowCount(const QModelIndex &parent) const
{
    return m_buttonList.size();
}

QVariant ControlCenterButtonsModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role);
    if (!index.isValid())
        return QVariant();

    if (index.row() >= m_buttonList.size())
        return QVariant();

    QString item = m_buttonList.at(index.row());

    if(role == Qt::UserRole)
        return item;

    return QVariant();
}

QStringList ControlCenterButtonsModel::allButtons()
{
    /*
    * All button must be here /usr/share/lipstick-glacier-home-qt5/qml/feedspage/
    * and name must be <SomeThing>ControlButton.qml
    */
    QStringList allButtons;
    QDir directory("/usr/share/lipstick-glacier-home-qt5/qml/feedspage/");
    QStringList controlButtons = directory.entryList(QStringList() << "*?ControlButton.qml" , QDir::Files);
    foreach(QString filename, controlButtons) {
        allButtons << filename.remove(".qml");
    }
    return allButtons;
}

void ControlCenterButtonsModel::loadDefaultConfig()
{
    m_buttonList
            << "WiFiControlButton"
            << "BluetoothControlButton"
            << "CellularDataControlButton"
            << "LocationControlButton"
            << "QuietControlButton";
    saveConfig();
}

void ControlCenterButtonsModel::loadConfig()
{
    QFile config(m_configFilePath);
    if(!config.open(QFile::ReadOnly | QFile::Text)) {
        qWarning() << "Can't read config" << m_configFilePath;
        return;
    }

    QXmlStreamReader xmlReader;
    xmlReader.setDevice(&config);
    xmlReader.readNext();

    while(!xmlReader.atEnd()) {
        if(xmlReader.isStartElement()) {
            if(xmlReader.name() == "Button") {
                m_buttonList << xmlReader.readElementText();
            }
        }
        xmlReader.readNext();
    }
    config.close();
}

void ControlCenterButtonsModel::saveConfig()
{
    QFile config(m_configFilePath);
    config.open(QIODevice::WriteOnly);

    QXmlStreamWriter xmlWriter(&config);
    xmlWriter.setAutoFormatting(true);
    xmlWriter.writeStartDocument();
    xmlWriter.writeStartElement("Menu");

    foreach(const QString button, m_buttonList) {
        xmlWriter.writeStartElement("Button");
        xmlWriter.writeCharacters(button);
        xmlWriter.writeEndElement();
    }

    xmlWriter.writeEndElement();
    xmlWriter.writeEndDocument();
    config.close();
}
