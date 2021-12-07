/****************************************************************************************
**
** Copyright (C) 2021 Chupligin Sergey <neochapay@gmail.com>
** All rights reserved.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the author nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

#include "swipewavewidget.h"

SwipeWaveWidget::SwipeWaveWidget(QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_color(QColor(0x00, 0x91, 0xe5))
    , m_active(false)
{
    m_itemSize = size();
    m_init = false;

    setAcceptedMouseButtons(Qt::LeftButton);
    setAcceptHoverEvents(true);

    connect(this, &SwipeWaveWidget::trigered,
            this, &SwipeWaveWidget::resetMainPoint);
}

void SwipeWaveWidget::paint(QPainter *painter)
{
    m_itemSize = size();
    m_c2.setX(m_itemSize.width());
    m_c2.setY(m_itemSize.height()/2);

    if(!m_init) {
        resetMainPoint();
        m_init = true;
    }

    m_endPoint.setX(m_itemSize.width());
    m_endPoint.setY(m_itemSize.height());

    QBrush accentBrush(m_color);

    painter->setPen(Qt::NoPen);
    painter->setRenderHint(QPainter::Antialiasing);

    QPainterPath myPath;
    myPath.moveTo(m_itemSize.width() , 0);
    myPath.quadTo(m_c1, m_endPoint);

    painter->setBrush(accentBrush);
    painter->drawPath(myPath);
}

void SwipeWaveWidget::setActive(bool active)
{
    if(active != m_active) {
        m_active = active;
        emit activeChanged();
    }
}

void SwipeWaveWidget::setColor(QColor color)
{
    if(color != m_color) {
        m_color = color;
        emit colorChanged();
    }
}

void SwipeWaveWidget::mousePressEvent(QMouseEvent *event)
{
    if(!active()) {
        return;
    }
    m_mouseButtonPressed = true;
}

void SwipeWaveWidget::mouseReleaseEvent(QMouseEvent *event)
{
    if(!active()) {
        return;
    }
    m_mouseButtonPressed = false;

    if(m_c1.x() < m_itemSize.width()/4) {
        emit trigered();
    }

    resetMainPoint();
    update();

}

void SwipeWaveWidget::mouseMoveEvent(QMouseEvent *event)
{
    if(!active()) {
        return;
    }

    if(m_mouseButtonPressed) {
        if(event->pos().x() < 0
                || event->pos().y() < 0)
        {
            int x = event->pos().x();
            int y = event->pos().y();

            if(event->pos().x() < 0) {
                x = 0;
            }
            if(event->pos().y() < 0) {
                y = 0;
            }
            setMainPoint(x, y);
        }
        else if (event->pos().x() > m_itemSize.width()
                 || event->pos().y() > m_itemSize.height()) {
            resetMainPoint();
        } else {
            setMainPoint(event->pos().x(), event->pos().y());
        }
        update();
    }
}

void SwipeWaveWidget::touchEvent(QTouchEvent *event)
{
    if(!active()) {
        return;
    }

    m_c1.setX(event->touchPoints().first().pos().x());
    m_c1.setY(event->touchPoints().first().pos().y());
}

void SwipeWaveWidget::setMainPoint(qreal x, qreal y)
{
    m_c1.setX(x);
    m_c1.setY(y);
}

void SwipeWaveWidget::resetMainPoint()
{
    setMainPoint(m_itemSize.width(), m_itemSize.height()/2);
}
