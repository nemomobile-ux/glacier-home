// Copyright (C) 2013 Jolla Ltd.
// Copyright (c) 2022-2023, Chupligin Sergey <neochapay@gmail.com>
// This file is part of glacier-home, a nice user experience for touchscreens.
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

import QtQuick
import QtQml

Item {
    id: wrapper
    width: window.width
    height: window.height

    property Item window

    function animateIn() {
        if(comp.lastClick != null) {
            toX.from = comp.lastClick[0]
            toY.from = comp.lastClick[1]
            openFromIcon.start();
        }
    }

    Component.onCompleted: {
        window.parent = wrapper
    }

    ParallelAnimation{
        id: openFromIcon
        PropertyAnimation{
            target: window
            property: "width"
            from: 0
            to: parent.width
            duration: 300
        }
        PropertyAnimation{
            target: window
            property: "height"
            from: 0
            to: parent.height
            duration: 300
        }
        PropertyAnimation{
            id: toX
            target: wrapper
            property: "x"
            to: 0
            duration: 300
        }
        PropertyAnimation{
            id: toY
            target: wrapper
            property: "y"
            to: 0
            duration: 300
        }
    }
}
