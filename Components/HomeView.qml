import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.15
import SortFilterProxyModel 0.2

FocusScope {
    id: root
    anchors.fill: parent

    ShowcaseCollection { id: collectionTypeRecentlyPlayed; collectionType: 1; maxItems: 16 }
    ShowcaseCollection { id: collectionTypeFavorites; collectionType: 2; maxItems: 16 }
    ShowcaseCollection { id: collectionTypeBookmarks; collectionType: 3; maxItems: 16 }
    ShowcaseCollection { id: collectionTypeRandomGames; collectionType: 4; maxItems: 16 }

    property var collectionsByType: ([
        undefined,
        collectionTypeRecentlyPlayed,
        collectionTypeFavorites,
        collectionTypeBookmarks,
        collectionTypeRandomGames
    ])

    Rectangle {
        id: background

        anchors.fill: parent
        color: 'black'

        Image {
            id: showcaseImage
            anchors.fill: parent

            readonly property var currentGame: listView.currentItem ? listView.currentItem.currentGame : undefined
            source: currentGame ? currentGame.assets['screenshot'] || '' : '' // ? (currentGame.assets['screenshot'] || '') : ''
            fillMode: Image.PreserveAspectCrop
            asynchronous: false

            smooth: false;
            cache: false;
        }
    }

    LinearGradient {
        id: gradient

        anchors.fill: background
        start: Qt.point(0, 0)
        end: Qt.point(0, background.height)
        gradient: Gradient {
            GradientStop { position: 0; color: "#40000000" }
            GradientStop { position: 0.8; color: "#f0000000" }
            GradientStop { position: 1; color: "#ff000000" }
        }
    }

    FocusScope {
        focus: true
        anchors.fill: parent;
        anchors.leftMargin: vpx(api.memory.get('settings.theme.leftMargin'));
        anchors.rightMargin: vpx(api.memory.get('settings.theme.rightMargin'));

        ListModel {
            id: showcaseCollectionsListModel

            ListElement { collectionKey: 'collection1' }
            ListElement { collectionKey: 'collection2' }
            ListElement { collectionKey: 'collection3' }
            ListElement { collectionKey: 'collection4' }
            ListElement { collectionKey: 'collection5' }
        }

        SortFilterProxyModel {
            id: showcaseCollectionsProxyModel
            proxyRoles: [
                ExpressionRole { name: 'collectionType'; expression: api.memory.get(`settings.home.${collectionKey}type`) },
                ExpressionRole { name: 'collection'; expression: collectionsByType[api.memory.get(`settings.home.${model.collectionKey}type`)] }
            ]

            filters: ExpressionFilter {
                expression: {
                    collectionTypeRecentlyPlayed.games.count;
                    collectionTypeFavorites.games.count;
                    collectionTypeBookmarks.games.count;
                    collectionTypeRandomGames.games.count;

                    return collection != null && collection.games.count > 0;
                }
            }

            sourceModel: showcaseCollectionsListModel
        }

        ListView {
            id: listView
            focus: true

            anchors {
                bottom: parent.bottom; left: parent.left; right: parent.right;
                bottomMargin: vpx(40)
            }

            height: vpx(300)

            preferredHighlightBegin: 0
            preferredHighlightEnd: 0

            highlightResizeDuration: 0
            highlightMoveDuration: 300
            highlightRangeMode: ListView.ApplyRange

            spacing: gameItemTitleMargin + vpx(10)

            cacheBuffer: height * 5
            
            model: showcaseCollectionsProxyModel
            delegate: HorizontalListViewFiltered {
                width: listView.width
                height: listView.height * 0.75

                focus: listView.focus && ListView.isCurrentItem

                model: collection ? collection.games : undefined

                opacity: index < listView.currentIndex ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            Keys.onUpPressed: {
                event.accepted = true;
                sfxNav.play();

                if (listView.currentIndex === 0) {
                    listView.currentIndex = -1;
                    header.focus = true;
                } else {
                    decrementCurrentIndex();
                }
            }

            Keys.onDownPressed: {
                event.accepted = true;
                sfxNav.play();
                incrementCurrentIndex();
            }
        }

        FocusScope {
            id: header

            anchors {
                left: parent.left; right: parent.right; top: parent.top;
            }

            anchors.topMargin: height / 4.0
            anchors.bottomMargin: anchors.topMargin

            height: vpx(75)

            Button {
                icon: '\uf013'

                anchors.verticalCenter: parent.verticalCenter;
                anchors.right: parent.right

                width: parent.height / 2; height: width;

                circle: true

                focus: parent.focus
                selected: parent.focus

                onActivated: {
                    toSettingsView();
                }
            }

            Keys.onDownPressed: {
                sfxNav.play();
                listView.focus = true;
                listView.currentIndex = 0;
            }
        }
    }
}