/*
 * Copyright (C) 2021 Chupligin Sergey <neochapay@gmail.com>
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

#include <QtQml>
#include <QtGlobal>
#include <QQmlEngine>
#include <QQmlExtensionPlugin>

#include "../models/glacierwindowmodel.h"
#include "../mceconnect.h"
#include "../geoagent.h"
#include "../models/controlcenterbuttonsmodel.h"

class Q_DECL_EXPORT NemomobileGlacierPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.nemomobile.glacier")
public:
    virtual ~NemomobileGlacierPlugin() { }

    void initializeEngine(QQmlEngine *, const char *uri)
    {
        Q_ASSERT(uri == QLatin1String("org.nemomobile.glacier"));
        qmlRegisterModule(uri, 1, 0);
    }

    void registerTypes(const char *uri)
    {
        Q_ASSERT(uri == QLatin1String("org.nemomobile.glacier"));
        qmlRegisterType<GlacierWindowModel>(uri, 1, 0 ,"GlacierWindowModel");
        qmlRegisterType<MceConnect>(uri, 1, 0, "GlacierMceConnect");
        qmlRegisterType<GeoclueAgent>(uri, 1, 0, "GlacierGeoAgent");
        qmlRegisterType<ControlCenterButtonsModel>(uri, 1, 0, "ControlCenterButtonsModel");
    }
};

#include "plugin.moc"
