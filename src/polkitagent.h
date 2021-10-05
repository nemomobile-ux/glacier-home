/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp -a polkitagent.h: ../interfaces/org.lipstick.polkitAuthAgent.xml
 *
 * qdbusxml2cpp is Copyright (C) 2020 The Qt Company Ltd.
 *
 * This is an auto-generated file.
 * This file may have been hand-edited. Look for HAND-EDIT comments
 * before re-generating it.
 */

#ifndef POLKITAGENT_H
#define POLKITAGENT_H

#include <QtCore/QObject>
#include <QtDBus/QtDBus>
QT_BEGIN_NAMESPACE
class QByteArray;
template<class T> class QList;
template<class Key, class Value> class QMap;
class QString;
class QStringList;
class QVariant;
QT_END_NAMESPACE

/*
 * Adaptor class for interface org.lipstick.polkitAuthAgent
 */
class PolkitAuthAgentAdaptor: public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.nemomobile.lipstick.polkitAuthAgent")
    Q_CLASSINFO("D-Bus Introspection", ""
"  <interface name=\"org.nemomobile.lipstick.polkitAuthAgent\">\n"
"    <method name=\"initiateAuthenticationFinish\">\n"
"      <arg direction=\"out\" type=\"b\"/>\n"
"    </method>\n"
"    <method name=\"cancelAuthentication\"/>\n"
"    <method name=\"sessionRequest\">\n"
"      <arg direction=\"in\" type=\"s\" name=\"request\"/>\n"
"      <arg direction=\"in\" type=\"b\" name=\"echo\"/>\n"
"    </method>\n"
"    <method name=\"sessionComplete\">\n"
"      <arg direction=\"in\" type=\"b\" name=\"ok\"/>\n"
"    </method>\n"
"    <method name=\"finish\"/>\n"
"    <method name=\"initSession\"/>\n"
"    <method name=\"accepted\"/>\n"
"    <method name=\"rejected\"/>\n"
"  </interface>\n"
        "")
public:
    PolkitAuthAgentAdaptor(QObject *parent);
    virtual ~PolkitAuthAgentAdaptor();

public: // PROPERTIES
public Q_SLOTS: // METHODS
    void accepted();
    void cancelAuthentication();
    void finish();
    void initSession();
    bool initiateAuthenticationFinish();
    void rejected();
    void sessionComplete(bool ok);
    void sessionRequest(const QString &request, bool echo);
Q_SIGNALS: // SIGNALS
};

#endif
