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

    Text {
        id: listViewTitle
        anchors.left: parent.left

        font.family: subtitleFont.name
        font.pixelSize: vpx(18)

        color: api.memory.get('settings.theme.textColor')
        opacity: parent.focus ? 1 : 0.2
    }

    ListView {
        id: listView
        anchors.top: listViewTitle.bottom; anchors.topMargin: vpx(10)
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom;

        focus: parent.focus
        orientation: ListView.Horizontal

        spacing: vpx(5)

        preferredHighlightBegin: 0
        preferredHighlightEnd: listView.width

        highlightResizeDuration: 0
        highlightMoveDuration: 0
        highlightRangeMode: ListView.ApplyRange
        highlightFollowsCurrentItem: true

        highlight: GamesViewItemHighlight {
            game: listView.model ? listView.model.get(listView.currentIndex) : undefined
            item: listView.currentItem

            visible: listView.focus
            muted: false
        }

        delegate: GamesViewItem {
            itemHeight: listView.height
            itemWidth: root.aspectRatioNative ? undefined : itemHeight / aspectRatio

            game: modelData
            selected: ListView.isCurrentItem && listView.focus

            assetKey: root.assetKey
            logoVisible: root.logoVisible
            aspectRatioNative: root.aspectRatioNative
        }
    }
}