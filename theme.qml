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

    property var settings
    property var stateHistory: []

    property var currentCollection
    property int currentCollectionIndex: 0

    states: [
        State { name: 'gamesView'; PropertyChanges { target: loader; sourceComponent: gamesView } },
        State { name: 'settingsView'; PropertyChanges { target: loader; sourceComponent: settingsView } }
    ]

    state: 'gamesView'

    BackgroundImage {
        anchors.fill: parent
    }

    Component {
        id: gamesView
        GamesView { focus: true }
    }

    Component {
        id: settingsView
        SettingsView { focus: true }
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

            return true;
        }

        return false;
    }

    function toGamesView() {
        sfxAccept.play();
        stateHistory.push(root.state);
        root.state = "gamesView";
    }

    function toSettingsView() {
        sfxAccept.play();
        stateHistory.push(root.state);
        root.state = "settingsView";
    }

    function loadSettings() {
        settings = {
            game: {
                gameViewColumns: { name: 'Number of Columns', value: 3, type: 'int', min: 1 },

                aspectRatioWidth: { name: 'Aspect Ratio - Width', value: 9.2, delta: 0.1, min: 0.1, type: 'real' },
                aspectRatioHeight: { name: 'Aspect Ratio - Height', value: 4.3, delta: 0.1, min: 0.1, type: 'real' },

                previewEnabled: { name: 'Video Preview - Enabled', value: true, type: 'bool' },
                previewVolume: { name: 'Video Preview - Volume', value: 0.0, delta: 0.05, min: 0.1, type: 'real' },
                previewHideLogo: { name: 'Video Preview - Hide Logo', value: false, type: 'bool' },

                borderAnimated: { name: 'Border - Animate', value: true, type: 'bool' },
                borderColor1: { name: 'Border - Color 1', value: '#FFD460', type: 'string' },
                borderColor2: { name: 'Border - Color 2', value: '#F6F7D7', type: 'string' },
                borderWidth: { name: 'Border - Width', value: 5, min: 0, type: 'int', },

                scale: { name: 'Scale', value: 0.95, delta: 0.01, min: 0.01, max: 1.0, type: 'real' },
                scaleSelected: { name: 'Scale - Selected', value: 1.0, delta: 0.01, min: 0.01, type: 'real' },

                cornerRadius: { name: 'Corner Radius', value: 5, min: 0, type: 'int' },

                logoScale: { name: 'Logo - Scale', value: 0.8, delta: 0.01, min: 0.01, type: 'real' },
                logoFontSize: { name: 'Logo - Font Size', value: 16, min: 1, type: 'int' },
            },
            theme: {
                backgroundColor: { name: 'Background Color', value: '#1B262C', type: 'string' },

                accentColor: { name: 'Accent Color', value: '#FFD460', type: 'string' },


                textColor: { name: 'Text Color', value: '#F6F7D7', type: 'string' },

                leftMargin: { name: 'Screen Padding - Left', value: 60, min: 0, type: 'int' },
                rightMargin: { name: 'Screen Padding - Right', value: 60, min: 0, type: 'int' },
            },
        };

        for (const category of Object.values(settings)) {
            for (const setting of Object.values(category)) {
                api.memory.set(setting.name, setting.value = api.memory.get(setting.name) ?? setting.value);
            }
        }
    }
}
