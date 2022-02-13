import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2
import Qt.labs.qmlmodels 1.0

FocusScope {
    id: root

    readonly property bool scaleEnabled: api.memory.get('settings.cardTheme.scaleEnabled')
    readonly property real scaleSelected: api.memory.get('settings.cardTheme.scaleSelected')
    readonly property real scaleUnselected: api.memory.get('settings.cardTheme.scale')

    readonly property bool animationEnabled: api.memory.get('settings.cardTheme.animationEnabled')
    readonly property int animationArtScaleDuration: api.memory.get('settings.cardTheme.animationArtScaleSpeed')

    anchors.fill: parent

    property var game
    property var gameMedia: [];

    onGameChanged: {
        const media = [];

        if (game) {
            game.assets.videoList.forEach(v => media.push(v));
            game.assets.screenshotList.forEach(v => media.push(v));
            game.assets.backgroundList.forEach(v => media.push(v));
        }

        gameMedia = media;
    }

    MediaView {
        id: mediaView
        anchors.fill: root

        media: gameMedia

        onClosed: {
            listView.focus = true
            mediaListView.currentIndex = mediaView.currentIndex
        }
    }

    ListModel {
        id: listModel

        ListElement { type: 'gameDetails' }
        ListElement { type: 'media' }
    }

    SortFilterProxyModel {
        id: proxyModel
        filters: ExpressionFilter {
            expression: {
                gameMedia.length;
                return type === 'gameDetails' || (type === 'media' && gameMedia.length > 0);
            }
        }

        sourceModel: listModel
    }

    DelegateChooser {
        id: listViewDelegate

        role: 'type'

        DelegateChoice {
            roleValue: 'gameDetails'

            FocusScope {
                id: gameDetails
                width: listView.width
                height: listView.height 

                readonly property bool selected: root.focus && ListView.isCurrentItem

                ColumnLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    GameMetadata {
                        width: parent.width
                        height: parent.height * 0.5

                        game: root.game

                        bottomMargin: vpx(10)
                    }

                    GameDetailsButtons {
                        game: root.game

                        focus: gameDetails.selected

                        Layout.fillWidth: true
                        Layout.topMargin: vpx(15)
                        Layout.bottomMargin: vpx(50)
                    }
                }
            }
        }

        DelegateChoice {
            roleValue: 'media'

            FocusScope {
                id: mediaScope

                width: root.width
                height: vpx(150)

                Column {
                    anchors.fill: parent
                    spacing: vpx(10)

                    focus: parent.focus

                    Text {
                        text: 'Media'

                        font.family: subtitleFont.name
                        font.pixelSize: vpx(18)

                        color: api.memory.get('settings.globalTheme.textColor')
                        opacity: root.focus ? 1 : 0.2

                        layer.enabled: true
                        layer.effect: DropShadowLow { cached: true }
                    }

                    ListView {
                        id: mediaListView

                        DelegateBorder {
                            parent: mediaListView.contentItem
                            currentItem: mediaListView.currentItem

                            visible: mediaScope.focus
                        }

                        width: root.width;
                        height: vpx(150)

                        focus: parent.focus
                        orientation: ListView.Horizontal

                        model: gameMedia

                        highlightResizeDuration: 0
                        highlightMoveDuration: 300
                        highlightRangeMode: ListView.ApplyRange
                        highlightFollowsCurrentItem: true

                        displayMarginBeginning: width * 2
                        displayMarginEnd: width * 2

                        // highlight: GamesViewItemBorder {
                        //     width: mediaListView.currentItem ? mediaListView.currentItem.width : undefined
                        //     height: mediaListView.currentItem ? mediaListView.currentItem.height : undefined

                        //     scale: mediaListView.currentItem ? mediaListView.currentItem.scale : 0

                        //     z: mediaListView.currentItem ? mediaListView.currentItem.z - 1 : 0

                        //     visible: mediaListView.currentItem != null && mediaScope.focus
                        // }

                        Keys.onLeftPressed: { sfxNav.play(); event.accepted = false; }
                        Keys.onRightPressed: { sfxNav.play(); event.accepted = false; }

                        delegate: MediaDelegate {
                            asset: modelData
                            height: vpx(150)

                            onActivated: {
                                mediaView.currentIndex = mediaListView.currentIndex
                                mediaView.focus = true;
                            }
                        }
                    }
                }
            }
        }
    }

    ListView {
        id: listView

        focus: true
        opacity: focus ? 1 : 0
        Behavior on opacity { OpacityAnimator { duration: 200 } }

        anchors { left: parent.left; right: parent.right }

        anchors.leftMargin: vpx(api.memory.get('settings.globalTheme.leftMargin'));
        anchors.rightMargin: vpx(api.memory.get('settings.globalTheme.rightMargin'));

        displayMarginBeginning: root.height
        displayMarginEnd: root.height

        preferredHighlightBegin: 0
        preferredHighlightEnd: vpx(175)

        highlightResizeDuration: 0
        highlightMoveDuration: 300
        highlightRangeMode: ListView.StrictlyEnforceRange

        height: vpx(150)

        y: parent.height - height - (proxyModel.count > 1 ? vpx(75) : vpx(0))

        model: proxyModel
        delegate: listViewDelegate
    }
}