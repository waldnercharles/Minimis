import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10

import "Components"

import "./utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: fontawesome; source: "assets/fonts/Fontawesome.otf" }
    FontLoader { id: titleFont; source: "assets/fonts/SourceSansPro-Bold.ttf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/OpenSans-Bold.ttf" }
    FontLoader { id: bodyFont; source: "assets/fonts/OpenSans-Semibold.ttf" }

    SoundEffect { id: sfxNav; source: "assets/sfx/navigation.wav" }
    SoundEffect { id: sfxBack; source: "assets/sfx/back.wav" }
    SoundEffect { id: sfxAccept; source: "assets/sfx/accept.wav" }
    SoundEffect { id: sfxToggle; source: "assets/sfx/toggle.wav" }

    property var settingsMetadata: ({
        global: ({
            videoPreview: ({ name: 'Video Preview', defaultValue: false, type: 'header' }),
            previewEnabled: ({
                name: 'Enabled', defaultValue: true, type: 'bool',
                parent: 'videoPreview', inset: 1,
            }),
            previewVolume: ({
                name: 'Volume', defaultValue: 0.5, delta: 0.1, min: 0.0, max: 1.0, type: 'real',
                parent: 'videoPreview', inset: 2,
                isEnabled: () => api.memory.get('settings.global.previewEnabled')
            }),
            videoPreviewDelay: ({
                name: 'Delay', defaultValue: 1000, min: 0, delta: 50, type: 'int',
                parent: 'videoPreview', inset: 2,
                isEnabled: () => api.memory.get('settings.global.previewEnabled')
            }),
            previewLogoVisible: ({
                name: 'Logo - Visible', defaultValue: true, type: 'bool',
                parent: 'videoPreview', inset: 2,
                isEnabled: () => api.memory.get('settings.global.previewEnabled')
            }),

            title: ({ name: 'Title', defaultValue: false, type: 'header' }),
            titleEnabled: ({
                name: 'Enabled', defaultValue: true, type: 'bool',
                parent: 'title', inset: 1,
            }),
            titleAlwaysVisible: ({
                name: 'Always Visible', defaultValue: true, type: 'bool',
                parent: 'title', inset: 2,
                isEnabled: () => api.memory.get('settings.global.titleEnabled')
            }),
            titleFontSize: ({
                name: 'Font Size', defaultValue: 16, type: 'int',
                parent: 'title', inset: 2,
                isEnabled: () => api.memory.get('settings.global.titleEnabled')
            }),
            titleBackgroundOpacity: ({
                name: 'Background Opacity', defaultValue: 0.05, delta: 0.01, min: 0.0, max: 1.0, type: 'real',
                parent: 'title', inset: 2,
                isEnabled: () => api.memory.get('settings.global.titleEnabled')
            }),

            scaling: ({ name: 'Scaling', defaultValue: false, type: 'header' }),
            scaleEnabled: ({
                name: 'Card Scaling - Enabled', defaultValue: true, type: 'bool',
                parent: 'scaling', inset: 1,
            }),
            scale: ({
                name: 'Card Scaling - Default', defaultValue: 0.95, delta: 0.01, min: 0, max: 1.0, type: 'real',
                parent: 'scaling', inset: 2,
                isEnabled: () => api.memory.get('settings.global.scaleEnabled')
            }),
            scaleSelected: ({
                name: 'Card Scaling - Selected', defaultValue: 1.0, delta: 0.01, min: 0, type: 'real',
                parent: 'scaling', inset: 2,
                isEnabled: () => api.memory.get('settings.global.scaleEnabled')
            }),
            logoScaleEnabled: ({
                name: 'Logo Scaling - Enabled', defaultValue: true, type: 'bool',
                parent: 'scaling', inset: 1,
            }),
            logoScale: ({
                name: 'Logo Scaling - Default', defaultValue: 0.75, delta: 0.01, min: 0.01, type: 'real',
                parent: 'scaling', inset: 2,
            }),
            logoScaleSelected: ({
                name: 'Logo Scaling - Selected', defaultValue: 0.75, delta: 0.01, min: 0, type: 'real',
                parent: 'scaling', inset: 2,
            }),

            animation: ({ name: 'Animation', defaultValue: false, type: 'header' }),
            animationEnabled: ({
                name: 'Enabled', defaultValue: true, type: 'bool',
                parent: 'animation', inset: 1
            }),
            animationArtScaleSpeed: ({
                name: 'Scale Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
                parent: 'animation', inset: 2,
                isEnabled: () => api.memory.get('settings.global.animationEnabled')
            }),
            animationArtFadeSpeed: ({
                name: 'Fade Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
                parent: 'animation', inset: 2,
                isEnabled: () => api.memory.get('settings.global.animationEnabled')
            }),
            logoScaleSpeed: ({
                name: 'Scale Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
                parent: 'animation', inset: 2,
            }),
            logoFadeSpeed: ({
                name: 'Fade Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
                parent: 'animation', inset: 2,
            }),

            border: ({ name: 'Border', defaultValue: false, type: 'header' }),
            borderEnabled: ({
                name: 'Enabled', defaultValue: true, type: 'bool',
                parent: 'border', inset: 1
            }),
            borderAnimated: ({
                name: 'Animated', defaultValue: true, type: 'bool',
                parent: 'border', inset: 2,
                isEnabled: () => api.memory.get('settings.global.borderEnabled')
            }),
            borderWidth: ({
                name: 'Width', defaultValue: 3, min: 0, type: 'int',
                parent: 'border', inset: 2,
                isEnabled: () => api.memory.get('settings.global.borderEnabled')
            }),
            cornerRadius: ({
                name: 'Corner Radius', defaultValue: 5, min: 0, type: 'int',
                parent: 'border', inset: 2,
                isEnabled: () => api.memory.get('settings.global.borderEnabled')
            }),
            borderColor1: ({
                name: 'Color 1', defaultValue: '#FFC85C', type: 'string',
                parent: 'border', inset: 2,
                isEnabled: () => api.memory.get('settings.global.borderEnabled')
            }),
            borderColor2: ({
                name: 'Color 2', defaultValue: '#ECECEC', type: 'string',
                parent: 'border', inset: 2,
                isEnabled: () => api.memory.get('settings.global.borderEnabled')
            }),

            overlay: ({ name: 'Overlay', defaultValue: false, type: 'header' }),
            darkenAmount: ({
                name: 'Darken', defaultValue: 0.15, delta: 0.01, min: 0.0, max: 1.0, type: 'real',
                parent: 'overlay', inset: 1
            }),

            logo: ({ name: 'Logo', defaultValue: false, type: 'header' }),
            logoFontSize: ({
                name: 'Font Size', defaultValue: 20, min: 1, type: 'int',
                parent: 'logo', inset: 1,
            }),

            navigation: ({ name: 'Navigation', defaultValue: false, type: 'header' }),
            navigationOpacity: ({
                name: 'Background Opacity', defaultValue: 0.8, delta: 0.01, min: 0.0, max: 1.0, type: 'real',
                parent: 'navigation', inset: 1,
            }),
            navigationSize: ({
                name: 'Size', defaultValue: 160, type: 'int',
                parent: 'navigation', inset: 1,
            }),
            navigationPauseDuration: ({
                name: 'Pause Duration (Milliseconds)', defaultValue: 400, delta: 50, min: 0, type: 'int',
                parent: 'navigation', inset: 1,
            }),
            navigationFadeDuration: ({
                name: 'Fade Duration (Milliseconds)', defaultValue: 400, delta: 50, min: 0, type: 'int',
                parent: 'navigation', inset: 1,
            }),
            navigationYearIncrement: ({
                name: 'Year - Increment', defaultValue: 1, delta: 1, min: 1, type: 'int',
                parent: 'navigation', inset: 1,
            }),
            navigationRatingIncrement: ({
                name: 'Rating - Increment', defaultValue: 0.5, delta: 0.1, min: 0.1, max: 5.0, type: 'real',
                parent: 'navigation', inset: 1,
            }),
        }),
        gameLibrary: ({
            gameViewColumns: ({ name: 'Number of Columns', defaultValue: 4, type: 'int', min: 1 }),

            preset: ({
                name: 'Preset',
                defaultValue: 1,
                values: [ 'Box Art', 'Wide', 'Tall', 'Square', 'Custom' ],
                type: 'array',
                onChanged: (value) => {
                    switch (value) {
                        case 0: // Box Art
                            api.memory.set('settings.gameLibrary.art', 1);
                            api.memory.set('settings.gameLibrary.aspectRatioNative', true);
                            api.memory.set('settings.gameLibrary.logoVisible', false);
                            break;
                        case 1: // Wide
                        case 4: // Custom
                            api.memory.set('settings.gameLibrary.art', 0);
                            api.memory.set('settings.gameLibrary.aspectRatioNative', false);
                            api.memory.set('settings.gameLibrary.aspectRatioWidth', 9.2);
                            api.memory.set('settings.gameLibrary.aspectRatioHeight', 4.3);
                            api.memory.set('settings.gameLibrary.logoVisible', true);
                            break;
                        case 2: // Tall
                            api.memory.set('settings.gameLibrary.art', 0);
                            api.memory.set('settings.gameLibrary.aspectRatioNative', false);
                            api.memory.set('settings.gameLibrary.aspectRatioWidth', 2);
                            api.memory.set('settings.gameLibrary.aspectRatioHeight', 3);
                            api.memory.set('settings.gameLibrary.logoVisible', true);
                            break;
                        case 3: // Square
                            api.memory.set('settings.gameLibrary.art', 0);
                            api.memory.set('settings.gameLibrary.aspectRatioNative', false);
                            api.memory.set('settings.gameLibrary.aspectRatioWidth', 1);
                            api.memory.set('settings.gameLibrary.aspectRatioHeight', 1);
                            api.memory.set('settings.gameLibrary.logoVisible', true);
                            break;
                    }
                },
            }),
            art: ({
                name: 'Art',
                defaultValue: 0,
                values: ['screenshot', 'boxFront', 'boxBack', 'boxSpine', 'boxFull', 'cartridge', 'marquee', 'bezel', 'panel', 'cabinetLeft', 'cabinetRight', 'tile', 'banner', 'steam', 'poster', 'background', 'titlescreen'],
                type: 'array',
                inset: 1,
                isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
            }),

            aspectRatioNative: ({
                name: 'Art - Aspect Ratio - Use Native', defaultValue: false, type: 'bool',
                inset: 1,
                isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
            }),
            aspectRatioWidth: ({
                name: 'Art - Aspect Ratio - Width', defaultValue: 9.2, delta: 0.1, min: 0.1, type: 'real',
                inset: 1,
                isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
            }),
            aspectRatioHeight: ({
                name: 'Art - Aspect Ratio - Height', defaultValue: 4.3, delta: 0.1, min: 0.1, type: 'real',
                inset: 1,
                isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
            }),
            logoVisible: ({
                name: 'Logo - Visible', defaultValue: true, type: 'bool',
                inset: 1,
                isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
            }),
        }),
        gameDetails: ({
            previewEnabled: ({ name: 'Video Preview - Enabled', defaultValue: true, type: 'bool' }),
            previewVolume: ({ name: 'Video Preview - Volume', defaultValue: 0.0, delta: 0.1, min: 0.0, type: 'real' }),
        }),
        theme: ({
            backgroundColor: ({ name: 'Background Color', defaultValue: '#13161B', type: 'string' }),
            accentColor: ({ name: 'Accent Color', defaultValue: '#FFC85C', type: 'string' }),
            textColor: ({ name: 'Text Color', defaultValue: '#ECECEC', type: 'string' }),

            // backgroundColor: { name: 'Background Color', defaultValue: '#262A53', type: 'string' },
            // accentColor: { name: 'Accent Color', defaultValue: '#FFA0A0', type: 'string' },
            // textColor: { name: 'Text Color', defaultValue: '#FFE3E3', type: 'string' },
            leftMargin: ({ name: 'Screen Padding - Left', defaultValue: 60, min: 0, type: 'int' }),
            rightMargin: ({ name: 'Screen Padding - Right', defaultValue: 60, min: 0, type: 'int' }),
        }),
        performance: ({
            artImageResolution: ({ name: 'Art - Image Resolution', defaultValue: 0, values: ['Native', 'Scaled'], type: 'array' }),
            artImageCaching: ({ name: 'Art - Image Caching', defaultValue: false, type: 'bool' }),
            artImageSmoothing: ({ name: 'Art - Image Smoothing', defaultValue: false, type: 'bool' }),
            artDropShadow: ({ name: 'Art - Drop Shadow', defaultValue: true, type: 'bool' }),

            logoImageResolution: ({ name: 'Logo - Image Resolution', defaultValue: 1, values: ['Native', 'Scaled'], type: 'array' }),
            logoImageCaching: ({ name: 'Logo - Image Caching', defaultValue: false, type: 'bool' }),
            logoImageSmoothing: ({ name: 'Logo - Image Smoothing', defaultValue: true, type: 'bool' }),
            logoDropShadow: ({ name: 'Logo - Drop Shadow', defaultValue: false, type: 'bool' })
        })
    });

    property var stateHistory: []

    property var currentCollection: api.collections.get(0)
    property int currentCollectionIndex: 0

    onCurrentCollectionChanged: savedGameIndex = 0;

    property var selectedGame
    property var selectedGameHistory: []

    property int savedGameIndex: 0;

    property bool filterByFavorites: false
    property bool filterByBookmarks: false

    property var orderBy: ['title', 'developer', 'publisher', 'genre', 'releaseYear', 'players', 'rating', 'lastPlayed']
    property int orderByIndex: 0
    property int orderByDirection: Qt.AscendingOrder

    readonly property bool gameItemTitleEnabled: api.memory.get('settings.global.titleEnabled')
    readonly property real gameItemTitlePadding: gameItemTitleEnabled ? vpx(api.memory.get('settings.global.titleFontSize') * 0.25) : 0
    readonly property real gameItemTitleHeight: gameItemTitleEnabled ? vpx(api.memory.get('settings.global.titleFontSize')) : 0

    readonly property real gameItemTitleMargin: gameItemTitleEnabled ? gameItemTitleHeight + (api.memory.get('settings.global.borderEnabled') ? vpx(api.memory.get('settings.global.borderWidth')) : 0) + gameItemTitlePadding * 3 : 0

    property bool gameItemPlayVideoPreview: false

    Timer {
        id: gameItemVideoPreviewDebouncer

        interval: api.memory.get('settings.global.videoPreviewDelay')
        onTriggered: { gameItemPlayVideoPreview = true; }

        function debounce() {
            if (api.memory.get('settings.global.previewEnabled')) {
                gameItemVideoPreviewDebouncer.restart();
            } else {
                gameItemVideoPreviewDebouncer.stop();
            }

            gameItemPlayVideoPreview = false;
        }
    }

    states: [
        State { name: 'homeView'; PropertyChanges { target: loader; sourceComponent: homeView } },
        State { name: 'gamesView'; PropertyChanges { target: loader; sourceComponent: gamesView } },
        State { name: 'settingsView'; PropertyChanges { target: loader; sourceComponent: settingsView } },
        State { name: 'gameDetailsView'; PropertyChanges { target: loader; sourceComponent: gameDetailsView } }
    ]

    state: 'gamesView'

    Rectangle {
        anchors.fill: parent
        color: api.memory.get('settings.theme.backgroundColor')
    }

    Component {
        id: homeView
        HomeView { focus: true }
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
        GameDetailsView { focus: true; game: selectedGame }
    }

    Loader {
        id: loader
        anchors.fill: parent

        focus: true
        asynchronous: true
    }

    Component.onCompleted: {
        reloadSettings();
    }

    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        }

        if (api.keys.isCancel(event)) {
            event.accepted = previousScreen();
        }
    }

    function reloadSettings(overwrite = false) {
        for (const [categoryKey, category] of Object.entries(settingsMetadata)) {
            for (const [settingKey, setting] of Object.entries(category)) {
                const key = `settings.${categoryKey}.${settingKey}`;

                if ((!api.memory.has(key) || overwrite) && setting.defaultValue != undefined) {
                    api.memory.set(key, setting.defaultValue);
                }
            }
        };
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

    function toggleBookmarks(collection, game) {
        const key = `database.bookmarks.${collection.shortName}.${game.title}`;
        api.memory.set(key, !(api.memory.get(key) ?? false));
    }

    function getPrecision(a) {
        if (!isFinite(a)) {
            return 0;
        }

        var e = 1, p = 0;
        while (Math.round(a * e) / e !== a) {
            e *= 10;
            p++;
        }

        return p;
    }

    function capitalizeFirstLetter([ first, ...rest ], locale = 'en-US') {
        return first.toLocaleUpperCase(locale) + rest.join('');
    }
}
