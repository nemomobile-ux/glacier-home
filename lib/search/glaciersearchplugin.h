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

#ifndef GLACIERSEARCHPLUGIN_H
#define GLACIERSEARCHPLUGIN_H

#include <QMap>
#include <QObject>
#include <QVariant>
#include <glacier_global.h>

class GLACIER_EXPORT GlacierSearchPlugin : public QObject {
    Q_OBJECT
public:
    struct SearchResult {
        QString iconTitle;
        QString iconSource;
        QString category;
        QString extraCaption;
        QMap<QString, QVariant> action;
    };

    virtual void search(QString searchString) = 0;
signals:
    void searchResultReady(QList<SearchResult> results);
};
Q_DECLARE_INTERFACE(GlacierSearchPlugin, "GlacierHome.SearchPlugin")

#endif // GLACIERSEARCHPLUGIN_H
