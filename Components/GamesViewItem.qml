import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game

    property bool selected: false
    property bool playPreview: false

    Item {
        id: card

        anchors.fill: parent;

        Rectangle {
            id: grayBackground

            anchors.fill: parent

            color: "#1a1a1a"
            radius: vpx(api.memory.get('settings.game.cornerRadius'))

            opacity: screenshot.opacity

            layer.enabled: !selected && api.memory.get('settings.performance.artDropShadow')
            layer.effect: DropShadow {
                horizontalOffset: vpx(0); verticalOffset: vpx(4)

                samples: 5
                color: '#99000000';
                cached: true
            }
        }

        Image {
            id: screenshot
            
            property var assetKey: settingsMetadata.game.art.values[api.memory.get('settings.game.art')]

            anchors.fill: parent

            source: game.assets[assetKey] || ''
            sourceSize: api.memory.get('settings.performance.artImageResolution') === 0 ? undefined : Qt.size(screenshot.width, screenshot.height)

            asynchronous: true

            cache: api.memory.get('settings.performance.artImageCaching')
            smooth: api.memory.get('settings.performance.artImageCaching')

            fillMode: api.memory.get('settings.game.aspectRatioNative') ? Image.Stretch : Image.PreserveAspectCrop
            visible: screenshot.status === Image.Ready && (logo.status !== Image.Loading || (!api.memory.get('settings.game.logoVisible') && api.memory.get('settings.game.previewLogoVisible')))

            opacity: selected && playPreview && game.assets.videoList.length > 0 ? 0 : 1

            Behavior on opacity { NumberAnimation { from: 1; duration: api.memory.get('settings.game.artFadeSpeed'); } }

            layer.enabled: true
            layer.effect: OpacityMask {
                id: mask
                maskSource: Rectangle {
                    width: screenshot.width; height: screenshot.height
                    radius: vpx(api.memory.get('settings.game.cornerRadius'))
                }
            }
        }

        Item {
            anchors.fill: parent

            property bool showLogo: selected && playPreview ? (api.memory.get('settings.game.previewLogoVisible') ? 1 : 0) : (api.memory.get('settings.game.logoVisible') ? 1 : 0)

            Image {
                id: logo
                anchors.fill: parent

                source: opacity != 0 ? game.assets.logo || '' : ''
                sourceSize: api.memory.get('settings.performance.logoImageResolution') === 0 ? undefined : Qt.size(logo.width, logo.height)

                asynchronous: true
                smooth: api.memory.get('settings.performance.logoImageSmoothing')
                cache: api.memory.get('settings.performance.logoImageCaching')

                fillMode: Image.PreserveAspectFit

                visible: logo.status === Image.Ready && screenshot.status !== Image.Loading

                Behavior on opacity { NumberAnimation { duration: api.memory.get('settings.game.logoFadeSpeed') } }
                opacity: parent.showLogo ? 1 : 0
            }

            Text {
                id: textLogo

                anchors.fill: parent
                anchors.margins: vpx(10)

                text: game.title || ''
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
                opacity: logo.opacity
            }

            Behavior on scale { NumberAnimation { duration: api.memory.get('settings.game.logoScaleSpeed'); } }
            scale: selected ? api.memory.get('settings.game.logoScaleSelected') : api.memory.get('settings.game.logoScale')


            layer.enabled: api.memory.get('settings.performance.logoDropShadow')
            layer.effect: DropShadow {
                horizontalOffset: vpx(0); verticalOffset: vpx(4)

                samples: 5
                color: '#75000000'
            }
        }

        Row {
            id: icons

            property real margins: vpx(9)
            property real aspectRatio: parent.height / parent.width

            height: parent.width / 15
            anchors {
                left: parent.left; right: parent.right; top: parent.top;
                rightMargin: margins; topMargin: margins * aspectRatio
            }

            spacing: height * 0.25

            Text {
                id: bookmarkIcon

                property bool isBookmarked: (api.memory.get(`database.bookmarks.${currentCollection.shortName}.${game.title}`) ?? false)
                width: icons.height; height: icons.height;
                anchors.verticalCenter: parent.verticalCenter

                text: isBookmarked ? '\uf02e' : ''
                font.family: fontawesome.name
                font.pixelSize: height

                color: api.memory.get('settings.theme.textColor')

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                visible: !!text
            }

            Text {
                id: favoriteIcon

                width: icons.height; height: icons.height;
                anchors.verticalCenter: parent.verticalCenter

                text: game.favorite ? '\uf004' : ''
                font.family: fontawesome.name
                font.pixelSize: height

                color: api.memory.get('settings.theme.textColor')

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                visible: !!text
            }

            layoutDirection: Qt.RightToLeft

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: vpx(0); verticalOffset: vpx(2)
                samples: 2
                color: '#77000000'
            } 
        }
    }
}
