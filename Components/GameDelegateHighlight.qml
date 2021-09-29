import QtQuick 2.6
import QtMultimedia 5.15
import QtGraphicalEffects 1.0

Item {
    id: root

    property var item
    property bool muted: false

    width: item ? item.width : undefined
    height: item ? item.height : undefined 

    scale: item ? item.scale : 0

    z: item ? item.z - 1 : -1

    visible: item

    Component {
        id: videoComponent

        Video {
            anchors.fill: parent
            source: root.item.game.assets.videoList[0]
            fillMode: VideoOutput.PreserveAspectCrop
            muted: root.muted
            loops: MediaPlayer.Infinite
            autoPlay: true
            volume: api.memory.get('settings.global.previewVolume')
        }
    }

    Rectangle {
        id: loaderContainer

        anchors.fill: parent
        color: 'black'

        Loader {
            id: loader

            anchors.fill: parent
            asynchronous: true

            sourceComponent: videoComponent

            active: !videoPreviewDebouncer.running && root.visible && root.item.game.assets.videoList.length > 0
        }

        visible: loader.active

        layer.enabled: true
        layer.effect: OpacityMask {
            id: mask
            maskSource: Rectangle {
                width: loaderContainer.width; height: loaderContainer.height
                radius: vpx(api.memory.get('settings.global.cornerRadius'))
            }
        }
    }
}