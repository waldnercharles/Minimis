import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property bool muted: false

    GridView {
        id: grid

        focus: true

        model: currentCollection != null ? currentCollection.games : null

        property real cellHeightRatio: 0.46739130434782608695652173913043

        cellWidth: width / 3
        cellHeight: cellWidth * cellHeightRatio

        displayMarginBeginning: cellHeight * 2
        displayMarginEnd: cellHeight * 2

        anchors.fill: parent
        anchors.topMargin: cellHeight * 0.14
        anchors.bottomMargin: cellHeight * 0.07

        highlight: GamesViewItemHighlight {
            width: grid.currentItem ? grid.currentItem.width  : 0
            height: grid.currentItem ? grid.currentItem.height : 0

            game: grid.model ? grid.model.get(grid.currentIndex) : null
            muted: root.muted

            scale: grid.currentItem ? grid.currentItem.scale : 0.0

            z: (grid.currentItem ? grid.currentItem.z : 0) - 1
        }

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0

        highlightRangeMode: GridView.ApplyRange
        preferredHighlightBegin: ((grid.cellHeight - grid.cellHeight * settings.game.scale.value) + (grid.cellHeight * settings.game.scaleSelected.value - grid.cellHeight)) / 2.0
        preferredHighlightEnd: grid.height - preferredHighlightBegin

        delegate: GamesViewItem {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            selected: GridView.isCurrentItem

            Behavior on scale { PropertyAnimation { duration: 100; } }

            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    root.launchRequested();
                }
            }
        }
    }
}
