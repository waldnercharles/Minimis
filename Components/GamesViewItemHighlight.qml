import QtQuick 2.6
import QtMultimedia 5.15
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property bool playPreview: false
    property bool muted: false

    onPlayPreviewChanged: {
        if (playPreview) {
            videoPlayer.play();
        } else {
            videoPlayer.pause();
        }
    }

    GamesViewItemBorder { anchors.fill: parent }

    Rectangle {
        anchors.fill: parent
        color: 'black'

        VideoOutput {
            id: videoOutput
            anchors.fill: parent

            source: MediaPlayer {
                id: videoPlayer
                source: game && game.assets.videoList.length > 0 ? game.assets.videoList[0] || '' : ''
                muted: root.muted
                volume: api.memory.get('settings.game.previewVolume')
                autoLoad: true
                autoPlay: playPreview
                loops: MediaPlayer.Infinite
            }

            fillMode: VideoOutput.PreserveAspectCrop
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: videoOutput.width; height: videoOutput.height
                radius: vpx(api.memory.get('settings.game.cornerRadius'))
            }
        }
    }
}