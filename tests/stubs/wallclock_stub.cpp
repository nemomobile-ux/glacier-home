#include "wallclock_stub.h"

WallClockStub::WallClockStub(QObject* parent)
    : QObject { parent }
    , m_time(QDateTime::currentDateTime())
{
}

QDateTime WallClockStub::time() const
{
    return m_time;
}

void WallClockStub::setTime(const QDateTime& newTime)
{
    if (m_time == newTime)
        return;
    m_time = newTime;
    emit timeChanged();
}
