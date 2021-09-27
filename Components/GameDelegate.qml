import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property bool selected

    property int itemWidth
    property int itemHeight

    property string assetKey
    property bool logoVisible
    property bool logoVisiblePreview: api.memory.get('settings.global.previewLogoVisible')

    property bool aspectRatioNative

    width: itemWidth
    height: itemHeight

    onSelectedChanged: { videoPreviewDebouncer.debounce(); }

    Timer {
        id: sourceDebounce
        interval: 500
        onTriggered: {
            screenshot.source = Qt.binding(() => screenshot.src);
            logo.source = Qt.binding(() => logo.src);
        }

        running: true
    }

    readonly property string textColor: api.memory.get('settings.theme.textColor')
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

    scale: scaleEnabled ? (selected ? scaleSelected : scaleUnselected) : settingsMetadata.global.scale.defaultValue
    Behavior on scale { NumberAnimation { duration: animationArtScaleDuration; } enabled: animationEnabled }

    z: selected ? 255 : 1

    Rectangle {
        id: grayBackground;
        anchors.fill: parent;

        color: "#1a1a1a";
        opacity: isPlayingPreview ? 0 : 1
        Behavior on opacity { OpacityAnimator { from: 1; duration: animationArtFadeDuration; } enabled: animationEnabled && grayBackground.visible }

        visible: isLoading || screenshot.hasError
    }

    Image {
        id: screenshot
        anchors.fill: parent

        readonly property string src: game.assets[assetKey] || ''
        readonly property string hasError: status === Image.Error || src == ''

        source: ''
        sourceSize: artNativeResolution ? undefined : Qt.size(0, itemHeight)

        cache: artCached 
        smooth: artSmoothed
        asynchronous: true

        fillMode: aspectRatioNative ? Image.PreserveAspectFit : Image.PreserveAspectCrop
        // visible: screenshot.opacity > 0

        opacity: isLoading || isPlayingPreview ? 0 : 1
        Behavior on opacity { OpacityAnimator { duration: animationArtFadeDuration; } enabled: animationEnabled }
    }

    Image {
        id: logo
        anchors.fill: parent

        readonly property string src: (logoVisible || logoVisiblePreview) ? game.assets.logo || '' : ''
        readonly property string hasError: status === Image.Error || src == ''

        source: ''
        sourceSize: logoNativeResolution ? undefined : Qt.size(logo.width, logo.height)

        cache: logoCached
        smooth: logoSmoothed
        asynchronous: true

        fillMode: Image.PreserveAspectFit

        opacity: !isLoading && (isPlayingPreview ? logoVisiblePreview : logoVisible) ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: animationLogoFadeDuration; } enabled: animationEnabled }

        scale: logoScaleEnabled ? (selected ? logoScaleSelected : logoScaleUnselected) : settingsMetadata.global.logoScale.defaultValue
        Behavior on scale { ScaleAnimator { duration: animationLogoScaleDuration } enabled: animationEnabled }
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
        styleColor: 'black'

        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        lineHeight: 1.2
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        opacity: (isLoading || ((logoVisiblePreview || (isPlayingPreview ? logoVisiblePreview : logoVisible)) && logo.hasError)) ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: animationLogoFadeDuration; } enabled: animationEnabled }
    }
}
    
//     readonly property bool isPlayingPreview: selected && !videoPreviewDebouncer.running
//     readonly property bool isLoading: logo.status === Image.Loading || screenshot.status === Image.Loading || debounce.running
//     readonly property bool loadOnDemand: logoVisible !== api.memory.get('settings.global.previewLogoVisible')
//     readonly property bool showLogo: isPlayingPreview ? (api.memory.get('settings.global.previewLogoVisible') ? 1 : 0) : (logoVisible ? 1 : 0)

//     readonly property bool fadeScreenshot: (selected && !videoPreviewDebouncer.running && game.assets.videoList.length > 0);

//     property alias itemWidth: screenshot.width
//     property alias itemHeight: screenshot.height

//     width: itemWidth
//     height: itemHeight

//     scale: api.memory.get('settings.global.scaleEnabled') ? (selected ? api.memory.get('settings.global.scaleSelected'): api.memory.get('settings.global.scale')) : settingsMetadata.global.scale.defaultValue
//     Behavior on scale { NumberAnimation { duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.animationArtScaleSpeed') : 0; } }

//     z: selected ? 255 : 1

//     Keys.onPressed: {
//         if (event.isAutoRepeat) {
//             return;
//         }

//         if (api.keys.isAccept(event)) {
//             event.accepted = true;
//             toGameDetailsView(game);
//         }
//     }

//     Timer {
//         id: debounce
//         interval: 200
//         running: true
//         onTriggered: screenshot.
//     }

//     Rectangle {
//         id: grayBackground
//         anchors.fill: parent

//         color: "#1a1a1a"
//         radius: vpx(api.memory.get('settings.global.cornerRadius'))

//         opacity: fadeScreenshot ? 0 : 1
//         Behavior on opacity { NumberAnimation { from: 1; duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.animationArtFadeSpeed') : 0; } }

//         layer.enabled: !selected && api.memory.get('settings.performance.artDropShadow')
//         layer.effect: DropShadowMedium { source: grayBackground }
//     }

//     Image {
//         id: screenshot

