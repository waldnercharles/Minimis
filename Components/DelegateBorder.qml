import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property Item currentItem

    readonly property bool borderEnabled: api.memory.get('settings.cardTheme.borderEnabled')
    readonly property bool dropShadowEnabled: true // api.memory.get('settings.performance.artDropShadow')

    readonly property int borderWidth: borderEnabled ? vpx(api.memory.get('settings.cardTheme.borderWidth')) : 0
    readonly property string borderColor1: api.memory.get('settings.cardTheme.borderColor1')
    readonly property string borderColor2: api.memory.get('settings.cardTheme.borderColor2')
    readonly property bool borderAnimated: api.memory.get('settings.cardTheme.borderAnimated') 

    readonly property int cornerRadius: vpx(api.memory.get('settings.cardTheme.cornerRadius'))

    anchors.fill: currentItem
    anchors.margins: -borderWidth

    scale: currentItem ? currentItem.scale : 1
    
    // NOTE: Originally the border was displayed below the item,
    // but now we make the middle of it transparent so that we can fix
    // a bug with how OpacityMask works with Video
    z: currentItem ? currentItem.z + 1 : 1

    Item {
        id: mask

        anchors.fill: parent
        
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            anchors.margins: borderWidth
            radius: cornerRadius
        }
        visible: false
    }
    
    Rectangle {
        anchors.fill: parent

        color: borderEnabled ? borderColor1 : 'transparent'
        radius: cornerRadius

        SequentialAnimation on color {
            loops: Animation.Infinite
            ColorAnimation { from: borderColor1; to: borderColor2; duration: 500 }
            ColorAnimation { from: borderColor2; to: borderColor1; duration: 500 }
            PauseAnimation { duration: 300 }

            running: borderEnabled && borderAnimated
        }

        layer.enabled: true

        // Opacity mask didn't work...
        layer.effect: ShaderEffect {
            property var source
            property var maskSource: mask

            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform highp float qt_Opacity;
                uniform lowp sampler2D source;
                uniform lowp sampler2D maskSource;

                void main(void) {
                    gl_FragColor = texture2D(source, qt_TexCoord0.st) * (1.0 - texture2D(maskSource, qt_TexCoord0.st).w) * qt_Opacity;
                }
            "
        }
    }
}