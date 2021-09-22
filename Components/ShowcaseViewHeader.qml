import QtQuick 2.3
import QtQml.Models 2.10
import QtGraphicalEffects 1.0

ListView {
    id: root

    height: vpx(40)

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top

        topMargin: height / 2.0
        bottomMargin: height / 2.0
    }

    spacing: vpx(12)

    orientation: ListView.Horizontal
    layoutDirection: Qt.RightToLeft

    model: ObjectModel {
        Button {
            icon: '\uf013'

            width: parent.height; height: parent.height
            circle: true

            selected: root.focus && ListView.isCurrentItem

            onActivated: {
                toSettingsView();
            }
        }

        Button {
            icon: '\uf0b0'
            text: `Filters`

            height: parent.height
            circle: true
            selected: root.focus && ListView.isCurrentItem

            onActivated: {
            }
        }
    }

    Keys.onDownPressed: {
        sfxNav.play();
        showcase.focus = true;
    }

    layer.enabled: true
    layer.effect: DropShadowLow { }
}