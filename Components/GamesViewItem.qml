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
            logo.opacity = 1;
        }
    }

    Behavior on scale { PropertyAnimation { duration: 100; } }

    scale: selected ? settings.game.scaleSelected.value : settings.game.scale.value
    z: selected ? 10 : 1

    Timer {
        id: fadescreenshot

        interval: 800
        onTriggered: {
            grayBackground.opacity = 0;
            screenshot.opacity = 0;

            if (settings.game.previewHideLogo.value) {
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

            visible: screenshot.status === Image.Null || screenshot.status === Image.Error || spinner.visible

            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Image {
            id: screenshot
            
            property var assetKey: settings.game.art.values[settings.game.art.value]

            anchors.fill: parent

            source: modelData.assets[assetKey] || ""
            sourceSize: Qt.size(screenshot.width, screenshot.height)

            asynchronous: true
            smooth: true

            fillMode: Image.PreserveAspectCrop

            visible: screenshot.status === Image.Ready && logo.status !== Image.Loading

            Behavior on opacity { NumberAnimation { duration: 200 } }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: screenshot.width; height: screenshot.height
                    radius: vpx(settings.game.cornerRadius.value)
                }
            }
        }

        Image {
            id: logo

            anchors.fill: parent
            scale: settings.game.logoScale.value

            source: modelData.assets.logo || ""
            sourceSize: Qt.size(logo.width, logo.height)

            asynchronous: true
            smooth: true

            fillMode: Image.PreserveAspectFit

            visible: logo.status === Image.Ready && screenshot.status !== Image.Loading && settings.game.logoVisible.value

            Behavior on opacity { NumberAnimation { duration: 200 } }
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
