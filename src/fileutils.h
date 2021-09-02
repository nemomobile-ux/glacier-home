#ifndef FILEUTILS_H
#define FILEUTILS_H

#include <QObject>

class FileUtils: public QObject
{
    Q_OBJECT
public:
    explicit FileUtils(QObject *parent = 0);

    Q_INVOKABLE QString getScreenshotPath();
    Q_INVOKABLE QStringList getBlacklistedApplications();
private:
    void makeDefaultMenu();

};

#endif // FILEUTILS_H
