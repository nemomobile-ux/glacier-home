#ifndef MCECONNECT_H
#define MCECONNECT_H

#include <QObject>

class MceConnect : public QObject
{
    Q_OBJECT
public:
    explicit MceConnect(QObject *parent = 0);

signals:
    void powerKeyPressed();

private slots:
    void getAction(const QString &action);

};

#endif // MCECONNECT_H
