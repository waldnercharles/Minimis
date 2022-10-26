import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

FocusScope {
    id: root
    anchors.fill: parent

    readonly property var game: currentGame ?? previousGame

    readonly property alias currentGame: showcase.currentGame
    property var previousGame: undefined

    states: [
        State {
            name: "full";
            PropertyChanges { target: showcase; y: header.height }
            PropertyChanges { target: showcaseMetadata; y: -showcaseMetadata.height; opacity: 0 }
        },
        State { name: "half"; }
    ]

    transitions: [
        Transition {
            NumberAnimation { target: showcase; property: 'y'; duration: 300 }
            NumberAnimation { target: showcase; property: 'height'; duration: 300 }
            NumberAnimation { target: showcaseMetadata; property: 'y'; duration: 300 }
            NumberAnimation { target: showcaseMetadata; property: 'opacity'; duration: 300 }
        }
    ]

    state: showcase.list.currentIndex < (showcase.list.count - 1) ? 'half' : 'full'

    FocusScope {
        focus: true
        anchors.fill: parent;
        anchors.leftMargin: vpx(api.memory.get('settings.general.leftMargin'));
        anchors.rightMargin: vpx(api.memory.get('settings.general.rightMargin'));

        GameMetadata {
            id: showcaseMetadata

            width: parent.width * 0.6
            height: parent.height * 0.5

            game: root.game

            visible: opacity > 0
        }

        ShowcaseCollections {
            id: showcase
            focus: true

            width: parent.width
            height: parent.height - header.height

            y: showcaseMetadata.height

            rowHeight: (root.height / 2) * 0.66

            onCurrentGameChanged: {
                if (currentGame != null) {
                    root.previousGame = currentGame;
                    showcaseMetadata.showDetails = false;
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
            
            onDropdownUpdated: {
                showcase.focus = true;
                showcase.list.currentIndex = showcase.list.count - 1;
                var gameLibraryDelegate = listView.itemAtIndex(listView.currentIndex);
                gameLibraryDelegate.currentIndex = 0;
            }
        }

        Keys.onPressed: {
            if (api.keys.isPageUp(event)) {
                event.accepted = true;
                showcase.focus = true;
                showcase.prevLetter();
            }

            if (api.keys.isPageDown(event)) {
                event.accepted = true;
                showcase.focus = true;
                showcase.nextLetter();
            }

            if (api.keys.isNextPage(event)) {
                event.accepted = true;
                currentCollectionIndex = (currentCollectionIndex < (api.collections.count - 1)) ? (currentCollectionIndex + 1) : 0;
                showcase.focus = true;
                showcase.list.currentIndex = showcase.list.count - 1;
                var gameLibraryDelegate = showcase.list.itemAtIndex(showcase.list.currentIndex);
                gameLibraryDelegate.currentIndex = 0;
                sfxAccept.play();
            }

            if (api.keys.isPrevPage(event)) {
                event.accepted = true;
                currentCollectionIndex = (currentCollectionIndex > 0) ? (currentCollectionIndex - 1) : (api.collections.count - 1);
                showcase.focus = true;
                showcase.list.currentIndex = showcase.list.count - 1;
                var gameLibraryDelegate = showcase.list.itemAtIndex(showcase.list.currentIndex);
                gameLibraryDelegate.currentIndex = 0;
                sfxAccept.play();
            }

            if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                if (showcase.focus && showcase.list.currentIndex != showcase.list.count - 1) {
                    event.accepted = true;
                    showcaseMetadata.showDetails = !showcaseMetadata.showDetails;

                    sfxAccept.play();
                }
            }
        }
    }
}