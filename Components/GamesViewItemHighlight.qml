import QtQuick 2.6
import QtMultimedia 5.15
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property Item item

    property bool muted: false

    width: item ? item.width : undefined
    height: item ? item.height : undefined 

    x: item ? item.x : 0
    y: item ? item.y : 0
    z: item ? item.z - 1 : 0

    scale: item ? item.scale : 0

    visible: item

    GamesViewItemBorder { anchors.fill: parent }

    Rectangle {
        anchors.fill: parent
        color: 'black'

        VideoOutput {
            id: videoOutput
            anchors.fill: parent

            source: MediaPlayer {
                id: videoPlayer
                source: gameItemPlayVideoPreview && game && game.assets.videoList.length > 0 ? game.assets.videoList[0] || '' : ''
                muted: root.muted
                volume: api.memory.get('settings.global.previewVolume')
                autoPlay: true
                loops: MediaPlayer.Infinite
            }

            fillMode: VideoOutput.PreserveAspectCrop
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: videoOutput.width; height: videoOutput.height
                radius: vpx(api.memory.get('settings.global.cornerRadius'))
            }
        }
    }
}