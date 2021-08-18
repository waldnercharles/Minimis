import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property int savedIndex: 0;

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

        property var gradientHeight: 0.0133

        GridView {
            id: grid

            focus: true

            anchors.leftMargin: vpx(settings.theme.leftMargin.value + settings.game.borderWidth.value)
            anchors.rightMargin: vpx(settings.theme.rightMargin.value + settings.game.borderWidth.value)

            model: currentCollection != null ? currentCollection.games : null

            cellWidth: width / settings.game.gameViewColumns.value
            cellHeight: cellWidth * settings.game.aspectRatioHeight.value / settings.game.aspectRatioWidth.value

            displayMarginBeginning: cellHeight * 2
            displayMarginEnd: cellHeight * 2

            anchors.fill: parent
            anchors.topMargin: (cellHeight + vpx(settings.game.borderWidth.value)) * (settings.game.scaleSelected.value - 1.0) / 2.0 + parent.height * gridContainer.gradientHeight * 2
            anchors.bottomMargin: anchors.topMargin

            highlight: GamesViewItemHighlight {
                width: grid.currentItem ? grid.currentItem.width  : 0
                height: grid.currentItem ? grid.currentItem.height : 0

                game: grid.model ? grid.model.get(grid.currentIndex) : null
                muted: collectionTransition.pendingCollection != currentCollection

                scale: grid.currentItem ? grid.currentItem.scale : 0.0

                z: (grid.currentItem ? grid.currentItem.z : 0) - 1
            }

            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0

            highlightRangeMode: GridView.ApplyRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: grid.height

            delegate: GamesViewItem {
                id: item

                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                selected: GridView.isCurrentItem

                Behavior on scale { PropertyAnimation { duration: 100; } }

                Keys.onPressed: {
                    // if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    //     root.launchRequested();
                    // }
                }
            }

            Keys.onUpPressed: {
                sfxNav.play();
                if (grid.currentIndex < settings.game.gameViewColumns.value) {
                    header.focus = true;
                } else {
                    moveCurrentIndexUp();
                }
            }
            Keys.onDownPressed: {
                sfxNav.play();

                const gamesOnFinalRow = model.count % settings.game.gameViewColumns.value

                if (gamesOnFinalRow > 0 && model.count - currentIndex > gamesOnFinalRow) {
                    currentIndex = Math.min(currentIndex + settings.game.gameViewColumns.value, model.count - 1);
                } else {
                    moveCurrentIndexDown();
                }
            }
            Keys.onLeftPressed: { sfxNav.play(); moveCurrentIndexLeft() }
            Keys.onRightPressed: { sfxNav.play(); moveCurrentIndexRight() }

            Keys.onPressed: {
                if (event.isAutoRepeat) {
                    return;
                }

                if (api.keys.isPrevPage(event)) {
                    event.accepted = true;
                    prevCollection();
                    return;
                }
                if (api.keys.isNextPage(event)) {
                    event.accepted = true;
                    nextCollection();
                    return;
                }
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
            if (focus) {
                grid.currentIndex = savedIndex;
            } else {
                savedIndex = grid.currentIndex;
                grid.currentIndex = -1;
            }
        }
    }

    CollectionTransition {
        id: collectionTransition
        anchors.fill: parent

        pendingCollection: api.collections.get(currentCollectionIndex)

    }

    function prevCollection() {
        currentCollectionIndex = (currentCollectionIndex + api.collections.count - 1) % api.collections.count;
    }

    function nextCollection() {
        currentCollectionIndex = (currentCollectionIndex + 1) % api.collections.count;
    }
}
