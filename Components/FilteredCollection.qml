import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    anchors.fill: parent
    property var orderBy: Qt.AscendingOrder

    readonly property alias games: games

    function toggleFavorites() {
        games.favorites = !games.favorites
    }

    AllOf {
        id: gameFilters
        ValueFilter { roleName: 'favorite'; value: true; enabled: games.favorites }
    }

    RoleSorter {
        id: sorter
        roleName: 'title'
        sortOrder: orderBy
    }

    RegExpFilter {
        id: letterNavFilter
        roleName: 'title'
        pattern: '^' + (letterNav.currentLetter ? letterNav.currentLetter : '[^a-z]')
        caseSensitivity: Qt.CaseInsensitive
    }

    SortFilterProxyModel {
        id: letterNav

        property string currentLetter

        sourceModel: games.sourceModel
        filters: [ gameFilters, letterNavFilter ]
        sorters: sorter
    }

    SortFilterProxyModel {
        id: games

        property bool favorites: false

        sourceModel: currentCollection.games
        filters: gameFilters
        sorters: sorter

        function get(index) {
            return currentCollection.games.get(games.mapToSource(index));
        }
    }

    function nextChar(c, modifier) {
        const firstAlpha = 97;
        const lastAlpha = 122;

        var charCode = c.charCodeAt(0) + modifier;

        if (modifier > 0) {
            if (charCode < firstAlpha || isNaN(charCode)) { return 'a'; }
            if (charCode > lastAlpha) { return ''; }
        } else {
            if (charCode == firstAlpha - 1) { return ''; }
            if (charCode < firstAlpha || charCode > lastAlpha || isNaN(charCode)) { return 'z'; }
        }

        return String.fromCharCode(charCode);
    }

    function navigateLetter(index, direction) {
        direction = direction < 0 ? -1 : 1;
        direction = direction * (orderBy == Qt.AscendingOrder ? 1 : -1);

        const currentLetter = games.get(index).title.toLocaleLowerCase().charAt(0);
        var nextLetter = currentLetter;

        do {
            letterNav.currentLetter = nextLetter = nextChar(nextLetter, direction);
        } while (letterNav.count === 0 && nextLetter != currentLetter)

        letterNavTransition.currentLetter = nextLetter || '#';

        return games.mapFromSource(letterNav.mapToSource(0));
    }

    LetterNavigationTransition {
        id: letterNavTransition
    }
}