import QtQuick 2.15
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    signal openCollectionsMenu

    property alias model: grid.model

    readonly property var currentGame: grid.currentItem ? grid.currentItem.game : undefined
    property alias currentIndex: grid.currentIndex

    clip: true

    FakeAsset { id: fakeAsset; collection: currentCollection }

    GridView {
        id: grid

        readonly property int numberOfColumns: Math.max(api.memory.get('settings.library.columns'), 1)
        readonly property real inverseSelectedScale: Math.max(api.memory.get('settings.cardTheme.scaleSelected') - 1.0, 0)
        readonly property real borderWidth: (api.memory.get('settings.cardTheme.borderEnabled') ? vpx(api.memory.get('settings.cardTheme.borderWidth')) : 0);

        property real aspectRatio: api.memory.get('settings.library.aspectRatioNative') ? fakeAsset.height / fakeAsset.width : (api.memory.get('settings.library.aspectRatioHeight') / api.memory.get('settings.library.aspectRatioWidth'))

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: navigationBar.left

        anchors.topMargin: ((cellHeight - gameDelegateTitleMargin) * inverseSelectedScale) / 2.0 + borderWidth
        anchors.bottomMargin: anchors.topMargin

        anchors.leftMargin: (parent.width / numberOfColumns) * inverseSelectedScale / 2.0 + borderWidth
        anchors.rightMargin: anchors.leftMargin + (navigationBar.width / 2.0)

        focus: parent.focus && !navigationBar.focus

        DelegateBorder {
            parent: grid.contentItem
            currentItem: grid.currentItem

            visible: grid.focus || navigationBar.focus
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
            visible: grid.focus || navigationBar.focus

            muted: false
        }

        delegate: GameDelegate {
            itemWidth: GridView.view.cellWidth
            itemHeight: GridView.view.cellHeight - gameDelegateTitleMargin

            game: modelData
            selected: GridView.isCurrentItem && (grid.focus || navigationBar.focus)

            assetKey: settingsMetadata.library.art.values[api.memory.get('settings.library.art')]
            logoVisible: api.memory.get('settings.library.logoVisible')
            aspectRatioNative: api.memory.get('settings.library.aspectRatioNative')
        }

        Component.onCompleted: {
            grid.positionViewAtIndex(grid.currentIndex, GridView.Center);
        }

        onCountChanged: {
            Qt.callLater(navigationBar.updateNavigation);
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
            if (((grid.currentIndex % grid.numberOfColumns) === (numberOfColumns - 1)) || (grid.currentIndex === grid.count - 1)) {
                navigationBar.focus = true;
                event.accepted = true;
            } else {
                event.accepted = false;
            }
        }
    }

    NavigationBar {
        id: navigationBar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        anchors.bottomMargin: vpx(16)

        width: vpx(32) * uiScale
        active: focus
        selectedItem: currentGame
        games: model
        onIndexChanged: {
            if (index != null) {
                grid.currentIndex = index
            }
        }

        Keys.onLeftPressed: {
            sfxNav.play();
            navigationBar.focus = false;
            event.accepted = true;
        }
    }
}