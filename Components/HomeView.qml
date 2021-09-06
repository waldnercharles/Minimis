import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import SortFilterProxyModel 0.2

FocusScope {
    id: root

    anchors.fill: parent
    focus: true

    SortFilterProxyModel {
        id: recentlyPlayedGames

        sourceModel: api.allGames
        filters: IndexFilter { maximumIndex: 15} 
        sorters: RoleSorter { roleName: 'lastPlayed'; sortOrder: Qt.DescendingOrder }
    }

    ListView {
        anchors.fill: parent
        focus: true

        model: ObjectModel {
            HorizontalListView { 
                id: recentlyPlayed

                title: 'Recently Played'
                model: recentlyPlayedGames // api.allGames

                height: vpx(200)
            }

            // HorizontalListView { 
            //     id: favorites
            //     title: 'Favorites'

            //     height: vpx(100)
            // }
        }
    }
}