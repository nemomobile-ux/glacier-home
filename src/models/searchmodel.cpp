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

#include "searchmodel.h"

SearchModel::SearchModel(QObject* parent)
    : QAbstractListModel { parent }
    , m_manager(new SearchPluginManager(this))
{
    m_hash.insert(Qt::UserRole, QByteArray("iconTitle"));
    m_hash.insert(Qt::UserRole + 1, QByteArray("iconSource"));
    m_hash.insert(Qt::UserRole + 2, QByteArray("category"));
    m_hash.insert(Qt::UserRole + 3, QByteArray("extraCaption"));
    m_hash.insert(Qt::UserRole + 4, QByteArray("action"));

    connect(m_manager.get(), &SearchPluginManager::searchResultReady, this, &SearchModel::searchResultHandler);
}

int SearchModel::rowCount(const QModelIndex& parent) const
{
    return m_searchResults.count();
}

QVariant SearchModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    if (index.row() >= m_searchResults.size()) {
        return QVariant();
    }

    GlacierSearchPlugin::SearchResult result = m_searchResults.at(index.row());
    if (role == Qt::UserRole) {
        return result.iconTitle;
    }
    if (role == Qt::UserRole + 1) {
        return result.iconSource;
    }
    if (role == Qt::UserRole + 2) {
        return result.category;
    }
    if (role == Qt::UserRole + 3) {
        return result.extraCaption;
    }
    if (role == Qt::UserRole + 4) {
        return result.action;
    }

    return QVariant();
}

void SearchModel::search(QString searchString)
{
    m_manager->search(searchString);
}

void SearchModel::searchResultHandler(QList<GlacierSearchPlugin::SearchResult> results)
{
    beginResetModel();
    m_searchResults.clear();
    m_searchResults = results;
    endResetModel();
    emit countChanged();
}

int SearchModel::count() const
{
    return m_searchResults.count();
}
