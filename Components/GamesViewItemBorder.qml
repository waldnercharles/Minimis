import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: root

    property int borderWidth: settings.game.highlightBorderWidth.value
    property string borderColor1: settings.game.highlightBorderColor1.value
    property string borderColor2: settings.game.highlightBorderColor2.value

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
            PauseAnimation { duration: 200 }

            running: settings.game.highlightBorderAnimated.value
        }
    }
}