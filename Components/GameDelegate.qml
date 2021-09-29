import QtQuick 2.15
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property bool selected

    property string assetKey
    property bool logoVisible
    readonly property bool logoVisiblePreview: api.memory.get('settings.global.previewLogoVisible')

    property bool aspectRatioNative

    property int sourceDebounceDuration: 500

    property alias itemWidth: screenshot.width
    property alias itemHeight: screenshot.height

    readonly property string textColor: api.memory.get('settings.theme.textColor')
    readonly property string textOutlineColor: 'black'

    readonly property int logoFontSize: vpx(api.memory.get('settings.global.logoFontSize'))

    readonly property bool isPlayingPreview: selected && !videoPreviewDebouncer.running
    readonly property bool isLoading: sourceDebounce.running || screenshot.status === Image.Loading || (logoVisible && logo.status === Image.Loading)

    readonly property bool scaleEnabled: api.memory.get('settings.global.scaleEnabled')
    readonly property real scaleSelected: api.memory.get('settings.global.scaleSelected')
    readonly property real scaleUnselected: api.memory.get('settings.global.scale')

    readonly property bool logoScaleEnabled: api.memory.get('settings.global.logoScaleEnabled')
    readonly property real logoScaleSelected: api.memory.get('settings.global.logoScaleSelected')
    readonly property real logoScaleUnselected: api.memory.get('settings.global.logoScale')

    readonly property bool animationEnabled: api.memory.get('settings.global.animationEnabled')
    readonly property int animationArtScaleDuration: api.memory.get('settings.global.animationArtScaleSpeed')
    readonly property int animationArtFadeDuration: api.memory.get('settings.global.animationArtFadeSpeed')
    readonly property int animationLogoScaleDuration: api.memory.get('settings.global.logoScaleSpeed')
    readonly property int animationLogoFadeDuration: api.memory.get('settings.global.logoFadeSpeed')

    readonly property bool artNativeResolution: api.memory.get('settings.performance.artImageResolution') === 0
    readonly property bool artCached: api.memory.get('settings.performance.artImageCaching')
    readonly property bool artSmoothed: api.memory.get('settings.performance.artImageSmoothing')

    readonly property bool logoNativeResolution: api.memory.get('settings.performance.logoImageResolution') === 0
    readonly property bool logoCached: api.memory.get('settings.performance.logoImageCaching')
    readonly property bool logoSmoothed: api.memory.get('settings.performance.logoImageSmoothing')

    width: screenshot.width
    height: screenshot.height

    scale: scaleEnabled ? (selected ? scaleSelected : scaleUnselected) : settingsMetadata.global.scale.defaultValue
    Behavior on scale { NumberAnimation { duration: animationArtScaleDuration; } enabled: animationEnabled }

    z: selected ? 255 : 1

    onSelectedChanged: { videoPreviewDebouncer.debounce(); }

    layer.enabled: !isLoading
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width; height: root.height
            radius: vpx(api.memory.get('settings.global.cornerRadius'))
        }
    }

    Timer {
        id: sourceDebounce
        interval: sourceDebounceDuration
        onTriggered: {
            screenshot.source = Qt.binding(() => screenshot.src);
            logo.source = Qt.binding(() => logo.src);
        }

        running: true
    }

    Rectangle {
        id: grayBackground;
        anchors.fill: parent;

        color: "#1a1a1a";
        opacity: isPlayingPreview ? 0 : 1
        Behavior on opacity { OpacityAnimator { duration: animationArtFadeDuration; } enabled: animationEnabled && !isLoading  }

        radius: vpx(api.memory.get('settings.global.cornerRadius'))
    }

    Image {
        id: screenshot

        readonly property string src: game.assets[assetKey] || ''
        readonly property bool hasError: status === Image.Error || src == ''

        source: ''
        sourceSize: artNativeResolution ? undefined : Qt.size(0, root.height)

        cache: artCached 
        smooth: artSmoothed
        asynchronous: true

        fillMode: aspectRatioNative ? Image.PreserveAspectFit : Image.PreserveAspectCrop

        visible: !screenshot.hasError

        opacity: isLoading || isPlayingPreview ? 0 : 1
        Behavior on opacity { OpacityAnimator { duration: animationArtFadeDuration; } enabled: animationEnabled && !screenshot.hasError }
    }

    Image {
        id: logo
        anchors.fill: parent

        readonly property string src: (logoVisible || logoVisiblePreview) ? game.assets.logo || '' : ''
        readonly property bool hasError: status === Image.Error || src == ''

        source: ''
        sourceSize: logoNativeResolution ? undefined : Qt.size(logo.width, logo.height)

        cache: logoCached
        smooth: logoSmoothed
        asynchronous: true

        fillMode: Image.PreserveAspectFit

        visible: !logo.hasError

        opacity: !isLoading && (isPlayingPreview ? logoVisiblePreview : logoVisible) ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: animationLogoFadeDuration; } enabled: animationEnabled && !logo.hasError }

        scale: logoScaleEnabled ? (selected ? logoScaleSelected : logoScaleUnselected) : settingsMetadata.global.logoScale.defaultValue
        Behavior on scale { ScaleAnimator { duration: animationLogoScaleDuration } enabled: animationEnabled && !isLoading && !logo.hasError }
    }

    Text {
        id: textLogo
        anchors.fill: parent
        anchors.margins: vpx(10)

        text: game ? game.title || '' : ''
        color: textColor

        font.family: subtitleFont.name
        font.pixelSize: logoFontSize
        font.bold: true

        style: Text.Outline;
        styleColor: textOutlineColor

        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 1.2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        visible: logo.hasError

        opacity: logo.hasError ? logo.opacity : 0
        Behavior on opacity { OpacityAnimator { duration: animationLogoFadeDuration; } enabled: animationEnabled && !isLoading && logo.hasError }
    }

    Row {
        id: icons
        anchors {
            left: parent.left; right: parent.right; top: parent.top;
            rightMargin: margins; topMargin: margins * aspectRatio
        }

        readonly property real margins: vpx(9)
        readonly property real aspectRatio: parent.height / parent.width

        height: vpx(15)
        spacing: height * 0.25

        Text {
            id: bookmarkIcon
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool isBookmarked: !isLoading && (database.games.get(game).bookmark ?? false)

            width: icons.height
            height: icons.height

            text: isBookmarked ? '\uf02e' : ''
            font.family: fontawesome.name
            font.pixelSize: height

            color: textColor
            style: Text.Outline
            styleColor: textOutlineColor

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: !!text
        }

        Text {
            id: favoriteIcon
            anchors.verticalCenter: parent.verticalCenter

            width: icons.height
            height: icons.height

            text: !isLoading && game.favorite ? '\uf004' : ''
            font.family: fontawesome.name
            font.pixelSize: height

            color: textColor
            style: Text.Outline
            styleColor: textOutlineColor

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: !!text
        }

        layoutDirection: Qt.RightToLeft
    }

    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: api.memory.get('settings.global.darkenAmount')
        visible: !selected
    }
}