import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10

import "Components"

import "./utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: titleFont; source: "assets/fonts/SourceSansPro-Bold.ttf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/OpenSans-Bold.ttf" }
    FontLoader { id: bodyFont; source: "assets/fonts/OpenSans-Semibold.ttf" }

    SoundEffect { id: sfxNav; source: "assets/sfx/navigation.wav" }
    SoundEffect { id: sfxBack; source: "assets/sfx/back.wav" }
    SoundEffect { id: sfxAccept; source: "assets/sfx/accept.wav" }
    SoundEffect { id: sfxToggle; source: "assets/sfx/toggle.wav" }

    property var settings: ({
        game: {
            gameViewColumns: { name: 'Number of Columns', value: 3, type: 'int', min: 1 },

            art: {
                name: 'Art',
                value: 0,
                values: ['screenshot', 'boxFront', 'boxBack', 'boxSpine', 'boxFull', 'cartridge', 'marquee', 'bezel', 'panel', 'cabinetLeft', 'cabinetRight', 'tile', 'banner', 'steam', 'poster', 'background', 'titlescreen'],
                type: 'array'
            },

            aspectRatioNative: { name: 'Aspect Ratio - Use Native', value: false, type: 'bool' },
            aspectRatioWidth: { name: 'Aspect Ratio - Width', value: 9.2, delta: 0.1, min: 0.1, type: 'real' },
            aspectRatioHeight: { name: 'Aspect Ratio - Height', value: 4.3, delta: 0.1, min: 0.1, type: 'real' },

            previewEnabled: { name: 'Video Preview - Enabled', value: true, type: 'bool' },
            previewVolume: { name: 'Video Preview - Volume', value: 0.0, delta: 0.1, min: 0.0, type: 'real' },

            borderAnimated: { name: 'Border - Animate', value: true, type: 'bool' },
            borderColor1: { name: 'Border - Color 1', value: '#FFC85C', type: 'string' },
            borderColor2: { name: 'Border - Color 2', value: '#ECECEC', type: 'string' },
            borderWidth: { name: 'Border - Width', value: 5, min: 0, type: 'int', },

            cornerRadius: { name: 'Border - Corner Radius', value: 5, min: 0, type: 'int' },

            scale: { name: 'Scale', value: 0.95, delta: 0.01, min: 0.01, max: 1.0, type: 'real' },
            scaleSelected: { name: 'Scale - Selected', value: 1.0, delta: 0.01, min: 0.01, type: 'real' },


            logoScale: { name: 'Logo - Scale', value: 0.75, delta: 0.01, min: 0.01, type: 'real' },
            logoScaleSelected: { name: 'Logo - Scale - Selected', value: 0.85, delta: 0.01, min: 0.01, type: 'real' },
            logoVisible: { name: 'Logo - Visible', value: true, type: 'bool' },
            previewLogoVisible: { name: 'Logo - Visible - Video Preview', value: true, type: 'bool' },
            logoFontSize: { name: 'Logo - Font Size', value: 16, min: 1, type: 'int' },

            letterNavOpacity: { name: 'Jump to Letter - Background Opacity', value: 0.8, delta: 0.01, min: 0.0, max: 1.0, type: 'real' },
            letterNavSize: { name: 'Jump to Letter - Size', value: 200, type: 'int' },
            letterNavPauseDuration: { name: 'Jump to Letter - Pause Duration (Milliseconds)', value: 400, delta: 50, min: 0, type: 'int' },
            letterNavFadeDuration: { name: 'Jump to Letter - Fade Duration (Milliseconds)', value: 400, delta: 50, min: 0, type: 'int' },
        },
        gameDetails: {
            previewEnabled: { name: 'Video Preview - Enabled', value: true, type: 'bool' },
            previewVolume: { name: 'Video Preview - Volume', value: 0.0, delta: 0.1, min: 0.0, type: 'real' },
        },
        theme: {
            backgroundColor: { name: 'Background Color', value: '#13161B', type: 'string' },
            accentColor: { name: 'Accent Color', value: '#FFC85C', type: 'string' },
            textColor: { name: 'Text Color', value: '#ECECEC', type: 'string' },

            // backgroundColor: { name: 'Background Color', value: '#262A53', type: 'string' },
            // accentColor: { name: 'Accent Color', value: '#FFA0A0', type: 'string' },
            // textColor: { name: 'Text Color', value: '#FFE3E3', type: 'string' },

            leftMargin: { name: 'Screen Padding - Left', value: 60, min: 0, type: 'int' },
            rightMargin: { name: 'Screen Padding - Right', value: 60, min: 0, type: 'int' },
        },
        performance: {
            artImageResolution: { name: 'Art - Image Resolution', value: 0, values: ['Native', 'Scaled'], type: 'array' },
            artImageCaching: { name: 'Art - Image Caching', value: false, type: 'bool' },
            artImageSmoothing: { name: 'Art - Image Smoothing', value: false, type: 'bool' },
            artDropShadow: { name: 'Art - Drop Shadow', value: false, type: 'bool' },

            logoImageResolution: { name: 'Logo - Image Resolution', value: 0, values: ['Native', 'Scaled'], type: 'array' },
            logoImageCaching: { name: 'Logo - Image Caching', value: false, type: 'bool' },
            logoImageSmoothing: { name: 'Logo - Image Smoothing', value: false, type: 'bool' },
            logoDropShadow: { name: 'Logo - Drop Shadow', value: false, type: 'bool' }
        }
    })

    property var stateHistory: []

    property var currentCollection: api.collections.get(0)
    property int currentCollectionIndex: 0

    property var selectedGame
    property var selectedGameHistory: []

    states: [
        State { name: 'gamesView'; PropertyChanges { target: loader; sourceComponent: gamesView } },
        State { name: 'settingsView'; PropertyChanges { target: loader; sourceComponent: settingsView } },
        State { name: 'gameDetailsView'; PropertyChanges { target: loader; sourceComponent: gameDetailsView } }
    ]

    state: 'gamesView'

    Rectangle {
        anchors.fill: parent
        color: settings.theme.backgroundColor.value
    }

    Component {
        id: gamesView
        GamesView { focus: true }
    }

    Component {
        id: settingsView
        SettingsView { focus: true }
    }

    Component {
        id: gameDetailsView
        GameDetailsView { focus: true }
    }

    Loader {
        id: loader
        anchors.fill: parent

        focus: true
        asynchronous: true
    }

    Component.onCompleted: {
        loadSettings();
    }

    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        }

        if (api.keys.isCancel(event)) {
            event.accepted = previousScreen();
        }
    }

    function previousScreen() {
        if (stateHistory.length > 0) {
            sfxBack.play();
            root.state = stateHistory.pop();

            if (selectedGameHistory.length > 0) {
                selectedGame = selectedGameHistory.pop();
            }

            return true;
        }


        return false;
    }

    function toGamesView() {
        sfxAccept.play();
        stateHistory.push(root.state);
        root.state = 'gamesView';
    }

    function toSettingsView() {
        sfxAccept.play();
        stateHistory.push(root.state);
        root.state = 'settingsView';
    }

    function toGameDetailsView(game) {
        sfxAccept.play();
        stateHistory.push(root.state);
        root.state = 'gameDetailsView';

        if (selectedGame) {
            selectedGameHistory.push(selectedGame);
        }

        selectedGame = game;
    }

    function loadSettings() {
        for (const [categoryName, category] of Object.entries(settings)) {
            for (const setting of Object.values(category)) {
                const memoryName = categoryName + setting.name;

                api.memory.set(memoryName, setting.value = api.memory.get(memoryName) ?? setting.value);
                // api.memory.set(memoryName, setting.value);
            }
        }
    }
}
