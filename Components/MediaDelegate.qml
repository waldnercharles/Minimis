import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtQuick.Layouts 1.15

Item {
    id: item

    property string asset
    property bool isVideo: asset.endsWith('.mp4') || asset.endsWith('.webm')

    property bool selected: mediaScope.focus && ListView.isCurrentItem

    width: isVideo ? assetVideo.width : assetImage.width

    scale: scaleEnabled ? (selected ? scaleSelected : scaleUnselected) : settingsMetadata.global.scale.defaultValue
    Behavior on scale { NumberAnimation { duration: animationArtScaleDuration; } enabled: animationEnabled }

    z: selected ? 255 : 1

    signal activated

    Rectangle {
        anchors.fill: item
        color: 'black'
    }

    Image {
        id: assetImage
        height: item.height

        source: !isVideo ? asset : ''
        asynchronous: true

        fillMode: Image.PreserveAspectFit
        visible: !isVideo
        opacity: selected ? 1.0 : 0.6
    }

    Video {
        id: assetVideo
        source: isVideo ? asset : ''

        width: metaData.resolution ? metaData.resolution.width / metaData.resolution.height * height : 0
        height: item.height

        loops: MediaPlayer.Infinite

        visible: isVideo
        muted: true

        autoLoad: true
        opacity: selected ? 1.0 : 0.6
        // flushMode: VideoOutput.FirstFrame

        onStatusChanged: {
            if (assetVideo.status == MediaPlayer.Loaded) {
                assetVideo.seek(2000);
                assetVideo.play();
                assetVideo.pause();
            }
        }
    }

    Text {
        id: icon
        height: item.height * 0.25; width: height
        anchors.centerIn: parent

        text: isVideo ? '\uf04b' : '\uf03e'

        font.family: fontawesome.name
        font.pixelSize: height

        color: api.memory.get('settings.globalTheme.textColor')

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        layer.enabled: true
        layer.effect: DropShadowLow { cached: true }
    }

    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            activated();
            sfxAccept.play();
        }
    }

    layer.enabled: isVideo ? api.memory.get('settings.cardTheme.videoPreviewMaskEnabled') : true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: item.width; height: item.height
            radius: vpx(api.memory.get('settings.cardTheme.cornerRadius'))
        }
    }
}