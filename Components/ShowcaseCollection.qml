import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    readonly property alias games: topFilteredGames

    property int maxItems: 0
    property int collectionType: 0

    SortFilterProxyModel {
        id: filteredGames

        sorters: [
            RoleSorter { roleName: 'lastPlayed'; sortOrder: Qt.DescendingOrder; enabled: collectionType === 1 }
        ]
        filters: AllOf {
            ExpressionFilter { expression: modelData.lastPlayed.getTime() === modelData.lastPlayed.getTime(); enabled: collectionType === 1 }
            ValueFilter { roleName: 'favorite'; value: true; enabled: collectionType === 2 }
            ExpressionFilter { expression: modelData && !!api.memory.get(`database.bookmarks.${modelData.collections.get(0).shortName}.${modelData.title}`); enabled: collectionType === 3 }
            ExpressionFilter { expression: !!filteredGames.randomMask[index]; enabled: collectionType === 4 }
            ExpressionFilter { expression: collectionType !== 0 }
        }

        property var randomMask: ([])
        onSourceModelChanged: {
            if (collectionType === 4) {
                filteredGames.randomMask = [];
                for(let i = 0; i < maxItems; i++) {
                    let randomIndex;
                    do {
                        randomIndex = Math.floor(Math.random() * filteredGames.sourceModel.count);
                    } while (filteredGames.randomMask[randomIndex])

                    filteredGames.randomMask[randomIndex] = true;
                }
            }
        }

        sourceModel: api.allGames
    }

    SortFilterProxyModel {
        id: topFilteredGames

        filters: IndexFilter { maximumIndex: maxItems - 1 }

        sourceModel: filteredGames
    }
}