// This file is part of glacier-home, a nice user experience for NemoMobile.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2020, Chupligin Sergey <neochapay@gmail.com>
#include <QDebug>

#include "bluetoothagent.h"

#if BLUEZQT_VERSION_MAJOR == 5 && BLUEZQT_VERSION_MINOR < 68
# include <device.h>
# include <initmanagerjob.h>
#else
# include <bluezqt/device.h>
# include <bluezqt/initmanagerjob.h>
#endif

BluetoothAgent::BluetoothAgent(QObject *parent)
    : BluezQt::Agent(parent)
{
    m_connected = false;
    m_manager = new BluezQt::Manager(this);

    BluezQt::InitManagerJob *job = m_manager->init();
    job->start();

    connect(job, &BluezQt::InitManagerJob::result,
            this, &BluetoothAgent::initManagerJobResult);

    connect(m_manager,&BluezQt::Manager::usableAdapterChanged,
            this, &BluetoothAgent::usableAdapterChanged);

    usableAdapterChanged(m_usableAdapter);
}

QDBusObjectPath BluetoothAgent::objectPath() const
{
    return QDBusObjectPath(QStringLiteral("/org/glacier/btagent"));
}

BluezQt::Agent::Capability BluetoothAgent::capability() const
{
    return DisplayYesNo;
}

void BluetoothAgent::registerAgent()
{
    BluezQt::PendingCall *call = m_manager->registerAgent(this);

    qDebug() << "BT: bt agent registring";

    connect(call, &BluezQt::PendingCall::finished,
            this, &BluetoothAgent::registerAgentFinished);

}

void BluetoothAgent::pair(const QString &btMacAddress)
{
    BluezQt::DevicePtr device = m_manager->deviceForAddress(btMacAddress);
    if(!device)
    {
        qWarning() << "BT: Device not found";
        return;
    }

#if BLUEZQT_VERSION_MAJOR == 5 && BLUEZQT_VERSION_MINOR < 68
    BluezQt::PendingCall *pcall = m_manager->pairWithDevice(btMacAddress);
#else
    BluezQt::PendingCall *pcall = device->pair();
#endif
    pcall->setUserData(btMacAddress);

    connect(pcall, &BluezQt::PendingCall::finished,
            this, &BluetoothAgent::connectToDevice);
}

void BluetoothAgent::connectDevice(const QString &btMacAddress)
{
    BluezQt::DevicePtr device = m_manager->deviceForAddress(btMacAddress);
    if(!device)
    {
        qWarning() << "BT: Device not found";
        return;
    }

    device->connectToDevice();
}

void BluetoothAgent::connectToDevice(BluezQt::PendingCall *call)
{
    QString btMacAddress = call->userData().toString();
    if(!call->error()) {
        BluezQt::DevicePtr device = m_manager->deviceForAddress(btMacAddress);
        if(device) {
           device->connectToDevice();
        }
    }
}

void BluetoothAgent::unPair(const QString &btMacAddress)
{
    BluezQt::DevicePtr device = m_manager->deviceForAddress(btMacAddress);
    if(!device)
    {
        return;
    }

    m_usableAdapter->removeDevice(device);
}

void BluetoothAgent::usableAdapterChanged(BluezQt::AdapterPtr adapter)
{
    if(adapter && m_usableAdapter != adapter)
    {
        emit adapterAdded(adapter);
        m_usableAdapter = adapter;

#if BLUEZQT_VERSION_MAJOR == 5 && BLUEZQT_VERSION_MINOR < 68
	connect(m_usableAdapter.data(), &BluezQt::Adapter::connectedChanged,
		this, &BluetoothAgent::updateConnectedStatus);
#else
        connect(m_usableAdapter.data(), &BluezQt::Adapter::deviceChanged,
                this, &BluetoothAgent::updateConnectedStatus);
#endif
        updateConnectedStatus();
    }
}

void BluetoothAgent::requestConfirmation(BluezQt::DevicePtr device, const QString &passkey, const BluezQt::Request<> &request)
{
    Q_UNUSED(request);

    emit showRequiesDialog(device->address() ,
                           device->name() ,
                           passkey);
}

void BluetoothAgent::initManagerJobResult(BluezQt::InitManagerJob *job)
{
    if (job->error())
    {
        qWarning() << "Error initializing Bluetooth manager:" << job->errorText();
    }
}

void BluetoothAgent::registerAgentFinished(BluezQt::PendingCall *call)
{
    if (call->error())
    {
        qWarning() << "BT: registerAgent() call failed:" << call->errorText();
        return;
    }

    BluezQt::PendingCall *pcall = m_manager->requestDefaultAgent(this);
    connect(pcall, &BluezQt::PendingCall::finished,
            this, &BluetoothAgent::requestDefaultAgentFinished);

}

void BluetoothAgent::requestDefaultAgentFinished(BluezQt::PendingCall *call)
{
    if (call->error())
    {
        qWarning() << "BT: requestDefaultAgent() call failed:" << call->errorText();
    }
     qDebug() << "BT: bt agent registring as system" << objectPath().path();
}

void BluetoothAgent::updateConnectedStatus()
{
#if BLUEZQT_VERSION_MAJOR == 5 && BLUEZQT_VERSION_MINOR < 68
    if(m_connected != m_usableAdapter->isConnected())
    {
        m_connected = m_usableAdapter->isConnected();
#else
    bool isSomebodyConnected = false;
    for (const auto &device : m_usableAdapter->devices()) {
        if (device->isConnected()) {
            isSomebodyConnected = true;
            break;
        }
    }
    
    if(m_connected != isSomebodyConnected)
    {
        m_connected = isSomebodyConnected;
#endif
        emit connectedChanged();
    }
}

bool BluetoothAgent::isConnected()
{
    return m_connected;
}

