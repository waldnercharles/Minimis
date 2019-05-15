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


import QtQuick 2.0
import "layer_filter"
import "layer_gameinfo"
import "layer_grid"
import "layer_platform"


FocusScope {
    PlatformBar {
        id: topbar
        z: 300
        anchors {
            top: parent.top;
            left: parent.left; right: parent.right
        }
    }

    BackgroundImage {
        anchors {
            top: topbar.bottom; bottom: parent.bottom
            left: parent.left; right: parent.right
        }

        game: gamegrid.currentGame
    }

    GameGrid {
        id: gamegrid

        focus: true

        anchors {
            top: topbar.bottom; bottom: parent.bottom;
            left: parent.left; right: parent.right;
            leftMargin: vpx(80); rightMargin: vpx(80);
        }

        platform: topbar.currentCollection
        onNextPlatformRequested: topbar.next()
        onPrevPlatformRequested: topbar.prev()
        onDetailsRequested: gamepreview.focus = true
        onFiltersRequested: filter.focus = true
        onLaunchRequested: launchGame()
    }

    // GamePreview {
    //     id: gamepreview

    //     panelWidth: parent.width * 0.7 + vpx(72)
    //     anchors {
    //         top: topbar.bottom; bottom: parent.bottom
    //         left: parent.left; right: parent.right
    //     }

    //     game: gamegrid.currentGame
    //     onOpenRequested: gamepreview.focus = true
    //     onCloseRequested: gamegrid.focus = true
    //     onFiltersRequested: filter.focus = true
    //     onLaunchRequested: launchGame()
    // }

    // FilterLayer {
    //     id: filter
    //     anchors.fill: parent

    //     onCloseRequested: gamegrid.focus = true
    //     onTitleFilterChanged: gamegrid.filterTitle = tfil
    // }

    Component.onCompleted: {
        var coll_idx = api.memory.get('collectionIndex') || 0;
        var game_idx = api.memory.get('gameIndex') || 0;

        // if (coll_idx < api.collections.count)
        //     topbar.collectionIndex = coll_idx;

        if (game_idx < api.collections.get(coll_idx).games.count)
            gamegrid.gameIndex = game_idx;

        gamegrid.memoryLoaded = true;
    }

    function launchGame() {
        api.memory.set('collectionIndex', topbar.collectionIndex);
        api.memory.set('gameIndex', gamegrid.gameIndex);
        gamegrid.currentGame.launch();
    }
}
