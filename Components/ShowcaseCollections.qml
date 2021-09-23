import QtQuick 2.15
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.15
import SortFilterProxyModel 0.2
import Qt.labs.qmlmodels 1.0

import "Collections"

FocusScope {
    id: root

    readonly property alias list: listView
    readonly property var currentGame: listView.currentItem && listView.currentItem ? listView.currentItem.currentGame : undefined

    property int rowHeight

    LastPlayedGamesModel { id: lastPlayedGamesModel; maxItems: 16 }
    FavoriteGamesModel { id: favoriteGamesModel; maxItems: 16 }
    BookmarkedGamesModel { id: bookmarkedGamesModel; maxItems: 16 }
    RandomGamesModel { id: randomGamesModel; maxItems: 16 }
    GameLibraryModel { id: gameLibraryModel; z: 100 }

    readonly property var collectionsByType: [
        undefined,
        lastPlayedGamesModel,
        favoriteGamesModel,
        bookmarkedGamesModel,
        randomGamesModel,
    ]

    ListModel {
        id: listModel

        ListElement { type: 'showcaseCollection' }
        ListElement { type: 'showcaseCollection' }
        ListElement { type: 'showcaseCollection' }
        ListElement { type: 'showcaseCollection' }
        ListElement { type: 'showcaseCollection' }
        ListElement { type: 'gameLibrary' }
    }

    SortFilterProxyModel {
        id: proxyModel
        proxyRoles: [
            ExpressionRole { name: 'collectionKey'; expression: type === 'showcaseCollection' ? `collection${index + 1}` : undefined },
            ExpressionRole { name: 'collectionType'; expression: type === 'showcaseCollection' ? api.memory.get(`settings.home.${collectionKey}type`) : undefined },
            ExpressionRole { name: 'collection'; expression: type === 'showcaseCollection' ? collectionsByType[collectionType] : undefined }
        ]

        filters: ExpressionFilter {
            expression: {
                lastPlayedGamesModel.games.count;
                favoriteGamesModel.games.count;
                bookmarkedGamesModel.games.count;
                randomGamesModel.games.count;

                return type === 'gameLibrary' || (collection != null && collection.games.count > 0);
            }
        }

        sourceModel: listModel
    }

    DelegateChooser {
        id: showcaseDelegate

        role: 'type'

        DelegateChoice {
            roleValue: 'showcaseCollection'
            ShowcaseCollection {
                readonly property bool selected: root.focus && ListView.isCurrentItem

                width: root.width
                height: root.rowHeight

                model: collection ? collection.games : undefined
                focus: selected

                opacity: index < listView.currentIndex ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        DelegateChoice {
            roleValue: 'gameLibrary'
            Column {
                readonly property bool selected: root.focus && ListView.isCurrentItem
                readonly property var currentGame: gameLibrary.currentGame

                width: root.width
                height: root.height

                spacing: vpx(10)

                Text {
                    text: 'Library'

                    font.family: subtitleFont.name
                    font.pixelSize: vpx(18)

                    color: api.memory.get('settings.theme.textColor')
                    opacity: selected ? 1 : 0.2

                    layer.enabled: true
                    layer.effect: DropShadowLow { cached: true }
                }

                GameLibrary {
                    id: gameLibrary

                    height: parent.height - y
                    width: parent.width

                    model: gameLibraryModel.games
                    focus: selected
                }
            }
        }
    }

    ListView {
        id: listView

        focus: true
        anchors.fill: parent

        preferredHighlightBegin: 0
        preferredHighlightEnd: 0

        highlightResizeDuration: 0
        highlightMoveDuration: 300
        highlightRangeMode: ListView.StrictlyEnforceRange 

        spacing: gameItemTitleMargin + vpx(10)

        cacheBuffer: Math.max(root.rowHeight * 6, 0)
        
        model: proxyModel
        delegate: showcaseDelegate

        keyNavigationWraps: false

        Keys.onUpPressed: { sfxNav.play(); event.accepted = false; }
        Keys.onDownPressed: { sfxNav.play(); event.accepted = false; }
    }
}