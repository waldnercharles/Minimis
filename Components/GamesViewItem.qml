import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property bool selected: false
    property bool playPreview: false

    Behavior on scale { NumberAnimation { duration: 100; } }

    scale: selected ? api.memory.get('settings.game.scaleSelected'): api.memory.get('settings.game.scale')
    z: selected ? 3 : 1

    Item {
        id: card

        anchors.fill: parent;

        Rectangle {
            id: grayBackground

            anchors.fill: parent

            color: "#1a1a1a"
            radius: vpx(api.memory.get('settings.game.cornerRadius'))

            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: !screenshot.visible
        }

        Image {
            id: screenshot
            
            property var assetKey: settingsMetadata.game.art.values[api.memory.get('settings.game.art')]

            anchors.fill: parent

            source: modelData.assets[assetKey] || ""
            sourceSize: api.memory.get('settings.performance.artImageResolution')=== 0 ? undefined : Qt.size(screenshot.width, screenshot.height)

            asynchronous: true

            cache: api.memory.get('settings.performance.artImageCaching')
            smooth: api.memory.get('settings.performance.artImageCaching')

            fillMode: api.memory.get('settings.game.aspectRatioNative')? Image.Stretch : Image.PreserveAspectCrop
            visible: screenshot.status === Image.Ready && logo.status !== Image.Loading

            opacity: selected && playPreview && modelData.assets.videos.length > 0 ? 0 : 1

            Behavior on opacity { NumberAnimation { duration: 200 } }

            layer.enabled: true
            layer.effect: OpacityMask {
                id: mask
                maskSource: Rectangle {
                    width: screenshot.width; height: screenshot.height
                    radius: vpx(api.memory.get('settings.game.cornerRadius'))
                }

                layer.enabled: !selected && api.memory.get('settings.performance.artDropShadow')
                layer.effect: DropShadow {
                    anchors.fill: screenshot
                    horizontalOffset: vpx(0); verticalOffset: vpx(3)

                    samples: 4
                    color: '#99000000';
                    source: mask
                }
            }
        }

        Image {
            id: logo
            anchors.fill: parent

            source: modelData.assets.logo || ''
            sourceSize: api.memory.get('settings.performance.logoImageResolution') === 0 ? undefined : Qt.size(logo.width, logo.height)

            asynchronous: true
            smooth: api.memory.get('settings.performance.logoImageSmoothing')

            cache: api.memory.get('settings.performance.logoImageCaching')

            fillMode: Image.PreserveAspectFit

            scale: selected ? api.memory.get('settings.game.logoScaleSelected') : api.memory.get('settings.game.logoScale')
            visible: logo.status === Image.Ready && screenshot.status !== Image.Loading

            opacity: selected && playPreview ? (api.memory.get('settings.game.previewLogoVisible') ? 1 : 0) : (api.memory.get('settings.game.logoVisible') ? 1 : 0)

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 100; } }

            layer.enabled: api.memory.get('settings.performance.logoDropShadow')
            layer.effect: DropShadow {
                anchors.fill: logo

                horizontalOffset: vpx(0); verticalOffset: vpx(4)

                samples: 5
                color: '#75000000'
                source: logo
            }
        }

        Text {
            id: textLogo

            anchors.fill: parent
            anchors.margins: vpx(10)

            text: modelData.title || ''
            color: api.memory.get('settings.theme.textColor')

            font.family: subtitleFont.name
            font.pixelSize: vpx(api.memory.get('settings.game.logoFontSize'))
            font.bold: true

            style: Text.Outline; styleColor: api.memory.get('settings.theme.backgroundColor')

            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            lineHeight: 1.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: !logo.visible
        }
    }
}
