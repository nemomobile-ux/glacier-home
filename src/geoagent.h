/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp -l GeoclueAgent -i geoclueagent.h -a geoagent.h: src/org.freedesktop.GeoClue2.Agent.xml
 *
 * qdbusxml2cpp is Copyright (C) 2020 The Qt Company Ltd.
 *
 * This is an auto-generated file.
 * This file may have been hand-edited. Look for HAND-EDIT comments
 * before re-generating it.
 */

#ifndef GEOAGENT_H
#define GEOAGENT_H

#include "geoclueagent.h"
#include <QtCore/QObject>
#include <QtDBus/QtDBus>
QT_BEGIN_NAMESPACE
class QByteArray;
template <class T>
class QList;
template <class Key, class Value>
class QMap;
class QString;
class QStringList;
class QVariant;
QT_END_NAMESPACE

/*
 * Adaptor class for interface org.freedesktop.GeoClue2.Agent
 */
class AgentAdaptor : public QDBusAbstractAdaptor {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.GeoClue2.Agent")
    Q_CLASSINFO("D-Bus Introspection", ""
                                       "  <interface name=\"org.freedesktop.GeoClue2.Agent\">\n"
                                       "    <property access=\"read\" type=\"u\" name=\"MaxAccuracyLevel\"/>\n"
                                       "    <method name=\"AuthorizeApp\">\n"
                                       "      <arg direction=\"in\" type=\"s\" name=\"desktop_id\"/>\n"
                                       "      <arg direction=\"in\" type=\"u\" name=\"req_accuracy_level\"/>\n"
                                       "      <arg direction=\"out\" type=\"b\" name=\"authorized\"/>\n"
                                       "      <arg direction=\"out\" type=\"u\" name=\"allowed_accuracy_level\"/>\n"
                                       "    </method>\n"
                                       "  </interface>\n"
                                       "")
public:
    AgentAdaptor(GeoclueAgent* parent);
    virtual ~AgentAdaptor();

    inline GeoclueAgent* parent() const
    {
        return static_cast<GeoclueAgent*>(QObject::parent());
    }

public: // PROPERTIES
    Q_PROPERTY(uint MaxAccuracyLevel READ maxAccuracyLevel)
    uint maxAccuracyLevel() const;

public Q_SLOTS: // METHODS
    void AuthorizeApp(const QString& desktop_id, uint req_accuracy_level, bool& authorized, uint& allowed_accuracy_level);
Q_SIGNALS: // SIGNALS
};

#endif
