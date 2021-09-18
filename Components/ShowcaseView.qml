import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.15
import SortFilterProxyModel 0.2
import QtQuick.Layouts 1.15

FocusScope {
    id: root
    anchors.fill: parent

    readonly property var game: currentGame ?? previousGame

    readonly property alias currentGame: showcase.currentGame
    property var previousGame: undefined

    states: [
        State { name: "full"; PropertyChanges { target: showcase; y: header.height } },
        State { name: "half"; PropertyChanges { target: showcase; y: root.height * 0.4 } }
    ]

    transitions: [
        Transition {
            NumberAnimation { target: showcase; property: 'y'; duration: 300 }
        }
    ]

    state: showcase.list.currentIndex < (showcase.list.count - 1) ? 'half' : 'full'

    // Background {
    //     anchors.fill: parent
        
    //     source: root.game ? root.game.assets.screenshot || '' : ''

    //     showBackgroundImage: root.state !== 'full'
    // }

    FocusScope {
        focus: true
        anchors.fill: parent;
        anchors.leftMargin: vpx(api.memory.get('settings.theme.leftMargin'));
        anchors.rightMargin: vpx(api.memory.get('settings.theme.rightMargin'));

        GameMetadata {
            width: parent.width
            height: parent.height * 0.4

            game: root.game

            opacity: root.state === 'full' ? 0 : 1
            Behavior on opacity { NumberAnimation { from: 0; duration: 200 } }
        }

        ShowcaseCollections {
            id: showcase
            focus: true

            width: parent.width
            height: root.height - header.height 

            rowHeight: (height / 2) * 0.75

            onCurrentGameChanged: {
                if (currentGame != null) {
                    root.previousGame = currentGame;
                }
            }

            Keys.onUpPressed: {
                if (showcase.list.currentIndex === 0) {
                    header.focus = true;
                    event.accepted = true;
                }
            }

            Keys.onPressed: {
                if (api.keys.isCancel(event)) {
                    header.focus = true;
                    event.accepted = true;
                }
            }
        }

        ShowcaseViewHeader {
            id: header
        }

        // FocusScope {
        //     id: header

        //     anchors {
        //         left: parent.left; right: parent.right; top: parent.top;
        //     }

        //     anchors.topMargin: height / 2.0
        //     anchors.bottomMargin: anchors.topMargin

        //     height: vpx(40)

        //     Button {
        //         icon: '\uf013'

        //         anchors.verticalCenter: parent.verticalCenter;
        //         anchors.right: parent.right

        //         width: parent.height
        //         height: parent.height;

        //         circle: true

        //         focus: parent.focus
        //         selected: parent.focus

        //         onActivated: {
        //             toSettingsView();
        //         }
        //     }

        //     Keys.onDownPressed: {
        //         sfxNav.play();
        //         showcase.focus = true;
        //     }
        // }
    }
}