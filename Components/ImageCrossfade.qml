import QtQuick 2.4
 
Item {
    id: root

    property string source: ''

    property int crossfadeDuration: 600
    property int crossfadePauseDuration: 200

    readonly property real progress: Math.max(img1.opacity, img2.opacity)

    onSourceChanged: {
        state = state === 'img1' ? 'img2' : 'img1';
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
 
    Image {
        id: img1
        anchors.fill: parent

        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        smooth: false
        cache: false
    }
 
    Image {
        id: img2
        anchors.fill: parent

        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        smooth: false
        cache: false
    }
 
    state: "img1"
}