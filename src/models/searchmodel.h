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

#ifndef SEARCHMODEL_H
#define SEARCHMODEL_H

#include <QAbstractListModel>
#include <QObject>

#include <search/searchpluginmanager.h>

class SearchModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)

public:
    explicit SearchModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    QVariant data(const QModelIndex& index, int role) const;
    QHash<int, QByteArray> roleNames() const { return m_hash; }

    Q_INVOKABLE void search(QString searchString);
    int count() const;

signals:
    void countChanged();

private slots:
    void searchResultHandler(QList<GlacierSearchPlugin::SearchResult> results);

private:
    QHash<int, QByteArray> m_hash;
    SearchPluginManager* m_manager;
    QList<GlacierSearchPlugin::SearchResult> m_searchResults;
};

#endif // SEARCHMODEL_H
