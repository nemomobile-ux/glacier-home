#include "pkgutils.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QFileInfo>

#include "logging.h"

PkgUtils::PkgUtils(QObject* parent)
    : QObject(parent)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.connect(QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("/org/nemomobile/glacier/packagemanager"),
        QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("TransactionStarted"),
        this, SIGNAL(packageManagerTransactionStarted()));

    bus.connect(QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("/org/nemomobile/glacier/packagemanager"),
        QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("ActionProgress"),
        this, SIGNAL(packageManagerActionProgress(QString, QString, double)));

    bus.connect(QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("/org/nemomobile/glacier/packagemanager"),
        QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("TransactionFinished"),
        this, SIGNAL(packageManagerTransactionFinished()));
}

bool PkgUtils::uninstallApplication(const QString& desktopFilePath)
{
    if (desktopFilePath.isEmpty()) {
        return false;
    }

    QDBusInterface pm(QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QStringLiteral("/org/nemomobile/glacier/packagemanager"),
        QStringLiteral("org.nemomobile.glacier.packagemanager"),
        QDBusConnection::sessionBus());
    pm.setTimeout(5000);

    if (!pm.isValid()) {
        qCWarning(lcGlacierHomeCoreLog) << "Package manager DBus interface unavailable";
        return false;
    }

    QDBusReply<QVariantMap> findReply = pm.call(QStringLiteral("FindPackageByFile"), desktopFilePath);
    if (!findReply.isValid()) {
        qCWarning(lcGlacierHomeCoreLog) << "FindPackageByFile DBus call failed" << findReply.error().message();
        return false;
    }

    const QVariantMap pkg = findReply.value();
    const QString name = pkg.value(QStringLiteral("name")).toString();
    const QString repo = pkg.value(QStringLiteral("repo")).toString();
    if (name.isEmpty()) {
        qCWarning(lcGlacierHomeCoreLog) << "Package not found for" << desktopFilePath;
        return false;
    }

    QDBusReply<void> removeReply = pm.call(QStringLiteral("Remove"), name, repo);
    if (!removeReply.isValid()) {
        qCWarning(lcGlacierHomeCoreLog) << "Remove DBus call failed" << removeReply.error().message();
        return false;
    }

    return true;
}
