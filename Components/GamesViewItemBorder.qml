import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: root

    property int borderWidth: api.memory.get('settings.global.borderEnabled') ? vpx(api.memory.get('settings.global.borderWidth')) : 0
    property string borderColor1: api.memory.get('settings.theme.borderColor1')
    property string borderColor2: api.memory.get('settings.theme.borderColor2')
    property int cornerRadius: vpx(api.memory.get('settings.global.cornerRadius'))

    Rectangle {
        id: border

        anchors.fill: parent
        anchors.margins: -borderWidth

        color: borderColor1
        radius: cornerRadius

        SequentialAnimation on color {
            loops: Animation.Infinite
            ColorAnimation { from: borderColor1; to: borderColor2; duration: 500 }
            ColorAnimation { from: borderColor2; to: borderColor1; duration: 500 }
            PauseAnimation { duration: 300 }

            running: api.memory.get('settings.global.borderAnimated')
        }

        layer.enabled: api.memory.get('settings.performance.artDropShadow')
        layer.effect: DropShadow {
            horizontalOffset: vpx(0); verticalOffset: vpx(4)
            samples: 5
            color: '#77000000';
        }
    }
}