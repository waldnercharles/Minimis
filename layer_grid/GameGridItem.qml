// Pegasus Frontend
// Copyright (C) 2017-2018  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.8
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

Item {
    id: root

    property int cornerRadius: vpx(4)
    property int gridItemSpacing: vpx(7)

    property bool selected: false
    property var game

    property alias imageWidth: screenshot.paintedWidth
    property alias imageHeight: screenshot.paintedHeight

    signal clicked()
    signal doubleClicked()
    signal imageLoaded(int imgWidth, int imgHeight)

    scale: selected ? 1.14 : 1.0
    z: selected ? 3 : 1


    Behavior on scale { PropertyAnimation { duration: 100; } }

    onSelectedChanged: {
        screenshot.opacity = 1;
        videoPreviewLoader.playlist.clear();
        videoPreviewLoader.sourceComponent = undefined;
        screenshotFadeTimer.stop();
        videoTimer.restart();
    }

    Timer {
        id: videoTimer
        interval: 300
        onTriggered: {
            // screenshot.visible = true;
            if (selected && game && game.assets.videos.length > 0) {
                for (var i = 0; i < game.assets.videos.length; i++) {
                    videoPreviewLoader.playlist.addItem(game.assets.videos[i]);
                }

                videoPreviewLoader.sourceComponent = videoPreviewWrapper;
                screenshotFadeTimer.restart();
            }
        }
    }

    Timer {
        id: screenshotFadeTimer
        interval: 800
        onTriggered: {
            screenshot.opacity = 0;
        }
    }

    Rectangle {
        id: container

        anchors.fill: parent
        anchors.margins: gridItemSpacing

        radius: cornerRadius + vpx(3)
        color: selected ? "#ff9e12" : "transparent"

        Rectangle {
            id: borderAnimation
            width: parent.width
            height: parent.height
            visible: selected
            color: "white"

            radius: cornerRadius + vpx(3)

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
            anchors { fill: parent; margins: vpx(3) }
            color: "#1a1a1a"
            radius: cornerRadius

            z: 2
        }

        Image {
            id: screenshot
            anchors { fill: parent; margins: vpx(3) }

            asynchronous: true

            source: game.assets.screenshots[0] || ""
            visible: game.assets.screenshots[0]
            opacity: selected ? 1 : 0.5

            // sourceSize { width: 256; height: 256 }
            fillMode: Image.PreserveAspectCrop

            // onStatusChanged: if (status === Image.Ready) {
            //     imageHeightRatio = paintedHeight / paintedWidth;
            //     root.imageLoaded(paintedWidth, paintedHeight);
            // }
            Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.OutQuart; easing.amplitude: 2.0; } }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: screenshot.width
                    height: screenshot.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: screenshot.width
                        height: screenshot.height
                        radius: cornerRadius - vpx(1)
                    }
                }
            }
            z: 3
        }

        Component {
            id: videoPreviewWrapper

            Video {
                id: video
                playlist: videoPreviewLoader.playlist
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
                autoPlay: true

                volume: 0.3
            }
        }

        Loader {
            id: videoPreviewLoader
            anchors { fill: parent; margins: vpx(3) }

            property Playlist playlist: Playlist {
                playbackMode: Playlist.Loop
            }

            visible: selected && playlist.itemCount > 0

            asynchronous: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: videoPreviewLoader.width
                    height: videoPreviewLoader.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: videoPreviewLoader.width
                        height: videoPreviewLoader.height
                        radius: cornerRadius - vpx(1)
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
            visible: source || ""
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
