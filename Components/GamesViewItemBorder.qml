import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: root

    property int borderWidth: api.memory.get('settings.game.borderWidth')
    property string borderColor1: api.memory.get('settings.game.borderColor1')
    property string borderColor2: api.memory.get('settings.game.borderColor2')
    property int cornerRadius: vpx(api.memory.get('settings.game.cornerRadius'))

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

            running: api.memory.get('settings.game.borderAnimated')
        }

        layer.enabled: api.memory.get('settings.performance.artDropShadow')
        layer.effect: DropShadow {
            anchors.fill: border
            horizontalOffset: vpx(0); verticalOffset: vpx(3)

            samples: 4
            color: '#99000000';
            source: border
        }
    }
}