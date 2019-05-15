import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property int cornerRadius: vpx(4)
    property int gridItemSpacing: vpx(7)
    property int borderWidth: vpx(3)

    property bool selected: false
    property bool highlightVisible: false

    property var game

    signal clicked()
    signal doubleClicked()
    signal imageLoaded(int imgWidth, int imgHeight)

    scale: selected ? 1.14 : 1.0
    z: selected ? 3 : 1

    Behavior on scale { PropertyAnimation { duration: 100; } }

    Rectangle {
        id: container

        anchors.fill: parent
        anchors.margins: gridItemSpacing

        radius: cornerRadius + borderWidth
        color: selected ? "#ff9e12" : "transparent"

        Rectangle {
            id: borderAnimation
            width: parent.width
            height: parent.height
            visible: selected
            color: "white"

            radius: cornerRadius + borderWidth

            SequentialAnimation on opacity {
                id: opacityAnimation
                loops: Animation.Infinite
                NumberAnimation { to: 1; duration: 500; }
                NumberAnimation { to: 0; duration: 500; }
                PauseAnimation { duration: 200 }
            }
        }

        Rectangle {
            id: grayBackground
            anchors { fill: parent; margins: borderWidth }
            color: "#1a1a1a"
            radius: cornerRadius

            z: 2
        }

        Image {
            id: screenshot
            anchors { fill: parent; margins: borderWidth }

            asynchronous: true

            source: game.assets.screenshots[0] || ""
            visible: game.assets.screenshots[0]
            opacity: selected ? 1 : 0.5

            fillMode: Image.PreserveAspectCrop

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: screenshot.width
                    height: screenshot.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: screenshot.width
                        height: screenshot.height
                        radius: cornerRadius
                    }
                }
            }
            z: 2
        }
    }

    Item {
        id: logo_container
        anchors.fill: parent
        anchors.centerIn: parent
        Image {
            id: logo
            anchors { fill: parent; centerIn: parent; margins: vpx(30) }
            asynchronous: true
            source: game.assets.logo || ""
            visible: false
            fillMode: Image.PreserveAspectFit
        }

        Glow {
            source: logo
            anchors.fill: source
            radius: vpx(2)
            spread: 0.8
            color: "#bbffffff"
        }
        visible: false
    }

    DropShadow {
        id: logo_shadow
        source: logo_container
        anchors.fill: source
        color: "black"
        radius: vpx(3)
        spread: 0.3
        smooth: true
        visible: !selected || !highlightVisible
        z: 5
    }

    Image {
        anchors.centerIn: parent

        visible: screenshot.status === Image.Loading
        source: "../assets/loading-spinner.png"

        RotationAnimator on rotation {
            loops: Animator.Infinite;
            from: 0;
            to: 360;
            duration: 500
        }
    }

    Text {
        width: parent.width - vpx(64)
        anchors.centerIn: parent

        visible: !game.assets.screenshots[0]

        text: game.title
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        color: "#eee"
        font {
            pixelSize: vpx(16)
            family: globalFonts.sans
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        onDoubleClicked: root.doubleClicked()
    }
}
