import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtQuick.Layouts 1.15

FocusScope {
    id: root

    anchors.fill: parent
    anchors.leftMargin: vpx(api.memory.get('settings.globalTheme.leftMargin'));
    anchors.rightMargin: vpx(api.memory.get('settings.globalTheme.rightMargin'));

    property var game
    property var gameMedia

    onGameChanged: {
        const media = [];

        if (game) {
            game.assets.videoList.forEach(v => media.push(v));
            game.assets.screenshotList.forEach(v => media.push(v));
            game.assets.backgroundList.forEach(v => media.push(v));
        }

        gameMedia = media;
    }

    ListView {
        id: listView

        focus: parent.focus

        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

        displayMarginBeginning: height
        displayMarginEnd: height

        preferredHighlightBegin: 0
        preferredHighlightEnd: height

        highlightMoveDuration: 300
        highlightRangeMode: ListView.ApplyRange

        height: vpx(220)
        spacing: vpx(20)

        model: ObjectModel {
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

            // FocusScope {
            //     id: mediaScope

            //     width: root.width; height: vpx(200)

            //     ListView {
            //         id: mediaListView

            //         focus: parent.focus

            //         width: root.width; height: vpx(200)
            //         orientation: ListView.Horizontal

            //         model: gameMedia

            //         highlightResizeDuration: 0
            //         highlightMoveDuration: 300
            //         highlightRangeMode: ListView.ApplyRange

            //         // highlight: GamesViewItemBorder {
            //         //     width: mediaListView.currentItem ? mediaListView.currentItem.width : undefined
            //         //     height: mediaListView.currentItem ? mediaListView.currentItem.height : undefined

            //         //     scale: mediaListView.currentItem ? mediaListView.currentItem.scale : 0

            //         //     z: mediaListView.currentItem ? mediaListView.currentItem.z - 1 : 0

            //         //     visible: mediaListView.currentItem != null && mediaScope.focus
            //         // }

            //         delegate: Item {
            //             id: item
            //             width: isVideo ? assetVideo.width : assetImage.width; height: vpx(150)

            //             property string asset: modelData
            //             property bool isVideo: asset.endsWith('.mp4') || asset.endsWith('.webm')

            //             property bool selected: mediaScope.focus && ListView.isCurrentItem

            //             Rectangle {
            //                 anchors.fill: item
            //                 color: 'black'
            //             }

            //             Image {
            //                 id: assetImage
            //                 height: item.height

            //                 source: !isVideo ? asset : ''
            //                 asynchronous: true

            //                 fillMode: Image.PreserveAspectFit
            //                 visible: !isVideo
            //                 opacity: selected ? 1.0 : 0.6
            //             }

            //             Video {
            //                 id: assetVideo
            //                 source: isVideo ? asset : ''

            //                 width: metaData.resolution ? metaData.resolution.width / metaData.resolution.height * height : 0
            //                 height: item.height

            //                 loops: MediaPlayer.Infinite

            //                 visible: isVideo
            //                 muted: true

            //                 autoPlay: true

            //                 opacity: selected ? 1.0 : 0.6
            //             }

            //             Text {
            //                 id: icon
            //                 height: item.height * 0.25; width: height
            //                 anchors.centerIn: parent

            //                 text: isVideo ? '\uf04b' : ''

            //                 font.family: fontawesome.name
            //                 font.pixelSize: height

            //                 color: api.memory.get('settings.globalTheme.textColor')

            //                 horizontalAlignment: Text.AlignHCenter
            //                 verticalAlignment: Text.AlignVCenter
            //             }

            //             layer.enabled: true
            //             layer.effect: OpacityMask {
            //                 id: mask
            //                 maskSource: Rectangle {
            //                     width: item.width; height: item.height
            //                     radius: vpx(api.memory.get('settings.cardTheme.cornerRadius'))
            //                 }

            //                 layer.enabled: !selected && api.memory.get('settings.performance.artDropShadow')
            //                 layer.effect: DropShadowLow {
            //                     anchors.fill: item
            //                     source: mask
            //                 }
            //             }
            //         }
            //     }
            // }
        }
    }
}