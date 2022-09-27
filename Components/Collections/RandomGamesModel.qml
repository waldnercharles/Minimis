import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    readonly property var games: randomGames
    readonly property bool indexed: true
    property int maxItems: 16

    SortFilterProxyModel {
        id: proxyModel

        sourceModel: api.allGames

        // delayed: true
    }

    SortFilterProxyModel {
        id: topGames

        sourceModel: proxyModel

        filters: IndexFilter { maximumIndex: maxItems - 1 }

        // delayed: true
    }
}