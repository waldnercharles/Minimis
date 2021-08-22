import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

import "../utils.js" as Utils

Rectangle {
    id: root

    property var pendingCollection

    color: settings.theme.backgroundColor.value
    opacity: 0

    SequentialAnimation {
        id: fadeAnimation;
        OpacityAnimator { target: root; from: 1; to: 0; duration: 500; }
    }

    Timer {
        id: debounceTimer

        interval: 500
        repeat: false
        running: false
        onTriggered: () => { 
            fadeAnimation.restart();
            currentCollection = pendingCollection;
        }
    }

    Item {
        id: logoContainer
        anchors.fill: parent

        Image {
            id: logo

            anchors.centerIn: parent
            width: root.width / 2.0
            fillMode: Image.PreserveAspectFit

            source: pendingCollection ? "../assets/logos/" + Utils.getPlatformName(pendingCollection.shortName) + ".svg" : ""
            sourceSize: Qt.size(root.width / 2.0, 0)

            asynchronous: false
            smooth: true

            layer.enabled: true
            layer.effect: ColorOverlay {
                id: colorMask
                anchors.fill: logo
                source: logo
                color: settings.theme.accentColor.value
            }
        }

        Text {
            id: logoFallback

            anchors.centerIn: parent

            text: pendingCollection ? pendingCollection.name : ''

            font.family: titleFont.name
            font.pixelSize: vpx(128)
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: settings.theme.accentColor.value

            visible: logo.status == Image.Null || logo.status == Image.Error
        }

        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: logoContainer 
            horizontalOffset: vpx(0); verticalOffset: vpx(6)

            samples: 10
            color: '#99000000';
            source: logoContainer
        }
    }

    onPendingCollectionChanged: {
        if (pendingCollection != currentCollection) {
            debounceTimer.stop();
            fadeAnimation.stop();

            root.opacity = 1;

            debounceTimer.restart();
        }
    }
}
