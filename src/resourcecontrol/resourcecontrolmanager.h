#ifndef RESOURCECONTROLMANAGER_H
#define RESOURCECONTROLMANAGER_H

#include <QObject>
#include "resourcecontrolservice.h"

class ResourceControlManager : public QObject {
    Q_OBJECT
public:
    explicit ResourceControlManager(QObject* parent = nullptr);

private:
    ResourceControlService* m_resourceControlServce;
};

#endif // RESOURCECONTROLMANAGER_H
