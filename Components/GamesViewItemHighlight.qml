import QtQuick 2.6
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property var game
    property bool muted: false

    onGameChanged: {
        videoPreview.state = "";
        videoPreview.stop();
        videoPreview.playlist.clear();

        if (settings.game.previewEnabled.value) {
            videoDelay.restart();
        }
    }

    Timer {
        id: videoDelay
        interval: 600
        onTriggered: {
            if (game && game.assets.videos.length > 0) {
                for (var i = 0; i < game.assets.videos.length; i++)
                    videoPreview.playlist.addItem(game.assets.videos[i]);

                videoPreview.play();
                videoPreview.state = "playing";
            }
        }
    }

    Rectangle {
        id: videoContainer
        anchors.fill: parent

        color: "black"
        visible: videoPreview.playlist.itemCount > 0 && videoPreview.opacity > 0

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

            volume: settings.game.previewVolume.value
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: videoPreview.width; height: videoPreview.height
                radius: vpx(settings.game.cornerRadius.value)
            }
        }
    }

    GamesViewItemBorder {
        id: border
        anchors.fill: videoContainer

        z: videoContainer.z - 1
    }
}