import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10

import "Components"

import "./utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: titleFont; source: "assets/fonts/AkzidenzGrotesk-BoldCond.otf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/Gotham-Bold.otf" }
    FontLoader { id: bodyFont; source: "assets/fonts/Montserrat-Medium.otf" }

    SoundEffect { id: sfxNav; source: "assets/sfx/navigation.wav" }
    SoundEffect { id: sfxBack; source: "assets/sfx/back.wav" }
    SoundEffect { id: sfxAccept; source: "assets/sfx/accept.wav" }
    SoundEffect { id: sfxToggle; source: "assets/sfx/toggle.wav" }

    property var stateHistory: []
    property var settings

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
            event.accepted = true;
            previousScreen();
            return;
        }
    }

    function previousScreen() {
        if (stateHistory.length > 0) {
            sfxBack.play();
            root.state = stateHistory.pop();
        }
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
        if (api.memory.has('settings')) {
            settings = api.memory.get('settings');
        } else {
            settings = {
                theme: {
                    accentColor: { key: 'Accent Color', value: '#efc62e', type: 'string' },
                    backgroundColor: { key: 'Background Color', value: '#1c1f26', type: 'string' },
                },
                game: {
                    scale: { key: 'Scale', value: 0.95, type: 'real' },
                    scaleSelected: { key: 'Scale - Selected', value: 1.00, type: 'real' },

                    aspectRatioWidth: { key: 'Aspect Ratio - Width', value: 9.2, type: 'real' },
                    aspectRatioHeight: { key: 'Aspect Ratio - Height', value: 4.3, type: 'real' },

                    cornerRadius: { key: 'Corner Radius', value: 5, type: 'int' },

                    previewEnabled: { key: 'Video Preview', value: true, type: 'bool' },
                    previewVolume: { key: 'Video Preview Volume', value: 0.0, type: 'real' },

                    logoMargin: { key: 'Logo Margins', value: 30, type: 'int' },
                    logoFontSize: { key: 'Logo Font Size', value: 16, type: 'int' },
                    
                    borderAnimated: { key: 'Highlight Border Animated', value: true, type: 'bool' },
                    borderWidth: { key: 'Highlight Border Width', value: 5, type: 'int', },

                    gameViewLeftPadding: { key: 'Screen Padding - Left', value: 60, type: 'int' },
                    gameViewRightPadding: { key: 'Screen Padding - Right', value: 60, type: 'int' },

                    gameViewColumns: { key: 'Number of Columns', value: 3, type: 'int' },
                }
            }
        }
    }
}
