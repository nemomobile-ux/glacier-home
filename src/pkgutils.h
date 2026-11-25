#ifndef PKGUTILS_H
#define PKGUTILS_H

#include <QObject>

class PkgUtils : public QObject {
    Q_OBJECT
public:
    explicit PkgUtils(QObject* parent = 0);

    Q_INVOKABLE bool uninstallApplication(const QString& desktopFilePath);

signals:
    void packageManagerTransactionStarted();
    void packageManagerActionProgress(const QString& action, const QString& status, double progress);
    void packageManagerTransactionFinished();
};

#endif // PKGUTILS_H
