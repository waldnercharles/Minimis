import QtQuick 2.3
import QtQml.Models 2.10
import QtGraphicalEffects 1.0

ListView {
    id: root
    property var game

    orientation: ListView.Horizontal
    spacing: vpx(10)
    keyNavigationWraps: true

    Keys.onLeftPressed: { event.accepted = false; }
    Keys.onRightPressed: { event.accepted = false; }

    height: vpx(40)

    model: ObjectModel {
        Button {
            icon: '\uf04b'
            text: 'Play Game'
            height: parent.height
            selected: root.focus && ListView.isCurrentItem
            onActivated: {
                launchGame(game);
            }
        }
        // Button {
        //     icon: '\uf05a'
        //     text: 'More Info'
        //     height: parent.height
        //     selected: root.focus && ListView.isCurrentItem
        //     onActivated: {
        //     }
        // }
        Button {
            icon: (game && game.favorite) ? '\uf004' : '\uf08a'
            height: parent.height
            selected: root.focus && ListView.isCurrentItem
            circle: true
            onActivated: {
                game.favorite = !game.favorite;
            }
        }

        Button {
            readonly property bool isBookmarked: database.games.get(root.game).bookmark ?? false
            icon: isBookmarked ? '\uf02e' : '\uf097'
            height: parent.height
            text: selected ? (isBookmarked ? 'Remove from Bookmarks' : 'Add to Bookmarks') : ''
            selected: root.focus && ListView.isCurrentItem
            circle: true
            onActivated: {
                const dbGame = database.games.get(game);
                dbGame.bookmark = !dbGame.bookmark;
            }
        }
    }

    layer.enabled: true
    layer.effect: DropShadowLow { }
}
