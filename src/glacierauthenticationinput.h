#ifndef GLACIERAUTHENTICATIONINPUT_H
#define GLACIERAUTHENTICATIONINPUT_H
#include <nemo-devicelock/authenticationinput.h>

class GlacierAuthenticationInput: public NemoDeviceLock::AuthenticationInput
{
    Q_OBJECT
public:
    explicit GlacierAuthenticationInput(QObject *parent = nullptr)
        : NemoDeviceLock::AuthenticationInput(DeviceLock, parent)
    {
    }
};

#endif // GLACIERAUTHENTICATIONINPUT_H
