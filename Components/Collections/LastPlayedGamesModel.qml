import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    readonly property alias games: topGames
    property int maxItems: 16

    SortFilterProxyModel {
        id: proxyModel

        sourceModel: api.allGames

        sorters: RoleSorter { roleName: 'lastPlayed'; sortOrder: Qt.DescendingOrder }
        filters: ExpressionFilter { expression: { model.lastPlayed; return model.lastPlayed ? database.games.get(model).played : false } }

        delayed: true
    }

    SortFilterProxyModel {
        id: topGames

        sourceModel: proxyModel

        filters: IndexFilter { maximumIndex: maxItems - 1 }

        delayed: true
    }
}