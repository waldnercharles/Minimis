import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtQuick.Layouts 1.15

FocusScope {
    id: root

    property var media: []
    property int currentIndex: 0

    property string asset: media.length > root.currentIndex ? media[root.currentIndex] : ''
    property bool isVideo: asset.endsWith('.mp4') || asset.endsWith('.webm')

    opacity: root.focus ? 1 : 0
    Behavior on opacity { OpacityAnimator { duration: 300 } }

    signal closed

    function next() {
        sfxNav.play();
        root.currentIndex = (root.currentIndex + media.length + 1) % media.length;
    }

    function prev() {
        sfxNav.play();
        root.currentIndex = (root.currentIndex + media.length - 1) % media.length;
    }

    Rectangle {
        anchors.fill: root
        color: 'black'
    }

    VideoCrossfade {
        id: video

        anchors.fill: root
        source: root.focus && isVideo ? asset : ''
        fillMode: Image.PreserveAspectFit

        volume: root.focus ? 1 : 0
    }

    ImageCrossfade {
        id: image

        anchors.fill: root
        source: isVideo ? '' : asset
        fillMode: Image.PreserveAspectFit
        crossfadeDuration: root.focus ? 300 : 0
        crossfadePauseDuration: 100
    }

    Keys.onLeftPressed: { prev(); }
    Keys.onRightPressed: { next(); }

    Keys.onPressed: {
        if (api.keys.isCancel(event) && !event.isAutoRepeat) {
            event.accepted = true;
            closed();
            sfxAccept.play();
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors { bottom: parent.bottom; bottomMargin: vpx(20) }
        spacing: vpx(10)
        Repeater {
            model: media.length
            Circle {
                color: root.currentIndex == index ? api.memory.get('settings.globalTheme.accentColor') : api.memory.get('settings.globalTheme.textColor')
                opacity: root.currentIndex == index ? 1 : 0.5
                radius: vpx(5)
            }
        }
    }
}