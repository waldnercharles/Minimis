import QtQuick 2.15
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10

import "Components"
import "Components/Collections"

import "./database.js" as Database
import "./settings.js" as Settings
import "./utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: homeFont; source: "assets/fonts/Comfortaa-Light.ttf" }

    FontLoader { id: fontawesome; source: "assets/fonts/FontAwesome.otf" }
    FontLoader { id: titleFont; source: "assets/fonts/SourceSansPro-Bold.ttf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/OpenSans-Bold.ttf" }
    FontLoader { id: bodyFont; source: "assets/fonts/OpenSans-Semibold.ttf" }

    SoundEffect { id: sfxNav; source: "assets/sfx/navigation.wav" }
    SoundEffect { id: sfxBack; source: "assets/sfx/back.wav" }
    SoundEffect { id: sfxAccept; source: "assets/sfx/accept.wav" }
    SoundEffect { id: sfxToggle; source: "assets/sfx/toggle.wav" }

    property var database: Database
    property var settingsMetadata: Settings.metadata

    property var stateHistory: []

    property var currentCollection: api.collections.get(0)
    property int currentCollectionIndex: 0

    onCurrentCollectionChanged: savedGameIndex = 0;

    property var selectedGame
    property var selectedGameHistory: []

    property int savedGameIndex: 0;

    property bool filterByFavorites: false
    property bool filterByBookmarks: false

    property var orderByFields: ['title', 'developer', 'publisher', 'genre', 'releaseYear', 'players', 'rating', 'lastPlayed']
    property int orderByIndex: 0
    property int orderByDirection: Qt.AscendingOrder

    readonly property real uiScale: api.memory.get('settings.general.uiScale') ?? 1;

    readonly property bool gameDelegateTitleEnabled: api.memory.get('settings.cardTheme.titleEnabled')
    readonly property real gameDelegateTitleFontSize: api.memory.get('settings.cardTheme.titleFontSize') * uiScale
    readonly property real gameDelegateTitlePadding: gameDelegateTitleEnabled ? vpx(gameDelegateTitleFontSize * 0.4) : 0
    readonly property real gameDelegateTitleHeight: gameDelegateTitleEnabled ? vpx(gameDelegateTitleFontSize) : 0

    readonly property real gameDelegateTitleMargin: gameDelegateTitleEnabled ? (gameDelegateTitleHeight * 2) + (gameDelegateTitlePadding * 2.25) + (api.memory.get('settings.cardTheme.borderEnabled') ? vpx(api.memory.get('settings.cardTheme.borderWidth')) * 2 : 0) : 0

    Debouncer {
        id: videoPreviewDebouncer

        interval: api.memory.get('settings.cardTheme.videoPreviewDelay')
        enabled: api.memory.get('settings.cardTheme.previewEnabled')
    }

    states: [
        State { name: 'showcaseView'; PropertyChanges { target: contentLoader; sourceComponent: showcaseViewComponent } },
        State { name: 'gameDetailsView'; PropertyChanges { target: contentLoader; sourceComponent: showcaseViewComponent } },
        State { name: 'settingsView'; PropertyChanges { target: contentLoader; sourceComponent: settingsViewComponent } }
    ]

    state: 'showcaseView'

    Background {
        anchors.fill: parent

        source: contentLoader.game ? contentLoader.game.assets.screenshot || '' : ''

        Image {
            id: loadingIndicator

            anchors.centerIn: parent
            source: loadingIndicator.visible ? 'assets/loading-spinner.png' : ''
            asynchronous: false
            smooth: true

            RotationAnimator on rotation {
                loops: Animator.Infinite;
                from: 0;
                to: 360;
                duration: 1000

                running: loadingIndicator.visible
            }

            visible: opacity > 0
            opacity: contentLoader.status === Loader.Loading ? 1 : 0
            Behavior on opacity { SequentialAnimation { NumberAnimation { duration: 300; from: 1 } } }
        }
    }

    Component { id: settingsViewComponent; SettingsView { anchors.fill: parent; focus: true } }

    Component {
        id: showcaseViewComponent;

        FocusScope {
            anchors.fill: parent
            focus: true

            readonly property var game: (root.state === 'showcaseView' ? showcaseView.game : gameDetailsView.game)

            ShowcaseView {
                id: showcaseView

                anchors.fill: parent
                focus: root.state === 'showcaseView'

                visible: focus
                opacity: focus ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300; from: 0 } }
            }

            GameDetailsView {
                id: gameDetailsView

                anchors.fill: parent
                focus: root.state === 'gameDetailsView'

                game: root.selectedGame

                visible: focus
                opacity: focus ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 300; from: 0 } }
            }
        }
    }

    Loader {
        id: contentLoader
        readonly property var game: item ? item.game : undefined

        anchors.fill: parent

        asynchronous: true

        opacity: contentLoader.status === Loader.Ready ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 300; from: 0 } }

        focus: true

        active: false
    }

    Component.onCompleted: {
        reloadSettings();
        const games = api.allGames;

        for (let i = games.count - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            games.move(i, j);
            games.move(j + 1, i);
        }

        contentLoader.active = true;
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
        // sfxAccept.play();
        stateHistory.push(root.state);
        root.state = 'gamesView';
    }

    function toSettingsView() {
        stateHistory.push(root.state);
        root.state = 'settingsView';
    }

    function toGameDetailsView(game) {
        // sfxAccept.play();

        if (selectedGame) {
            selectedGameHistory.push(selectedGame);
        }

        selectedGame = game;

        stateHistory.push(root.state);
        root.state = 'gameDetailsView';
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

    function capitalize(str) {
        return capitalizeFirstLetter(str).split(/([A-Z]?[^A-Z]*)/g).join(' ');
    }
}
