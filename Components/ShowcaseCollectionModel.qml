import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    readonly property alias games: topFilteredGames

    property int maxItems: 0
    property int collectionType: 0

    SortFilterProxyModel {
        id: filteredGames

        sorters: [
            RoleSorter { roleName: 'lastPlayed'; sortOrder: Qt.DescendingOrder; enabled: collectionType === 1 },
            RoleSorter { roleName: 'random'; sortOrder: Qt.AscendingOrder; enabled: collectionType === 4 }
        ]
        filters: AllOf {
            ValueFilter { roleName: 'played'; value: true; enabled: collectionType === 1 }
            ValueFilter { roleName: 'favorite'; value: true; enabled: collectionType === 2 }
            ValueFilter { roleName: 'bookmark'; value: true; enabled: collectionType === 3 }
        }

        sourceModel: collectionType !== 0 ? allGames : undefined
    }

    SortFilterProxyModel {
        id: topFilteredGames
        filters: IndexFilter { maximumIndex: maxItems - 1 }
        sourceModel: filteredGames
    }
}