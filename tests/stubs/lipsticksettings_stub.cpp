#include "lipsticksettings_stub.h"

LipstickSettingsStub::LipstickSettingsStub(QObject* parent)
    : QObject { parent }
    , m_lockscreenVisible(true)
{
}

bool LipstickSettingsStub::lockscreenVisible() const
{
    return m_lockscreenVisible;
}

void LipstickSettingsStub::setLockscreenVisible(bool newLockscreenVisible)
{
    if (m_lockscreenVisible == newLockscreenVisible)
        return;
    m_lockscreenVisible = newLockscreenVisible;
    emit lockscreenVisibleChanged();
}
