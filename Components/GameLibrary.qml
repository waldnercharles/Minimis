import QtQuick 2.15
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import SortFilterProxyModel 0.2

FocusScope {
    property alias model: grid.model

    readonly property var currentGame: grid.currentItem ? grid.currentItem.game : undefined

    clip: true

    FakeAsset { id: fakeAsset; collection: currentCollection }

    GridView {
        id: grid

        readonly property int numberOfColumns: Math.max(api.memory.get('settings.gameLibrary.gameViewColumns'), 1)
        readonly property real inverseSelectedScale: Math.max(api.memory.get('settings.global.scaleSelected') - 1.0, 0)
        readonly property real borderWidth: (api.memory.get('settings.global.borderEnabled') ? vpx(api.memory.get('settings.global.borderWidth')) : 0);

        property real aspectRatio: api.memory.get('settings.gameLibrary.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.gameLibrary.aspectRatioHeight') / api.memory.get('settings.gameLibrary.aspectRatioWidth'))

        anchors.fill: parent
        anchors.topMargin: ((cellHeight - gameItemTitleMargin) * inverseSelectedScale) / 2.0 + borderWidth
        anchors.bottomMargin: anchors.topMargin

        anchors.leftMargin: (parent.width / numberOfColumns) * inverseSelectedScale / 2 + borderWidth
        anchors.rightMargin: anchors.leftMargin

        focus: parent.focus

        FlickableDelegateBorder {
            parent: grid.contentItem
            currentItem: grid.currentItem

            visible: grid.focus
        }

        cellWidth: width / numberOfColumns
        cellHeight: cellWidth * aspectRatio + gameItemTitleMargin

        preferredHighlightBegin: 0
        preferredHighlightEnd: grid.height - cellHeight

        highlightRangeMode: GridView.ApplyRange

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 300

        keyNavigationWraps: false

        highlight: GameDelegateHighlight {
            item: grid.currentItem
            visible: grid.focus

            z: item.z - 1

            muted: false
        }

        delegate: GameDelegate {
            itemWidth: GridView.view.cellWidth
            itemHeight: GridView.view.cellHeight - gameItemTitleMargin

            game: modelData
            selected: GridView.isCurrentItem && grid.focus

            assetKey: settingsMetadata.gameLibrary.art.values[api.memory.get('settings.gameLibrary.art')]
            logoVisible: api.memory.get('settings.gameLibrary.logoVisible')
            aspectRatioNative: api.memory.get('settings.gameLibrary.aspectRatioNative')
        }

        Component.onCompleted: {
            // grid.currentIndex = gridContainer.focus ? savedGameIndex : -1;
            grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
        }

        Keys.onUpPressed: { sfxNav.play(); event.accepted = false; }
        Keys.onDownPressed: { sfxNav.play(); event.accepted = false; }
        Keys.onLeftPressed: { sfxNav.play(); event.accepted = false; }
        Keys.onRightPressed: { sfxNav.play(); event.accepted = false; }
    }
}