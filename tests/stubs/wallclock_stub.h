#ifndef WALLCLOCK_STUB_H
#define WALLCLOCK_STUB_H

#include <QDateTime>
#include <QObject>

class WallClockStub  : public QObject  {
    Q_OBJECT
    Q_PROPERTY(QDateTime time READ time WRITE setTime NOTIFY timeChanged FINAL)
public:
    explicit WallClockStub(QObject* parent = nullptr);
    QDateTime time() const;
    void setTime(const QDateTime &newTime);

signals:
    void timeChanged();

private:
    QDateTime m_time;
};

#endif // WALLCLOCK_STUB_H
