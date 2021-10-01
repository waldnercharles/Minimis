import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
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
    z: currentItem ? currentItem.z - 1 : -1

    color: borderEnabled ? borderColor1 : 'transparent'
    radius: cornerRadius

    SequentialAnimation on color {
        loops: Animation.Infinite
        ColorAnimation { from: borderColor1; to: borderColor2; duration: 500 }
        ColorAnimation { from: borderColor2; to: borderColor1; duration: 500 }
        PauseAnimation { duration: 300 }

        running: borderEnabled && borderAnimated
    }

    layer.enabled: dropShadowEnabled
    layer.effect: DropShadowMedium { }
}