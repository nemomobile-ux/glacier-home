import QtQuick 2.6
import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0
import QtQuick.Controls.Styles.Nemo 1.0

Item {
    id: contolButton
    property alias image: icon.source
    property alias textLabel: label.text

    property bool activated: false
    property bool connected: false

    signal clicked();

    width: icon.width
    height: icon.height+label.height+size.dp(8)

    Image {
        id: icon
        anchors.centerIn: parent

        sourceSize.width: size.dp(86)
        sourceSize.height: size.dp(86)


        layer.effect: ShaderEffect {
             id: shaderItem
             property color color: activated ?
                                       connected ? Theme.accentColor : Theme.textColor
                                         : Theme.fillColor

             fragmentShader: "
                 varying mediump vec2 qt_TexCoord0;
                 uniform highp float qt_Opacity;
                 uniform lowp sampler2D source;
                 uniform highp vec4 color;
                 void main() {
                     highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                     gl_FragColor = vec4(mix(pixelColor.rgb/max(pixelColor.a, 0.00390625), color.rgb/max(color.a, 0.00390625), color.a) * pixelColor.a, pixelColor.a) * qt_Opacity;
                 }
             "
         }
         layer.enabled: true
         layer.samplerName: "source"

    }

    Text{
        id: label
        anchors{
            top: icon.bottom
            topMargin: size.dp(8)
        }
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 6
        text: textLabel
        color: Theme.textColor
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            contolButton.clicked()
        }
    }
}

