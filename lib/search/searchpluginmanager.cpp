/*
 * Copyright (C) 2024-2025 Chupligin Sergey <neochapay@gmail.com>
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

#include "searchpluginmanager.h"
#include <QDir>
#include <QPluginLoader>
#include <QTimer>

#ifndef INSTALL_LIBDIR
#error INTALLINSTALL_LIBDIR is not set!
#endif

SearchPluginManager::SearchPluginManager(QObject* parent)
    : QObject { parent }
{
    QTimer::singleShot(0, this, SLOT(loadSearchPlugins()));
}

SearchPluginManager::~SearchPluginManager()
{
    foreach (const GlacierSearchPlugin* plugin, m_pluginList) {
        if(plugin == nullptr) {
            disconnect(plugin, &GlacierSearchPlugin::searchResultReady, this, &SearchPluginManager::searchResultPluginHandler);
            delete plugin;
        }
    }
}

void SearchPluginManager::search(QString searchString)
{
    m_searchResults.clear();

    foreach (GlacierSearchPlugin* plugin, m_pluginList) {
        plugin->search(searchString);
    }
}

void SearchPluginManager::loadSearchPlugins()
{
    QDir pluginsDir(QString::fromUtf8(INSTALL_LIBDIR) + "/glacier-home/plugins/search");
    QList<QString> pluginsLibList = pluginsDir.entryList(QDir::Files);

    for (const QString& file : std::as_const(pluginsLibList)) {
        QPluginLoader pluginLoader(pluginsDir.path() + "/" + file);

        QObject* plugin = pluginLoader.instance();
        if (plugin) {
            GlacierSearchPlugin* searchPlugin = qobject_cast<GlacierSearchPlugin*>(plugin);
            if (searchPlugin != nullptr) {
                m_pluginList.push_back(searchPlugin);
                connect(searchPlugin, &GlacierSearchPlugin::searchResultReady, this, &SearchPluginManager::searchResultReady);
            } else {
                qWarning() << "CANT CAST PLIUGIN FROM" << pluginsDir.path() + "/" + file;
            }
        } else {
            delete plugin;
        }
    }
}

void SearchPluginManager::searchResultPluginHandler(QList<GlacierSearchPlugin::SearchResult> results)
{
    m_searchResults.append(results);
    emit searchResultReady(m_searchResults);
}
