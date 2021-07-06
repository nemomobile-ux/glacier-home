#include "polkitinterface.h"
#include "polkitagent.h"

PolkitInterface::PolkitInterface(QObject *parent) : PolkitQt1::Agent::Listener(parent)
{
    new PolkitAuthAgentAdaptor(this);
    new PolkitAuthAgentAdaptor(this);
}

void PolkitInterface::initiateAuthentication(const QString &actionId, const QString &message, const QString &iconName, const PolkitQt1::Details &details, const QString &cookie, const PolkitQt1::Identity::List &identities, PolkitQt1::Agent::AsyncResult *result)
{

}

bool PolkitInterface::initiateAuthenticationFinish()
{
    return false;
}

void PolkitInterface::cancelAuthentication()
{

}

void PolkitInterface::sessionRequest(QString request, bool echo)
{

}

void PolkitInterface::sessionComplete(bool ok)
{

}

void PolkitInterface::finish()
{

}

void PolkitInterface::initSession()
{

}

void PolkitInterface::accepted()
{

}

void PolkitInterface::rejected()
{

}

void PolkitInterface::setUser(PolkitQt1::Identity newUser)
{

}
