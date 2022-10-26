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
        listView.currentIndex = 0;
    }

    onFocusChanged: {
        listView.currentIndex = 0;
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
                    id: columnLayout
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

                    GameMetadata {
                        Layout.preferredWidth: root.width * 0.7
                        Layout.preferredHeight: root.height * 0.5

                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

                        game: root.game
                    }

                    GameDetailsButtons {
                        id: buttons

                        game: root.game

                        focus: gameDetails.selected

                        Layout.fillWidth: true
                        Layout.bottomMargin: height * 0.5

                        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
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
                    spacing: vpx(10) * uiScale

                    Text {
                        text: 'Media'

                        font.family: subtitleFont.name
                        font.pixelSize: vpx(18) * uiScale

                        color: api.memory.get('settings.general.textColor')
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

                        focus: mediaScope.focus
                        orientation: ListView.Horizontal

                        model: gameMedia

                        highlightResizeDuration: 0
                        highlightMoveDuration: 300
                        highlightRangeMode: ListView.ApplyRange
                        highlightFollowsCurrentItem: true

                        displayMarginBeginning: width * 2
                        displayMarginEnd: width * 2

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

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

        anchors.leftMargin: vpx(api.memory.get('settings.general.leftMargin'));
        anchors.rightMargin: vpx(api.memory.get('settings.general.rightMargin'));
        anchors.bottomMargin: proxyModel.count > 1 ? vpx(75) : vpx(0)

        displayMarginBeginning: root.height
        displayMarginEnd: root.height

        preferredHighlightBegin: 0
        preferredHighlightEnd: vpx(175)

        highlightResizeDuration: 0
        highlightMoveDuration: 300
        highlightRangeMode: ListView.StrictlyEnforceRange

        height: vpx(150)

        model: proxyModel
        delegate: listViewDelegate
    }
}