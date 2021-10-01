import QtQuick 2.15
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    signal openCollectionsMenu
    signal openNavigationMenu

    property alias model: grid.model

    readonly property var currentGame: grid.currentItem ? grid.currentItem.game : undefined

    clip: true

    FakeAsset { id: fakeAsset; collection: currentCollection }

    GridView {
        id: grid

        readonly property int numberOfColumns: Math.max(api.memory.get('settings.layout.library.columns'), 1)
        readonly property real inverseSelectedScale: Math.max(api.memory.get('settings.cardTheme.scaleSelected') - 1.0, 0)
        readonly property real borderWidth: (api.memory.get('settings.cardTheme.borderEnabled') ? vpx(api.memory.get('settings.cardTheme.borderWidth')) : 0);

        property real aspectRatio: api.memory.get('settings.layout.library.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.layout.library.aspectRatioHeight') / api.memory.get('settings.layout.library.aspectRatioWidth'))

        anchors.fill: parent
        anchors.topMargin: ((cellHeight - gameDelegateTitleMargin) * inverseSelectedScale) / 2.0 + borderWidth
        anchors.bottomMargin: anchors.topMargin

        anchors.leftMargin: (parent.width / numberOfColumns) * inverseSelectedScale / 2 + borderWidth
        anchors.rightMargin: anchors.leftMargin

        focus: parent.focus

        DelegateBorder {
            parent: grid.contentItem
            currentItem: grid.currentItem

            visible: grid.focus
        }

        cellWidth: width / numberOfColumns
        cellHeight: cellWidth * aspectRatio + gameDelegateTitleMargin

        cacheBuffer: grid.height

        preferredHighlightBegin: 0
        preferredHighlightEnd: grid.height - cellHeight

        highlightRangeMode: GridView.ApplyRange

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 300

        keyNavigationWraps: false

        highlight: GameDelegateHighlight {
            item: grid.currentItem
            visible: grid.focus

            muted: false
        }

        delegate: GameDelegate {
            itemWidth: GridView.view.cellWidth
            itemHeight: GridView.view.cellHeight - gameDelegateTitleMargin

            game: modelData
            selected: GridView.isCurrentItem && grid.focus

            assetKey: settingsMetadata.layout['library.art'].values[api.memory.get('settings.layout.library.art')]
            logoVisible: api.memory.get('settings.layout.library.logoVisible')
            aspectRatioNative: api.memory.get('settings.layout.library.aspectRatioNative')
        }

        Component.onCompleted: {
            // grid.currentIndex = gridContainer.focus ? savedGameIndex : -1;
            grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
        }

        Keys.onUpPressed: { sfxNav.play(); event.accepted = false; }
        Keys.onDownPressed: { sfxNav.play(); event.accepted = false; }

        Keys.onLeftPressed: { 
            sfxNav.play();
            if ((grid.currentIndex % grid.numberOfColumns) === 0) {
                openCollectionsMenu();
                event.accepted = true;
            } else {
                event.accepted = false;
            }
        }
        Keys.onRightPressed: {
            sfxNav.play();
            if ((grid.currentIndex % grid.numberOfColumns) === (numberOfColumns - 1)) {
                openNavigationMenu();
                event.accepted = true;
            } else {
                event.accepted = false;
            }
        }
    }
}