import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root
    readonly property real aspectRatio: api.memory.get('settings.gameLibrary.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.gameLibrary.aspectRatioHeight') / api.memory.get('settings.gameLibrary.aspectRatioWidth'))

    property alias title: listViewTitle.text
    property alias model: listView.model

    anchors.left: parent.left; anchors.right: parent.right

    Component {
        id: highlightComponent

        GamesViewItemHighlight {
            game: listView.model ? listView.model.get(listView.currentIndex) : undefined
            item: listView.currentItem

            muted: false
        }
    }

    FakeAsset { id: fakeAsset; collection: currentCollection }

    Text {
        id: listViewTitle
        anchors.left: parent.left; anchors.leftMargin: vpx(10)

        font.family: subtitleFont.name
        font.pixelSize: vpx(18)

        color: api.memory.get('settings.theme.textColor')
        opacity: parent.focus ? 1 : 0.2
    }

    ListView {
        id: listView
        anchors.top: listViewTitle.bottom; anchors.topMargin: vpx(10)
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom;

        focus: true
        orientation: ListView.Horizontal

        spacing: vpx(5)

        cacheBuffer: listView.width * model.count

        preferredHighlightBegin: 0
        preferredHighlightEnd: listView.width

        highlightResizeDuration: 0
        highlightMoveDuration: 0
        highlightRangeMode: ListView.ApplyRange
        highlightFollowsCurrentItem: true

        highlight: highlightComponent
        delegate: GamesViewItem {
            itemHeight: listView.height
            selected: ListView.isCurrentItem && listView.focus

            scale: selected ? api.memory.get('settings.global.scaleSelected'): api.memory.get('settings.global.scale')
            z: selected ? 3 : 1

            Behavior on scale { NumberAnimation { duration: api.memory.get('settings.global.animationEnabled') ? api.memory.get('settings.global.animationArtScaleSpeed') : 0; } }

            game: modelData
        }
    }
}