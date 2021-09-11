import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

FocusScope {
    id: root
    anchors.fill: parent

    FocusScope {
        id: gridContainer
        focus: true

        anchors.fill: parent
        anchors.topMargin: header.height + vpx(8)

        FakeAsset { id: fakeAsset; collection: currentCollection }

        Component { id: gamesViewItemComponent; GamesViewItem { } }

        Component {
            id: highlightComponent

            GamesViewItemHighlight {
                game: grid.model ? grid.model.get(grid.currentIndex) : undefined
                item: grid.currentItem

                muted: collectionTransition.opacity === 1
            }
        }

        GridView {
            id: grid

            focus: true

            anchors.fill: parent
            anchors.topMargin: ((cellHeight - gameItemTitleMargin) * Math.max(api.memory.get('settings.global.scaleSelected') - 1.0, 0)) / 2.0 + (api.memory.get('settings.global.borderEnabled') ? vpx(api.memory.get('settings.global.borderWidth')) : 0)

            anchors.leftMargin: vpx(api.memory.get('settings.theme.leftMargin'))
            anchors.rightMargin: vpx(api.memory.get('settings.theme.rightMargin'))

            model: filteredCollection.games

            property real aspectRatio: api.memory.get('settings.gameLibrary.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.gameLibrary.aspectRatioHeight') / api.memory.get('settings.gameLibrary.aspectRatioWidth'))

            cellWidth: width / api.memory.get('settings.gameLibrary.gameViewColumns')
            cellHeight: cellWidth * aspectRatio + gameItemTitleMargin

            displayMarginBeginning: cellHeight * 2
            displayMarginEnd: cellHeight * 2

            highlightRangeMode: GridView.ApplyRange
            highlightFollowsCurrentItem: false

            preferredHighlightBegin: 0
            preferredHighlightEnd: grid.height

            delegate: GamesViewItem {
                itemWidth: GridView.view.cellWidth
                itemHeight: GridView.view.cellHeight - gameItemTitleMargin

                game: modelData
                selected: GridView.isCurrentItem

                assetKey: settingsMetadata.gameLibrary.art.values[api.memory.get('settings.gameLibrary.art')]
                logoVisible: api.memory.get('settings.gameLibrary.logoVisible')
                aspectRatioNative: api.memory.get('settings.gameLibrary.aspectRatioNative')
            }

            highlight: highlightComponent

            Component.onCompleted: {
                grid.currentIndex = gridContainer.focus ? savedGameIndex : -1;
                grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
            }

            Keys.onUpPressed: {
                event.accepted = true;

                sfxNav.play();
                if (grid.currentIndex < api.memory.get('settings.gameLibrary.gameViewColumns')) {
                    header.focus = true;
                } else {
                    moveCurrentIndexUp();
                }
            }

            Keys.onDownPressed: {
                event.accepted = true;

                sfxNav.play();
                const gamesOnFinalRow = model.count % api.memory.get('settings.gameLibrary.gameViewColumns')

                if (gamesOnFinalRow > 0 && model.count - currentIndex > gamesOnFinalRow) {
                    currentIndex = Math.min(currentIndex + api.memory.get('settings.gameLibrary.gameViewColumns'), model.count - 1);
                } else {
                    moveCurrentIndexDown();
                }
            }

            Keys.onLeftPressed: { event.accepted = true; sfxNav.play(); moveCurrentIndexLeft() }
            Keys.onRightPressed: { event.accepted = true; sfxNav.play(); moveCurrentIndexRight() }

            Keys.onPressed: {
                if (api.keys.isPageDown(event)) {
                    event.accepted = true;
                    grid.currentIndex = filteredCollection.navigate(grid.currentIndex, 1) ?? grid.currentIndex;
                }

                if (api.keys.isPageUp(event)) {
                    event.accepted = true;
                    grid.currentIndex = filteredCollection.navigate(grid.currentIndex, -1) ?? grid.currentIndex;
                }

                if (event.isAutoRepeat) {
                    return;
                }

                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    header.focus = true;
                }
            }
        }

        onFocusChanged: {
            if (gridContainer.focus) {
                grid.currentIndex = savedGameIndex;
            } else {
                savedGameIndex = grid.currentIndex;
                grid.currentIndex = -1;
            }
        }
    }

    GamesViewHeader {
        id: header

        Keys.onDownPressed: {
            sfxNav.play();
            gridContainer.focus = true;
        }
    }

    FilteredCollection { id: filteredCollection }

    CollectionTransition {
        id: collectionTransition
        anchors.fill: parent

        pendingCollection: api.collections.get(currentCollectionIndex)
    }

    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        }

        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevCollection();
        }

        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextCollection();
        }
    }

    function prevCollection() {
        currentCollectionIndex = (currentCollectionIndex + api.collections.count - 1) % api.collections.count;
        grid.currentIndex = savedGameIndex = 0;

        gameItemVideoPreviewDebouncer.debounce();
    }

    function nextCollection() {
        currentCollectionIndex = (currentCollectionIndex + 1) % api.collections.count;
        grid.currentIndex = savedGameIndex = 0;

        gameItemVideoPreviewDebouncer.debounce();
    }
}
