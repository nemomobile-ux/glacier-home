#ifndef POLKITINTERFACE_H
#define POLKITINTERFACE_H


#include <polkit-qt5-1/PolkitQt1/Agent/Listener>
#include <polkit-qt5-1/PolkitQt1/Identity>
#include <polkit-qt5-1/PolkitQt1/Subject>
#include <QObject>
#include <QDebug>
#include <QDBusConnection>

class PolkitInterface : public PolkitQt1::Agent::Listener
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.lipstick.polkitAuthAgent")

public:
    explicit PolkitInterface(QObject *parent = 0);

signals:

public slots:
    void initiateAuthentication(const QString &actionId,
                                const QString &message,
                                const QString &iconName,
                                const PolkitQt1::Details &details,
                                const QString &cookie,
                                const PolkitQt1::Identity::List &identities,
                                PolkitQt1::Agent::AsyncResult *result);
    bool initiateAuthenticationFinish();
    void cancelAuthentication();

    void sessionRequest(QString request, bool echo);
    void sessionComplete(bool ok);
    void finish();
    void initSession();

    void accepted();
    void rejected();
    void setUser(PolkitQt1::Identity newUser);

private:
};

#endif // POLKITINTERFACE_H
