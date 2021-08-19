import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property bool selected: false

    onSelectedChanged: {
        const playPreview = modelData && modelData.assets.videoList.length > 0 && settings.game.previewEnabled.value;

        if (selected && playPreview)
            fadescreenshot.restart();
        else {
            fadescreenshot.stop();
            grayBackground.opacity = 1;
            screenshot.opacity = 1;
            if (settings.game.logoVisible.value) {
                logo.opacity = 1;
            } else {
                logo.opacity = 0;
            }
        }
    }

    Behavior on scale { NumberAnimation { duration: 100; } }

    scale: selected ? settings.game.scaleSelected.value : settings.game.scale.value
    z: selected ? 10 : 1

    Timer {
        id: fadescreenshot

        interval: 800
        onTriggered: {
            grayBackground.opacity = 0;
            screenshot.opacity = 0;

            if (settings.game.previewLogoVisible.value) {
                logo.opacity = 1;
            } else {
                logo.opacity = 0;
            }
        }
    }

    Item {
        id: card

        anchors.fill: parent;

        Rectangle {
            id: grayBackground

            anchors.fill: parent

            color: "#1a1a1a"
            radius: vpx(settings.game.cornerRadius.value)

            Behavior on opacity { NumberAnimation { duration: 200 } }

            visible: !screenshot.visible
        }

        Image {
            id: screenshot
            
            property var assetKey: settings.game.art.values[settings.game.art.value]

            anchors.fill: parent

            source: modelData.assets[assetKey] || ""
            sourceSize: Qt.size(screenshot.width, screenshot.height)

            asynchronous: true
            smooth: true

            fillMode: settings.game.aspectRatioNative.value ? Image.Stretch : Image.PreserveAspectCrop

            visible: screenshot.status === Image.Ready && logo.status !== Image.Loading

            Behavior on opacity { NumberAnimation { duration: 200 } }

            layer.enabled: true
            layer.effect: OpacityMask {
                id: mask
                maskSource: Rectangle {
                    width: screenshot.width; height: screenshot.height
                    radius: vpx(settings.game.cornerRadius.value)
                }

                layer.enabled: !selected
                layer.effect: DropShadow {
                    anchors.fill: screenshot
                    horizontalOffset: vpx(0); verticalOffset: vpx(4)

                    samples: 5
                    color: '#99000000';
                    source: mask
                }
            }
        }

        Image {
            id: logo
            anchors.fill: parent

            source: modelData.assets.logo || ""
            sourceSize: Qt.size(logo.width, logo.height)

            asynchronous: true
            smooth: true

            fillMode: Image.PreserveAspectFit

            scale: selected ? settings.game.logoScaleSelected.value : settings.game.logoScale.value
            visible: logo.status === Image.Ready && screenshot.status !== Image.Loading

            opacity: settings.game.logoVisible.value ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 100; } }

            layer.enabled: true
            layer.effect: DropShadow {
                anchors.fill: logo

                horizontalOffset: vpx(0); verticalOffset: vpx(6)

                samples: 10
                color: '#99000000'
                source: logo

            }
        }

        


        Text {
            id: textLogo

            anchors.fill: parent
            anchors.margins: vpx(10)

            text: modelData.title || ''
            color: "white"

            font.family: subtitleFont.name
            font.pixelSize: vpx(settings.game.logoFontSize.value)
            font.bold: true

            style: Text.Outline; styleColor: "black"

            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            lineHeight: 1.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: (logo.status === Image.Null || logo.status === Image.Error) && screenshot.status !== Image.Loading
        }

        Image {
            id: spinner

            anchors.centerIn: parent
            anchors.margins: vpx(30)

            source: "../assets/loading-spinner.png"
            sourceSize: Qt.size(spinner.width, spinner.height)

            asynchronous: false
            smooth: false

            RotationAnimator on rotation {
                loops: Animator.Infinite;
                from: 0; to: 360
                duration: 800
            }

            visible: screenshot.status === Image.Loading || logo.status === Image.Loading
        }
    }
}
