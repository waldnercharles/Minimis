import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    anchors.fill: parent

    readonly property alias games: games
    readonly property alias model: games.sourceModel

    ValueFilter { id: gameFilters; roleName: 'favorite'; value: true; enabled: filterByFavorites }

    FilterSorter {
        id: playCountSorter
        ValueFilter {
            roleName: 'playCount'
            value: 0
            inverted: true
        }
        enabled: orderByFields[orderByIndex] === 'lastPlayed'
        sortOrder: orderByDirection
    }

    RoleSorter {
        id: sorter
        roleName: orderByFields[orderByIndex]
        sortOrder: orderByDirection
    } 

    SortFilterProxyModel {
        id: games

        sourceModel: currentCollection.games

        filters: gameFilters
        sorters: [ playCountSorter, sorter ]

        // delayed: true
    }
}