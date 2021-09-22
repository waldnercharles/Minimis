import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property bool aspectRatioNative;

    property real aspectRatioWidth;
    property real aspectRatioHeight;

    property string assetKey;
    property bool logoVisible;

    readonly property real aspectRatio: aspectRatioNative ? 1 : aspectRatioHeight / aspectRatioWidth;

    readonly property var currentGame: listView.currentItem ? listView.currentItem.game : undefined

    property alias title: listViewTitle.text
    property alias model: listView.model

    Column {
        anchors.fill: parent
        spacing: vpx(10)

        Text {
            id: listViewTitle

            font.family: subtitleFont.name
            font.pixelSize: vpx(18)

            color: api.memory.get('settings.theme.textColor')
            opacity: root.focus ? 1 : 0.2

            layer.enabled: true
            layer.effect: DropShadowLow { cached: true }
        }

        ListView {
            id: listView

            FlickableDelegateBorder {
                parent: listView.contentItem
                currentItem: listView.currentItem

                visible: listView.focus
            }

            height: parent.height - y
            width: parent.width

            focus: root.focus
            orientation: ListView.Horizontal

            spacing: vpx(5)

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
                itemHeight: listView.height
                itemWidth: root.aspectRatioNative ? undefined : itemHeight / root.aspectRatio

                game: modelData
                selected: ListView.isCurrentItem && listView.focus

                assetKey: root.assetKey
                logoVisible: root.logoVisible
                aspectRatioNative: root.aspectRatioNative
            }

            Keys.onLeftPressed: { sfxNav.play(); event.accepted = false; }
            Keys.onRightPressed: { sfxNav.play(); event.accepted = false; }
        }
    }
}