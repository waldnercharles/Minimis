import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    readonly property alias status: logo.status

    property var game

    property bool isLoading 
    property bool showLogo
    property bool loadOnDemand
    property bool isPlayingPreview
    property bool selected

    readonly property int logoImageResolution: api.memory.get('settings.performance.logoImageResolution')

    Image {
        id: logo
        anchors.fill: parent

        source: opacity != 0 ? game.assets.logo || '' : ''
        sourceSize: logoImageResolution === 0 ? undefined : Qt.size(logo.width, logo.height)

        asynchronous: true
        smooth: api.memory.get('settings.performance.logoImageSmoothing')
        cache: api.memory.get('settings.performance.logoImageCaching')

        fillMode: Image.PreserveAspectFit

        visible: logo.status === Image.Ready && !isLoading

        Behavior on opacity { NumberAnimation { duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.logoFadeSpeed') : 0 } }
        opacity: showLogo ? 1 : 0
    }

    Text {
        id: textLogo

        anchors.fill: parent
        anchors.margins: vpx(10)

        text: game ? game.title || '' : ''
        color: api.memory.get('settings.theme.textColor')

        font.family: subtitleFont.name
        font.pixelSize: vpx(api.memory.get('settings.global.logoFontSize'))
        font.bold: true

        style: Text.Outline;
        styleColor: api.memory.get('settings.theme.backgroundColor')

        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 1.2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        visible: !logo.visible
        opacity: !(loadOnDemand && isPlayingPreview) && isLoading ? 1 : logo.opacity
    }

    Behavior on scale { NumberAnimation { duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.logoScaleSpeed') : 0; } }
    scale: api.memory.get('settings.global.logoScaleEnabled') ? (selected ? api.memory.get('settings.global.logoScaleSelected') : api.memory.get('settings.global.logoScale')) : settingsMetadata.global.logoScale.defaultValue

    layer.enabled: api.memory.get('settings.performance.logoDropShadow')
    layer.effect: DropShadowLow { }
}