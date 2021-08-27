import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

FocusScope {
    id: root
    anchors.fill: parent

    GamesViewHeader {
        id: header

        Keys.onDownPressed: {
            sfxNav.play();
            gridContainer.focus = true;
        }
    }

    FocusScope {
        id: gridContainer
        anchors.fill: parent
        anchors.topMargin: header.height

        focus: true

        property var assetKey: settingsMetadata.game.art.values[api.memory.get('settings.game.art')]
        property var gradientHeight: 0.0133

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

        GridView {
            id: grid

            Timer {
                id: videoPreviewTimer

                interval: 800
                onTriggered: {
                    grid.playPreview = true;
                }
            }

            focus: true

            anchors.fill: parent
            anchors.topMargin: (cellHeight + vpx(api.memory.get('settings.game.borderWidth'))) * (api.memory.get('settings.game.scaleSelected') - 1.0) / 2.0 + parent.height * gridContainer.gradientHeight * 2
            anchors.bottomMargin: anchors.topMargin

            anchors.leftMargin: vpx(api.memory.get('settings.theme.leftMargin'))
            anchors.rightMargin: vpx(api.memory.get('settings.theme.rightMargin'))

            model: filteredCollection.games

            property bool playPreview: false
            property real aspectRatio: api.memory.get('settings.game.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.game.aspectRatioHeight') / api.memory.get('settings.game.aspectRatioWidth'))

            cellWidth: width / api.memory.get('settings.game.gameViewColumns')
            cellHeight: cellWidth * aspectRatio

            displayMarginBeginning: cellHeight * 2
            displayMarginEnd: cellHeight * 2


            highlight: GamesViewItemHighlight {
                property Item currentItem: grid.currentItem

                playPreview: grid.playPreview

                width: currentItem ? currentItem.width  : 0
                height: currentItem ? currentItem.height : 0

                game: grid.model ? grid.model.get(grid.currentIndex) : null
                muted: collectionTransition.opacity === 1

                scale: currentItem ? currentItem.scale : 0.0

                z: (currentItem ? currentItem.z : 0) - 1
            }

            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0

            highlightRangeMode: GridView.ApplyRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: grid.height

            delegate: Item {
                id: container

                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                property Item item
                property bool selected: GridView.isCurrentItem

                scale: selected ? api.memory.get('settings.game.scaleSelected'): api.memory.get('settings.game.scale')
                z: selected ? 3 : 1

                Behavior on scale { NumberAnimation { duration: 100; } }

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

                Component.onCompleted: {
                    item = cache.get();

                    item.parent = container;
                    item.anchors.fill = Qt.binding(() => container);
                    item.selected = Qt.binding(() => container.selected);
                    item.playPreview = Qt.binding(() => grid.playPreview);

                    item.game = modelData;
                }

                Component.onDestruction: {
                    cache.release(item);
                    item = null;
                }
            }

            // delegate: GamesViewItem {
            //     id: item

            //     width: GridView.view.cellWidth
            //     height: GridView.view.cellHeight

            //     selected: GridView.isCurrentItem
            //     playPreview: grid.playPreview 

            //     Behavior on scale { PropertyAnimation { duration: 100; } }

            //     Keys.onPressed: {
            //         if (event.isAutoRepeat) {
            //             return;
            //         }

            //         if (api.keys.isAccept(event)) {
            //             event.accepted = true;
            //             savedGameIndex = grid.currentIndex;
            //             toGameDetailsView(modelData)
            //         }
            //     }
            // }

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
                    grid.currentIndex = filteredCollection.navigateLetter(grid.currentIndex, 1);
                    grid.positionViewAtIndex(grid.currentIndex, GridView.SnapPosition);
                }

                if (api.keys.isPageUp(event)) {
                    event.accepted = true;
                    grid.currentIndex = filteredCollection.navigateLetter(grid.currentIndex, -1);
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

        layer.enabled: true
        layer.effect: OpacityMask {
            width: root.width; height: root.height

            maskSource: LinearGradient {
                width: root.width; height: root.height

                start: Qt.point(0, 0)
                end: Qt.point(0, root.height)

                gradient: Gradient {
                    GradientStop { position: gridContainer.gradientHeight / 1.2; color: 'transparent' }
                    GradientStop { position: gridContainer.gradientHeight; color: 'white' }
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
