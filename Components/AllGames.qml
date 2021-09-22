import QtQuick 2.3
import SortFilterProxyModel 0.2

SortFilterProxyModel {
    id: root

    property var randomValues: undefined;

    proxyRoles: [
        ExpressionRole {
            name: 'bookmark'
            expression: {
                model.title; model.favorite;
                return model.title ? api.memory.get(`database.bookmarks.${model.collections.get(0).shortName}.${model.title}`) : false;
            }
        },
        ExpressionRole { name: 'random'; expression: root.randomValues ? root.randomValues[index] : 0; },
        ExpressionRole { name: 'played'; expression: model.lastPlayed && model.lastPlayed.getTime() === model.lastPlayed.getTime() }
    ]

    sourceModel: api.allGames

    Component.onCompleted: {
        root.randomValues = Array(root.sourceModel.count).fill().map(() => Math.random());
    }
}