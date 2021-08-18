import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: root

    property int borderWidth: settings.game.borderWidth.value
    property string borderColor1: settings.theme.accentColor.value
    property string borderColor2: 'white'

    property int cornerRadius: vpx(settings.game.cornerRadius.value)

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

            running: settings.game.borderAnimated.value
        }
    }
}