import QtQuick 2.4
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtQuick.Layouts 1.15
 
Item {
    id: root

    property string source: ''

    property int crossfadeDuration: 600
    property int crossfadePauseDuration: 200

    property var fillMode: VideoOutput.PreserveAspectCrop
    property real volume: 1.0

    readonly property real progress: Math.max(img1.opacity, img2.opacity)

    function restart() {
        img1.seek(0)
        img2.seek(0)
    }

    onSourceChanged: {
        state = state === 'img1' ? 'img2' : 'img1';
        restart()
    }

    states: [
        State {
            name: "img1"
            PropertyChanges { target: img1; source: root.source; explicit: true; restoreEntryValues: false }
        },
        State {
            name: "img2"
            PropertyChanges { target: img2; source: root.source; explicit: true; restoreEntryValues: false }
        }
    ]
 
    transitions: [
        Transition {
            to: 'img1'
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: img1; property: 'opacity'; to: 0; duration: img1.opacity * crossfadeDuration * 0.5 }
                    NumberAnimation { target: img2; property: 'opacity'; to: 0; duration: img2.opacity * crossfadeDuration * 0.5 }
                }
                PropertyAction { target: img1; property: 'source'; }
                PauseAnimation { duration: crossfadePauseDuration }
                NumberAnimation { target: img1; property: 'opacity'; to: 1; easing.type: Easing.InOutQuad; duration: crossfadeDuration * 0.5 }
            }
        },
        Transition {
            to: 'img2'
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: img1; property: 'opacity'; to: 0; duration: img1.opacity * crossfadeDuration * 0.5 }
                    NumberAnimation { target: img2; property: 'opacity'; to: 0; duration: img2.opacity * crossfadeDuration * 0.5 }
                }
                PropertyAction { target: img2; property: 'source' }
                PauseAnimation { duration: crossfadePauseDuration }
                NumberAnimation { target: img2; property: 'opacity'; to: 1; easing.type: Easing.InOutQuad; duration: crossfadeDuration * 0.5 }
            }
        }
    ]
 
    Video {
        id: img1
        anchors.fill: parent

        fillMode: root.fillMode
        autoPlay: true
        loops: MediaPlayer.Infinite

        volume: img1.opacity * root.volume
    }
 
    Video {
        id: img2
        anchors.fill: parent

        fillMode: root.fillMode
        autoPlay: true
        loops: MediaPlayer.Infinite

        volume: img2.opacity * root.volume
    }
 
    state: "img1"
}