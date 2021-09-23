import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    readonly property alias games: topGames
    property int maxItems: 16

    SortFilterProxyModel {
        id: proxyModel

        sourceModel: api.allGames

        sorters: ExpressionSorter { expression: modelLeft.title && modelRight.title && database.games.get(modelLeft).random < database.games.get(modelRight).random }
        filters: ExpressionFilter {
            expression: {
                model.title; model.favorite;
                return model.title ? !!database.games.get(model).bookmark : false;
            }
        }

        delayed: true
    }

    SortFilterProxyModel {
        id: topGames

        sourceModel: proxyModel

        filters: IndexFilter { maximumIndex: maxItems - 1 }

        delayed: true
    }
}