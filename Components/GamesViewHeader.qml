import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10

import "../utils.js" as Utils

FocusScope {
    id: root

    property string text: ''
    property bool titleOnly 

    anchors {
        left: parent.left; right: parent.right; top: parent.top;
        leftMargin: vpx(api.memory.get('settings.theme.leftMargin'))
        rightMargin: vpx(api.memory.get('settings.theme.rightMargin'))
    }

    height: vpx(75)

    Rectangle {
        anchors.fill: parent
        color: api.memory.get('settings.theme.backgroundColor')

        Item {
            id: container

            anchors.fill: parent

            Rectangle {
                id: background
                color: api.memory.get('settings.theme.accentColor')

                width: (title.visible ? title.width : logo.width) + vpx(80)
                height: root.height

                radius: vpx(3)

                layer.enabled: true
                layer.effect: DropShadow {
                    anchors.fill: background
                    horizontalOffset: vpx(0); verticalOffset: vpx(4)

                    samples: 5
                    color: '#77000000';
                    source: background
                }
            }

            Image {
                id: logo

                height: root.height - vpx(30)
                anchors.centerIn: background

                fillMode: Image.PreserveAspectFit
                source: currentCollection ? '../assets/logos/png/' + Utils.getPlatformName(currentCollection.shortName) + '.png' : ''
                sourceSize: Qt.size(0, logo.height)
                smooth: true
                asynchronous: false
                visible: !title.visible

                layer.enabled: true
                layer.effect: ColorOverlay {
                    anchors.fill: logo
                    source: logo
                    color: api.memory.get('settings.theme.backgroundColor')
                }
            }

            Text {
                id: title

                height: root.height - vpx(30)
                anchors.centerIn: background

                text: root.text || (currentCollection != null ? currentCollection.name : '')

                font.family: titleFont.name
                font.pixelSize: vpx(36)
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: api.memory.get('settings.theme.backgroundColor')

                visible: root.text || logo.status === Image.Null || logo.status === Image.Error
            }

            ListView {
                id: buttons
                focus: true

                visible: !titleOnly

                model: ObjectModel {
                    Button {
                        icon: '\uf013'

                        width: parent.height; height: parent.height
                        circle: true

                        selected: root.focus && ListView.isCurrentItem

                        onActivated: {
                            toSettingsView();
                        }
                    }

                    Button {
                        icon: '\uf0b0'
                        text: buttons.getFilterText()

                        height: parent.height
                        circle: true
                        selected: root.focus && ListView.isCurrentItem

                        onActivated: {
                            if (!filterByFavorites && !filterByBookmarks) {
                                filterByFavorites = true;
                                filterByBookmarks = false;
                            } else if (filterByFavorites && filterByBookmarks) {
                                filterByFavorites = false;
                                filterByBookmarks = false;
                            } else if (filterByFavorites) {
                                filterByFavorites = false;
                                filterByBookmarks = true;
                            } else if (filterByBookmarks) {
                                filterByFavorites = true;
                                filterByBookmarks = true;
                            }
                        }
                    }
                }

                spacing: vpx(12)

                orientation: ListView.Horizontal
                layoutDirection: Qt.RightToLeft

                anchors.fill: parent
                anchors.centerIn: parent

                anchors.topMargin: parent.height / 4.0
                anchors.bottomMargin: anchors.topMargin

                function getFilterText() {
                    if (!filterByFavorites && !filterByBookmarks) {
                        return 'All Games';
                    }

                    if (filterByFavorites && filterByBookmarks) {
                        return 'Favorites and Bookmarks';
                    }

                    if (filterByFavorites) {
                        return 'Favorites';
                    }

                    if (filterByBookmarks) {
                        return 'Bookmarks';
                    }
                }
            }
        }
    }
}