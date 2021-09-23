import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property bool selected: false

    property string assetKey;
    property bool logoVisible;
    property bool aspectRatioNative;

    onSelectedChanged: { gameItemVideoPreviewDebouncer.debounce(); }
    
    readonly property bool isPlayingPreview: selected && gameItemPlayVideoPreview
    readonly property bool isLoading: logo.status === Image.Loading || screenshot.status === Image.Loading
    readonly property bool loadOnDemand: logoVisible !== api.memory.get('settings.global.previewLogoVisible')
    readonly property bool showLogo: isPlayingPreview ? (api.memory.get('settings.global.previewLogoVisible') ? 1 : 0) : (logoVisible ? 1 : 0)

    property alias itemWidth: screenshot.width
    property alias itemHeight: screenshot.height

    width: itemWidth
    height: itemHeight

    scale: api.memory.get('settings.global.scaleEnabled') ? (selected ? api.memory.get('settings.global.scaleSelected'): api.memory.get('settings.global.scale')) : settingsMetadata.global.scale.defaultValue
    Behavior on scale { NumberAnimation { duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.animationArtScaleSpeed') : 0; } }

    z: selected ? 255 : 1

    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        }

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            toGameDetailsView(game);
        }
    }

    Rectangle {
        id: grayBackground
        anchors.fill: parent

        color: "#1a1a1a"
        radius: vpx(api.memory.get('settings.global.cornerRadius'))

        opacity: screenshot.opacity

        layer.enabled: !selected && api.memory.get('settings.performance.artDropShadow')
        layer.effect: DropShadowMedium { }
    }

    Image {
        id: screenshot

        source: game.assets[assetKey] || ''
        sourceSize: api.memory.get('settings.performance.artImageResolution') === 0 ? undefined : Qt.size(0, screenshot.height) //((screenshot.width > 0 && screenshot.height > 0) ? Qt.size(screenshot.width, screenshot.height) : undefined)

        asynchronous: true

        cache: api.memory.get('settings.performance.artImageCaching')
        smooth: api.memory.get('settings.performance.artImageSmoothing')

        fillMode: aspectRatioNative ? Image.PreserveAspectFit : Image.PreserveAspectCrop
        visible: screenshot.status === Image.Ready && (logo.status !== Image.Loading || (!logoVisible && api.memory.get('settings.global.previewLogoVisible')))

        opacity: selected && gameItemPlayVideoPreview && game.assets.videoList.length > 0 ? 0 : 1

        Behavior on opacity { NumberAnimation { from: 1; duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.animationArtFadeSpeed') : 0; } }

        layer.enabled: true
        layer.effect: OpacityMask {
            id: mask
            maskSource: Rectangle {
                width: screenshot.width; height: screenshot.height
                radius: vpx(api.memory.get('settings.global.cornerRadius'))
            }
        }
    }

    GameDelegateLogo {
        id: logo
        anchors.fill: parent

        game: root.game
        isLoading: root.isLoading
        showLogo: root.showLogo
        loadOnDemand: root.loadOnDemand
        isPlayingPreview: root.isPlayingPreview
        selected: root.selected
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

            readonly property bool isBookmarked: database.games.get(game).bookmark ?? false // (api.memory.get(`database.bookmarks.${game.collections.get(0).shortName}.${game.title}`) ?? false)

            width: icons.height; height: icons.height;

            text: isBookmarked ? '\uf02e' : ''
            font.family: fontawesome.name
            font.pixelSize: height

            color: api.memory.get('settings.theme.textColor')
            style: Text.Outline; styleColor: api.memory.get('settings.theme.backgroundColor')

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: !!text
        }

        Text {
            id: favoriteIcon
            anchors.verticalCenter: parent.verticalCenter

            width: icons.height; height: icons.height;

            text: game.favorite ? '\uf004' : ''
            font.family: fontawesome.name
            font.pixelSize: height

            color: api.memory.get('settings.theme.textColor')
            style: Text.Outline; styleColor: api.memory.get('settings.theme.backgroundColor')

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: !!text
        }

        layoutDirection: Qt.RightToLeft
    }

    // Rectangle {
    //     id: titleBackground
    //     anchors.centerIn: title;

    //     width: title.contentWidth + title.height * 1.5
    //     height: title.height + gameItemTitlePadding * 2;

    //     radius: height / 2

    //     color: selected ? api.memory.get('settings.theme.backgroundColor') : api.memory.get('settings.theme.textColor')

    //     opacity: selected ? api.memory.get('settings.global.titleBackgroundOpacity') : 0
    //     visible: title.visible
    // }

    Item
    {
        anchors.top: screenshot.bottom
        anchors.left: screenshot.left
        anchors.right: screenshot.right

        opacity: selected ? 1 : 0.2
        visible: api.memory.get('settings.global.titleEnabled') && (api.memory.get('settings.global.titleAlwaysVisible') || selected)

        Text {
            id: title
            anchors.top: parent.top
            anchors.topMargin: (api.memory.get('settings.global.borderEnabled') ? vpx(api.memory.get('settings.global.borderWidth')) : 0) + gameItemTitlePadding

            width: parent.width
            height: gameItemTitleHeight
            color: api.memory.get('settings.theme.textColor')

            text: game ? game.title : ''

            font.family: subtitleFont.name
            font.pixelSize: vpx(api.memory.get('settings.global.titleFontSize'))
            fontSizeMode: Text.VerticalFit

            elide: Text.ElideRight

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            style: Text.Outline
        }

        Text {
            anchors.top: title.bottom
            anchors.topMargin: gameItemTitlePadding * 0.25

            width: parent.width
            height: gameItemTitleHeight
            color: api.memory.get('settings.theme.textColor')

            text: game ? game.releaseYear : ''

            font.family: subtitleFont.name
            font.pixelSize: vpx(api.memory.get('settings.global.titleFontSize'))
            fontSizeMode: Text.VerticalFit

            elide: Text.ElideRight

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            style: Text.Outline
        }
    }

    Rectangle {
        anchors.fill: parent
        color: 'black'
        opacity: selected ? 0.0 : api.memory.get('settings.global.darkenAmount')
    }
}