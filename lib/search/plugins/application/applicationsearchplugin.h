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

#ifndef APPLICATIONSEARCHPLUGIN_H
#define APPLICATIONSEARCHPLUGIN_H

#include <lipstick-qt6/launchermodel.h>
#include <search/glaciersearchplugin.h>

class ApplicationSearchPlugin : public GlacierSearchPlugin {
    Q_OBJECT
    Q_INTERFACES(GlacierSearchPlugin)
    Q_PLUGIN_METADATA(IID "GlacierHome.SearchPlugin")
public:
    explicit ApplicationSearchPlugin(QObject* parent = nullptr);
    void search(QString searchString);

private:
    LauncherModel m_launchModel;
    QList<SearchResult> m_searchResults;
};

#endif // APPLICATIONSEARCHPLUGIN_H
