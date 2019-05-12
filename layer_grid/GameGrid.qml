// Pegasus Frontend
// Copyright (C) 2017-2019  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.3


FocusScope {
    id: root

    property bool memoryLoaded: false

    property string filterTitle: ""

    property var platform
    property alias gameIndex: grid.currentIndex
    readonly property bool gameIndexValid: 0 <= gameIndex && gameIndex < grid.count
    readonly property var currentGame: gameIndexValid ? platform.games.get(gameIndex) : null

    signal detailsRequested
    signal filtersRequested
    signal nextPlatformRequested
    signal prevPlatformRequested
    signal launchRequested

    onPlatformChanged: if (memoryLoaded && grid.count) gameIndex = 0;

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevPlatformRequested();
            return;
        }
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextPlatformRequested();
            return;
        }
        if (api.keys.isDetails(event)) {
            event.accepted = true;
            detailsRequested();
            return;
        }
        if (api.keys.isFilters(event)) {
            event.accepted = true;
            filtersRequested();
            return;
        }
    }

    GridView {
        id: grid

        focus: true

        anchors {
            fill: parent;
            leftMargin: vpx(7);
            rightMargin: vpx(7);
        }

        model: platform.games

        property real cellHeightRatio: 0.46739130434782608695652173913043

        cellWidth: width / 3
        cellHeight: cellWidth * cellHeightRatio

        displayMarginBeginning: cellHeight * 2
        displayMarginEnd: cellHeight * 2

        anchors.topMargin: cellHeight * 0.14
        anchors.bottomMargin: cellHeight * 0.07

        highlightMoveDuration: 150

        delegate: GameGridItem {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            selected: GridView.isCurrentItem

            game: modelData

            onClicked: GridView.view.currentIndex = index
            onDoubleClicked: {
                GridView.view.currentIndex = index;
                root.detailsRequested();
            }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    root.launchRequested();
                }
            }
        }
    }
}
