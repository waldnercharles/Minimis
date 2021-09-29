import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property Item currentItem

    readonly property bool borderEnabled: api.memory.get('settings.global.borderEnabled')
    readonly property bool dropShadowEnabled: api.memory.get('settings.performance.artDropShadow')

    readonly property int borderWidth: borderEnabled ? vpx(api.memory.get('settings.global.borderWidth')) : 0
    readonly property string borderColor1: api.memory.get('settings.global.borderColor1')
    readonly property string borderColor2: api.memory.get('settings.global.borderColor2')
    readonly property bool borderAnimated: api.memory.get('settings.global.borderAnimated') 

    readonly property int cornerRadius: vpx(api.memory.get('settings.global.cornerRadius'))


    anchors.fill: currentItem

    scale: currentItem ? currentItem.scale : 1
    z: currentItem ? currentItem.z - 1 : -1

    Item {
        anchors.fill: parent

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

                running: borderAnimated
            }

            layer.enabled: dropShadowEnabled
            layer.effect: DropShadowMedium { cached: false }
        }
    }
}