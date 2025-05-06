#ifndef LIPSTICKSETTINGS_STUB_H
#define LIPSTICKSETTINGS_STUB_H

#include <QObject>

class LipstickSettingsStub : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool lockscreenVisible READ lockscreenVisible WRITE setLockscreenVisible NOTIFY lockscreenVisibleChanged FINAL)

public:
    explicit LipstickSettingsStub(QObject* parent = nullptr);

    bool lockscreenVisible() const;
    void setLockscreenVisible(bool newLockscreenVisible);

signals:
    void lockscreenVisibleChanged();
private:
    bool m_lockscreenVisible;
};

#endif // LIPSTICKSETTINGS_STUB_H
