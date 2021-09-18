import QtQuick 2.15
import QtGraphicalEffects 1.0

Rectangle {
    property alias source: crossfade.source
    property bool showBackgroundImage: true

    color: api.memory.get('settings.theme.backgroundColor')

    ImageCrossfade {
        id: crossfade

        anchors.fill: parent

        opacity: showBackgroundImage ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(0, parent.height)
        gradient: Gradient {
            GradientStop { position: 0; color: "#00000000" }
            GradientStop { position: 0.9; color: "#ff000000" }
        }
    }

    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0)
        end: Qt.point(parent.width, 0)
        gradient: Gradient {
            GradientStop { position: 0; color: "#ff000000" }
            GradientStop { position: 1; color: "#00000000" }
        }
    }
}