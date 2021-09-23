import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    readonly property alias games: topGames
    property int maxItems: 16

    SortFilterProxyModel {
        id: proxyModel

        sourceModel: api.allGames

        sorters: ExpressionSorter { expression: modelLeft.title && modelRight.title && database.games.get(modelLeft).random < database.games.get(modelRight).random }
        filters: ValueFilter { roleName: 'favorite'; value: true }

        delayed: true
    }

    SortFilterProxyModel {
        id: topGames

        sourceModel: proxyModel

        filters: IndexFilter { maximumIndex: maxItems - 1 }

        delayed: true
    }
}