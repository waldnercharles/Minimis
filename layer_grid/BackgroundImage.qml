import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property var game
    property string defaultBg: '../assets/defaultbg.jpg'
    property string bgSource: game ? game.assets.background || game.assets.screenshots[0] || defaultBg : defaultBg

    property bool toggle: false;
    property string image1Source
    property string image2Source

    onBgSourceChanged: {
        if (toggle) {
            image2Source = bgSource;
            image2.opacity = 1;
            image1.opacity = 0;
        } else {
            image1Source = bgSource;
            image2.opacity = 0;
            image1.opacity = 1;
        }
        toggle = !toggle;
    }

    Image {
        id: image1
        anchors.fill: parent

        asynchronous: true
        opacity: 1

        source: image1Source
        visible: source
        sourceSize { width: 1920; height: 1080 }
        fillMode: Image.PreserveAspectCrop
        smooth: false

        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    Image {
        id: image2
        anchors.fill: parent

        asynchronous: true
        opacity: 0

        source: image2Source
        visible: source
        sourceSize { width: 1920; height: 1080 }
        fillMode: Image.PreserveAspectCrop
        smooth: false

        Behavior on opacity { NumberAnimation { duration: 500 } }
    }

    Image {
        id: grill
        anchors.fill: parent

        asynchronous: true
        opacity: 0.2

        source: '../assets/grill.png'
        visible: source
        sourceSize { width: 1920; height: 1080 }
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    LinearGradient {
        width: parent.width
        height: parent.height
        start: Qt.point(0, 0)
        end: Qt.point(0, height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0015181e" }
            GradientStop { position: 1.0; color: "#ff15181e" }
        }
    }

    Rectangle {
        id: backgrounddim
        anchors.fill: parent
        // color: "#151719"
        color: "#15181e"

        opacity: 0.8

        Behavior on opacity { NumberAnimation { duration: 100 } }
    }
}
