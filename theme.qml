import QtQuick 2.0
import "Components"

FocusScope {
    FontLoader { id: titleFont; source: "assets/fonts/AkzidenzGrotesk-BoldCond.otf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/Gotham-Bold.otf" }
    FontLoader { id: bodyFont; source: "assets/fonts/Montserrat-Medium.otf" }

    property int currentCollectionIndex: 0
    property var currentCollection
    property var currentGame

    property bool muteVideo: false

    property var settings

    BackgroundImage {
        anchors.fill: parent
    }

    GamesView {
        id: gamesView

        focus: true

        anchors.fill: parent
        anchors.leftMargin: vpx(80)
        anchors.rightMargin: vpx(80)

        muted: collectionTransition.pendingCollection != currentCollection
    }

    CollectionTransition {
        id: collectionTransition

        anchors.fill: parent

        pendingCollection: api.collections.get(currentCollectionIndex)
    }


    Component.onCompleted: {
        loadSettings();
    }

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevCollection();
            return;
        }
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextCollection();
            return;
        }
        // if (api.keys.isDetails(event)) {
        //     event.accepted = true;
        //     detailsRequested();
        //     return;
        // }
        // if (api.keys.isFilters(event)) {
        //     event.accepted = true;
        //     filtersRequested();
        //     return;
        // }
    }

    function prevCollection() {
        currentCollectionIndex = (currentCollectionIndex + api.collections.count - 1) % api.collections.count;
    }

    function nextCollection() {
        currentCollectionIndex = (currentCollectionIndex + 1) % api.collections.count;
    }

    function launchGame() {
        api.memory.set('collectionIndex', collectionIndex);
        api.memory.set('gameIndex', grid.gameIndex);
        grid.currentGame.launch();
    }

    function loadSettings() {
        if (api.memory.has('settings')) {
            settings = api.memory.get('settings');
        } else {
            settings = {
                game: {
                    scale: { key: 'Scale', value: 0.95, type: 'real' },
                    scaleSelected: { key: 'Scale - Selected', value: 1.1, type: 'real' },

                    cornerRadius: { key: 'Corner Radius', value: 5, type: 'int' },

                    previewEnabled: { key: 'Video Preview', value: true, type: 'bool' },
                    previewVolume: { key: 'Video Preview Volume', value: 0.5, type: 'real' },

                    logoMargin: { key: 'Logo Margins', value: 30, type: 'int' },
                    logoFontSize: { key: 'Logo Font Size', value: 16, type: 'int' },
                    
                    highlightBorderAnimated: { key: 'Highlight Border Animated', value: true, type: 'bool' },
                    highlightBorderWidth: { key: 'Highlight Border Width', value: 3, type: 'int', },
                    highlightBorderColor1: { key: 'Highlight Border Color 1', value: '#ff9e12', type: 'string' },
                    highlightBorderColor2: { key: 'Highlight Border Color 2', value: '#ffffff', type: 'string' },

                }
            }
        }
    }
}
