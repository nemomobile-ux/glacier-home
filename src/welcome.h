#ifndef WELCOME_H
#define WELCOME_H

#include <QDBusInterface>
#include <QObject>

class Welcome: public QObject
{
    Q_OBJECT
public:
    Welcome();
    Q_INVOKABLE void startWelcome();
    Q_INVOKABLE void endWelcome();
    Q_INVOKABLE bool isFirstRun();
private:
    bool m_needToStart;
    QDBusInterface *m_mceDbus;
};

#endif // WELCOME_H
