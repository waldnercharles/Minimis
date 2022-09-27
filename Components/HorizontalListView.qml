import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property var games;
    property bool indexed;

    property bool aspectRatioNative;

    property real aspectRatioWidth;
    property real aspectRatioHeight;

    property string assetKey;
    property bool logoVisible;

    readonly property real aspectRatio: aspectRatioNative ? 1 : aspectRatioHeight / aspectRatioWidth;

    readonly property var currentGame: listView.currentItem ? listView.currentItem.game : undefined

    property alias title: listViewTitle.text

    Column {
        anchors.fill: parent
        spacing: vpx(10) * uiScale

        Text {
            id: listViewTitle

            font.family: subtitleFont.name
            font.pixelSize: vpx(18) * uiScale

            color: api.memory.get('settings.general.textColor')
            opacity: root.focus ? 1 : 0.2

            layer.enabled: true
            layer.effect: DropShadowLow { cached: true }
        }

        ListView {
            id: listView

            DelegateBorder {
                parent: listView.contentItem
                currentItem: listView.currentItem

                visible: listView.focus
            }

            model: indexed ? games.length : games

            height: parent.height - y
            width: parent.width

            focus: root.focus
            orientation: ListView.Horizontal

            highlightResizeDuration: 0
            highlightMoveDuration: 300
            highlightRangeMode: ListView.ApplyRange
            highlightFollowsCurrentItem: true

            displayMarginBeginning: width * 2
            displayMarginEnd: width * 2

            highlight: GameDelegateHighlight {
                item: listView.currentItem
                visible: listView.focus

                muted: false
            }

            delegate: GameDelegate {
                itemWidth: root.aspectRatioNative ? undefined : height / root.aspectRatio
                itemHeight: listView.height

                game: indexed ? api.allGames.get(games[index]) : modelData
                selected: ListView.isCurrentItem && listView.focus

                assetKey: root.assetKey
                logoVisible: root.logoVisible
                aspectRatioNative: root.aspectRatioNative

                sourceDebounceDuration: 0
            }

            Keys.onLeftPressed: { sfxNav.play(); event.accepted = false; }
            Keys.onRightPressed: { sfxNav.play(); event.accepted = false; }
        }
    }
}