/*
 * Copyright (C) 2024 Chupligin Sergey <neochapay@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#include "applicationsearchplugin.h"

ApplicationSearchPlugin::ApplicationSearchPlugin(QObject* parent)
    : m_launchModel(new LauncherModel)
{
}

void ApplicationSearchPlugin::search(QString searchString)
{
    m_searchResults.clear();

    for (int i = 0; i < m_launchModel.itemCount(); i++) {
        QObject* item = m_launchModel.get(i);
        if (item->property("title").toString().toLower().indexOf(searchString) != -1
            && !item->property("isBlacklisted").toBool()) {
            SearchResult result;
            result.iconTitle = item->property("title").toString();

            QString iconSource = item->property("iconId").toString();
            if (iconSource.isEmpty()) {
                iconSource = "/usr/share/glacier-home/qml/theme/default-icon.png";
            } else {
                if (iconSource.startsWith("/")) {
                    iconSource = "file://" + iconSource;
                } else if (!iconSource.startsWith("file:///")) {
                    iconSource = "image://theme/" + iconSource;
                }
            }
            result.iconSource = iconSource;

            result.category = tr("Application");
            result.extraCaption = tr("installed on your device");
            QMap<QString, QVariant> action;
            action.insert("type", "exec");
            action.insert("app_id", i);
            result.action = action;

            m_searchResults.push_back(result);
        }
    }

    if (!m_searchResults.isEmpty()) {
        emit searchResultReady(m_searchResults);
    }
}
