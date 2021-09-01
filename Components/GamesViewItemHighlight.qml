import QtQuick 2.6
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property bool playPreview: false
    property bool muted: false

    onPlayPreviewChanged: {
        if (playPreview) {
            if (game && game.assets.videoList.length > 0) {
                for (var i = 0; i < game.assets.videoList.length; i++) {
                    videoPreview.playlist.addItem(game.assets.videoList[i]);
                }
            }

            videoPreview.play();
            videoPreview.state = 'playing'
        } else {
            videoPreview.pause();
            videoPreview.state = '';
            videoPreview.playlist.clear();
        }
    }

    GamesViewItemBorder { anchors.fill: parent }

    Rectangle {
        anchors.fill: parent
        color: 'black'
        Video {
            id: videoPreview
            anchors.fill: parent

            fillMode: VideoOutput.PreserveAspectCrop

            playlist: Playlist {
                playbackMode: Playlist.Loop
            }

            states: State {
                name: "playing"
                PropertyChanges { target: videoPreview; opacity: 1 }
            }
            transitions: Transition {
                from: ""; to: "playing"
                NumberAnimation { properties: 'opacity'; duration: 500 }
            }

            opacity: 0

            muted: root.muted
            volume: api.memory.get('settings.game.previewVolume')

            visible: videoPreview.playlist.itemCount > 0 && videoPreview.opacity > 0
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: videoPreview.width; height: videoPreview.height
                radius: vpx(api.memory.get('settings.game.cornerRadius'))
            }
        }
    }
}