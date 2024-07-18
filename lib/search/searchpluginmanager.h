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

#ifndef SEARCHPLUGINMANAGER_H
#define SEARCHPLUGINMANAGER_H

#include "glaciersearchplugin.h"
#include <QMap>
#include <QObject>
#include <QVariant>

class SearchPluginManager : public QObject {
    Q_OBJECT
public:
    explicit SearchPluginManager(QObject* parent = nullptr);
    virtual ~SearchPluginManager();

    void search(QString searchString);

signals:
    void searchResultReady(QList<GlacierSearchPlugin::SearchResult> results);

private slots:
    void loadSearchPlugins();
    void searchResultPluginHandler(QList<GlacierSearchPlugin::SearchResult> results);

private:
    QList<GlacierSearchPlugin*> m_pluginList;
    QList<GlacierSearchPlugin::SearchResult> m_searchResults;
};

#endif // SEARCHPLUGINMANAGER_H
