import QtQuick 2.3
import QtQml.Models 2.10
import QtGraphicalEffects 1.0

ListView {
    id: root

    height: vpx(33)

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top

        topMargin: height / 2.0
        bottomMargin: height / 2.0
    }

    spacing: vpx(12)

    orientation: ListView.Horizontal
    layoutDirection: Qt.RightToLeft

    model: ObjectModel {
        Button {
            id: settingsButton
            icon: '\uf013'

            width: root.height; height: root.height
            circle: true

            selected: root.focus && ListView.isCurrentItem

            onActivated: {
                toSettingsView();
            }
        }

        Button {
            id: sortButton
            text: sortDropdown.items[sortDropdown.checkedIndex]

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { sortDropdown.toggle() }

            Dropdown {
                id: sortDropdown
                focus: parent.selected

                items: ['By Title', 'By Developer', 'By Publisher', 'By Genre', 'By Year', 'By Players', 'By Rating', 'By Last Played']
                checkedIcon: orderByDirection === Qt.AscendingOrder ? '\uf0d8 ' : '\uf0d7 '

                checkedIndex: orderByIndex

                onActivated: {
                    if (orderByIndex === checkedIndex) {
                        orderByDirection = orderByDirection === Qt.AscendingOrder ? Qt.DescendingOrder : Qt.AscendingOrder;
                    } else {
                        orderByIndex = checkedIndex;
                        orderByDirection = Qt.AscendingOrder;
                    }
                }
            }
        }

        Button {
            id: filterButton
            text: filterDropdownModel.get(filterDropdown.checkedIndex).name

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { filterDropdown.toggle(); }

            ListModel {
                id: filterDropdownModel

                ListElement { name: 'All Games' }
                ListElement { name: 'Favorites' }
            }

            Dropdown {
                id: filterDropdown
                focus: parent.selected

                items: filterDropdownModel
                roleName: 'name'

                checkedIndex: filterByFavorites ? 1 : 0

                onActivated: {
                    if (checkedIndex === 0) {
                        filterByFavorites = false;
                    }

                    if (checkedIndex === 1) {
                        filterByFavorites = true;
                    }
                }
            }
        }

        Button {
            id: collectionsButton
            text: currentCollection.name

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { collectionsDropdown.toggle(); }

            Dropdown {
                id: collectionsDropdown
                focus: parent.selected

                items: api.collections
                roleName: 'name'

                checkedIndex: currentCollectionIndex

                onActivated: {
                    currentCollectionIndex = checkedIndex;
                    currentCollection = api.collections.get(checkedIndex);
                }
            }
        }
    }

    Keys.onDownPressed: {
        sfxNav.play();
        showcase.focus = true;
    }

}