//         sourceSize: api.memory.get('settings.performance.artImageResolution') === 0 ? undefined : Qt.size(0, screenshot.height) //((screenshot.width > 0 && screenshot.height > 0) ? Qt.size(screenshot.width, screenshot.height) : undefined)

//         asynchronous: true

//         cache: api.memory.get('settings.performance.artImageCaching')
//         smooth: api.memory.get('settings.performance.artImageSmoothing')

//         fillMode: aspectRatioNative ? Image.PreserveAspectFit : Image.PreserveAspectCrop
//         visible: screenshot.status === Image.Ready && (logo.status !== Image.Loading || (!logoVisible && api.memory.get('settings.global.previewLogoVisible')))

//         opacity: fadeScreenshot || screenshot.status != Image.Ready || debounce.running ? 0 : 1

//         Behavior on opacity { NumberAnimation { duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.animationArtFadeSpeed') : 0; } }

//         layer.enabled: true
//         layer.effect: OpacityMask {
//             id: mask
//             maskSource: Rectangle {
//                 width: screenshot.width; height: screenshot.height
//                 radius: vpx(api.memory.get('settings.global.cornerRadius'))
//             }
//         }
//     }

//     GameDelegateLogo {
//         id: logo
//         anchors.fill: parent

//         game: root.game
//         isLoading: root.isLoading
//         showLogo: root.showLogo && !debounce.running
//         loadOnDemand: root.loadOnDemand
//         isPlayingPreview: root.isPlayingPreview
//         selected: root.selected
//     }

//     Row {
//         id: icons
//         anchors {
//             left: parent.left; right: parent.right; top: parent.top;
//             rightMargin: margins; topMargin: margins * aspectRatio
//         }

//         readonly property real margins: vpx(9)
//         readonly property real aspectRatio: parent.height / parent.width

//         height: vpx(15)
//         spacing: height * 0.25

//         Text {
//             id: bookmarkIcon
//             anchors.verticalCenter: parent.verticalCenter

//             readonly property bool isBookmarked: database.games.get(game).bookmark ?? false // (api.memory.get(`database.bookmarks.${game.collections.get(0).shortName}.${game.title}`) ?? false)

//             width: icons.height; height: icons.height;

//             text: isBookmarked ? '\uf02e' : ''
//             font.family: fontawesome.name
//             font.pixelSize: height

//             color: api.memory.get('settings.theme.textColor')
//             style: Text.Outline; styleColor: api.memory.get('settings.theme.backgroundColor')

//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter

//             visible: !!text
//         }

//         Text {
//             id: favoriteIcon
//             anchors.verticalCenter: parent.verticalCenter

//             width: icons.height; height: icons.height;

//             text: game.favorite ? '\uf004' : ''
//             font.family: fontawesome.name
//             font.pixelSize: height

//             color: api.memory.get('settings.theme.textColor')
//             style: Text.Outline; styleColor: api.memory.get('settings.theme.backgroundColor')

//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter

//             visible: !!text
//         }

//         layoutDirection: Qt.RightToLeft
//     }

//     // Rectangle {
//     //     id: titleBackground
//     //     anchors.centerIn: title;

//     //     width: title.contentWidth + title.height * 1.5
//     //     height: title.height + gameItemTitlePadding * 2;

//     //     radius: height / 2

//     //     color: selected ? api.memory.get('settings.theme.backgroundColor') : api.memory.get('settings.theme.textColor')

//     //     opacity: selected ? api.memory.get('settings.global.titleBackgroundOpacity') : 0
//     //     visible: title.visible
//     // }

//     Item
//     {
//         anchors.top: screenshot.bottom
//         anchors.left: screenshot.left
//         anchors.right: screenshot.right

//         opacity: selected ? 1 : 0.2
//         visible: api.memory.get('settings.global.titleEnabled') && (api.memory.get('settings.global.titleAlwaysVisible') || selected)

//         Text {
//             id: title
//             anchors.top: parent.top
//             anchors.topMargin: (api.memory.get('settings.global.borderEnabled') ? vpx(api.memory.get('settings.global.borderWidth')) : 0) + gameItemTitlePadding

//             width: parent.width
//             height: gameItemTitleHeight
//             color: api.memory.get('settings.theme.textColor')

//             text: game ? game.title : ''

//             font.family: subtitleFont.name
//             font.pixelSize: vpx(api.memory.get('settings.global.titleFontSize'))
//             fontSizeMode: Text.VerticalFit

//             elide: Text.ElideRight

//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter

//             style: Text.Outline
//         }

//         Text {
//             anchors.top: title.bottom
//             anchors.topMargin: gameItemTitlePadding * 0.25

//             width: parent.width
//             height: gameItemTitleHeight
//             color: api.memory.get('settings.theme.textColor')

//             text: game ? game.releaseYear : ''

//             font.family: subtitleFont.name
//             font.pixelSize: vpx(api.memory.get('settings.global.titleFontSize'))
//             fontSizeMode: Text.VerticalFit

//             elide: Text.ElideRight

//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter

//             style: Text.Outline
//         }
//     }

//     layer.enabled: true
//     layer.effect: ColorOverlay {
//         property real computedOpacity: Math.round(255.0 * api.memory.get('settings.global.darkenAmount'));
//         color: selected ? '#00000000' : `#${computedOpacity.toString(16)}000000`
//     }
// }