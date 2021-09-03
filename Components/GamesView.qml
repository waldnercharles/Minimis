import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

FocusScope {
    id: root
    anchors.fill: parent

    FocusScope {
        id: gridContainer
        anchors.fill: parent
        anchors.topMargin: header.height + vpx(8)

        focus: true

        property var assetKey: settingsMetadata.game.art.values[api.memory.get('settings.game.art')]

        Image {
            id: fakeAsset

            property var fakeSource: {
                if (currentCollection != null) {
                    for (var i = 0; i < currentCollection.games.count; i++) {
                        var game = currentCollection.games.get(i);
                        if (game && game.assets[gridContainer.assetKey]) {
                            return game.assets[gridContainer.assetKey] || '';
                        }
                    }
                }

                return '';
            }

            fillMode: Image.PreserveAspectFit
            source: fakeSource

            asynchronous: !api.memory.get('settings.game.aspectRatioNative')
            visible: false
            enabled: false
        }

        ComponentCache { id: cache; component: gamesViewItemComponent }
        Component { id: gamesViewItemComponent; GamesViewItem { } }

        Component {
            id: highlight

            GamesViewItemHighlight {
                width: grid.currentItem ? grid.currentItem.width : undefined
                height: grid.currentItem ? grid.currentItem.height : undefined 

                x: grid.currentItem ? grid.currentItem.x : 0
                y: grid.currentItem ? grid.currentItem.y : 0
                z: grid.currentItem ? grid.currentItem.z - 1 : 0

                scale: grid.currentItem ? grid.currentItem.scale : 0

                playPreview: grid.playPreview

                game: grid.model ? grid.model.get(grid.currentIndex) : undefined
                muted: collectionTransition.opacity === 1

                visible: grid.currentItem && grid.currentItem.item
            }
        }

        GridView {
            id: grid

            readonly property bool titleEnabled: api.memory.get('settings.game.titleEnabled')
            readonly property real titlePadding: titleEnabled ? vpx(api.memory.get('settings.game.titleFontSize') * 0.25) : 0
            readonly property real titleHeight: titleEnabled ? vpx(api.memory.get('settings.game.titleFontSize')) : 0

            readonly property real reservedSpace: titleEnabled ? titleHeight + + vpx(api.memory.get('settings.game.borderWidth')) + titlePadding * 3 : 0

            Timer {
                id: videoPreviewTimer

                interval: api.memory.get('settings.game.videoPreviewDelay')
                onTriggered: {
                    grid.playPreview = true;
                }
            }

            focus: true

            anchors.fill: parent
            anchors.topMargin: ((cellHeight - reservedSpace) * Math.max(api.memory.get('settings.game.scaleSelected') - 1.0, 0)) / 2.0 + vpx(api.memory.get('settings.game.borderWidth'))
            // anchors.bottomMargin: anchors.topMargin

            anchors.leftMargin: vpx(api.memory.get('settings.theme.leftMargin'))
            anchors.rightMargin: vpx(api.memory.get('settings.theme.rightMargin'))

            model: filteredCollection.games

            property bool playPreview: false
            property real aspectRatio: api.memory.get('settings.game.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.game.aspectRatioHeight') / api.memory.get('settings.game.aspectRatioWidth'))

            cellWidth: width / api.memory.get('settings.game.gameViewColumns')
            cellHeight: cellWidth * aspectRatio + reservedSpace

            displayMarginBeginning: cellHeight * 2
            displayMarginEnd: cellHeight * 2

            highlightRangeMode: GridView.ApplyRange
            highlightFollowsCurrentItem: false

            preferredHighlightBegin: 0
            preferredHighlightEnd: grid.height

            delegate: Item {
                id: container

                width: GridView.view.cellWidth
                height: GridView.view.cellHeight - grid.reservedSpace

                property Item item
                property bool selected: GridView.isCurrentItem

                scale: selected ? api.memory.get('settings.game.scaleSelected'): api.memory.get('settings.game.scale')
                z: selected ? 3 : 1

                Behavior on scale { NumberAnimation { duration: api.memory.get('settings.game.artScaleSpeed'); } }

                Keys.onPressed: {
                    if (event.isAutoRepeat) {
                        return;
                    }

                    if (api.keys.isAccept(event)) {
                        event.accepted = true;
                        savedGameIndex = grid.currentIndex;
                        toGameDetailsView(modelData)
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: 'black'
                    opacity: selected ? 0.0 : api.memory.get('settings.game.darkenAmount')
                    z: 10
                }

                Component.onCompleted: {
                    item = cache.get();

                    item.parent = container;
                    item.anchors.fill = Qt.binding(() => container);
                    item.selected = Qt.binding(() => container.selected);
                    item.playPreview = Qt.binding(() => grid.playPreview);

                    item.titleHeight = Qt.binding(() => grid.titleHeight);
                    item.titlePadding = Qt.binding(() => grid.titlePadding);

                    item.game = modelData;
                }

                Component.onDestruction: {
                    cache.release(item);
                    item = null;
                }
            }

            highlight: highlight

            Component.onCompleted: {
                grid.currentIndex = gridContainer.focus ? savedGameIndex : -1;
                grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
            }

            onCurrentIndexChanged: { grid.resetVideoPreview(); }

            Keys.onUpPressed: {
                event.accepted = true;

                sfxNav.play();
                if (grid.currentIndex < api.memory.get('settings.game.gameViewColumns')) {
                    header.focus = true;
                } else {
                    moveCurrentIndexUp();
                }
            }

            Keys.onDownPressed: {
                event.accepted = true;

                sfxNav.play();
                const gamesOnFinalRow = model.count % api.memory.get('settings.game.gameViewColumns')

                if (gamesOnFinalRow > 0 && model.count - currentIndex > gamesOnFinalRow) {
                    currentIndex = Math.min(currentIndex + api.memory.get('settings.game.gameViewColumns'), model.count - 1);
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
                    grid.positionViewAtIndex(grid.currentIndex, GridView.SnapPosition);
                }

                if (api.keys.isPageUp(event)) {
                    event.accepted = true;
                    grid.currentIndex = filteredCollection.navigate(grid.currentIndex, -1) ?? grid.currentIndex;
                    grid.positionViewAtIndex(grid.currentIndex, GridView.SnapPosition);
                }

                if (event.isAutoRepeat) {
                    return;
                }

                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    header.focus = true;
                }
            }

            function resetVideoPreview() {
                if (api.memory.get('settings.game.previewEnabled')) {
                    videoPreviewTimer.restart();
                } else {
                    videoPreviewTimer.stop();
                }

                grid.playPreview = false;
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

        grid.resetVideoPreview();
    }

    function nextCollection() {
        currentCollectionIndex = (currentCollectionIndex + 1) % api.collections.count;
        grid.currentIndex = savedGameIndex = 0;

        grid.resetVideoPreview();
    }
}
