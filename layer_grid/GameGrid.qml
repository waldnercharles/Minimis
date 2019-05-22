import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property bool memoryLoaded: false

    property string filterTitle: ""

    property var platform
    property alias gameIndex: grid.currentIndex
    readonly property bool gameIndexValid: 0 <= gameIndex && gameIndex < grid.count
    readonly property var currentGame: gameIndexValid ? platform.games.get(gameIndex) : null

    signal detailsRequested
    signal filtersRequested
    signal nextPlatformRequested
    signal prevPlatformRequested
    signal launchRequested

    onPlatformChanged: if (memoryLoaded && grid.count) gameIndex = 0;

    property var videoSource
    property var highlightVisible
    // property int videoVisible = 0

    onCurrentGameChanged: {
        videoSource = undefined;
        highlightVisible = false;
        videoDelay.restart();
        videoVisibleDelay.stop();
    }

    Timer {
        id: videoDelay
        interval: 200
        onTriggered: {
            if (currentGame.assets.videos.length > 0) {
                videoSource = currentGame.assets.videos[0];
            }
        }
    }

    Timer {
        id: videoVisibleDelay
        interval: 800
        onTriggered: {
            highlightVisible = true;
        }
    }

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevPlatformRequested();
            return;
        }
        if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextPlatformRequested();
            return;
        }
        if (api.keys.isDetails(event)) {
            event.accepted = true;
            detailsRequested();
            return;
        }
        if (api.keys.isFilters(event)) {
            event.accepted = true;
            filtersRequested();
            return;
        }
    }

    Component {
        id: highlight
        Item {
            id: highlightContainer
            z: grid.currentItem.z + 1
            scale: grid.currentItem.scale

            width: grid.currentItem.width
            height: grid.currentItem.height

            x: grid.currentItem.x
            y: grid.currentItem.y

            visible: highlightVisible

            Behavior on x { PropertyAnimation { duration: videoDelay.interval; easing.type: Easing.OutQuart; easing.amplitude: 2.0; } }
            Behavior on y { PropertyAnimation { duration: videoDelay.interval; easing.type: Easing.OutQuart; easing.amplitude: 2.0; } }

            // TODO: Move this into its own component
            Item {
                id: logo_container
                anchors.fill: parent

                anchors.centerIn: video
                Image {
                    id: logo
                    anchors { fill: parent; centerIn: parent; margins: vpx(30) }
                    asynchronous: true
                    source: currentGame.assets.logo || ""
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

                z: video.z + 1
            }

            Video {
                id: video
                anchors.fill: parent
                anchors.margins: grid.currentItem.gridItemSpacing + grid.currentItem.borderWidth;
                anchors.centerIn: parent

                // autoPlay: true

                volume: highlightVisible ? 0.3 : 0

                source: videoSource || ""
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite

                onStatusChanged: {
                    if (status == MediaPlayer.Loaded) {
                        video.play();
                        videoVisibleDelay.restart();
                    }
                }

                opacity: source && highlightVisible ? 1 : 0

                Behavior on opacity { PropertyAnimation { duration: videoDelay.interval * 4; easing.type: Easing.OutQuart; easing.amplitude: 2.0; } }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Item {
                        width: video.width
                        height: video.height
                        Rectangle {
                            anchors.centerIn: parent
                            width: video.width
                            height: video.height
                            radius: grid.currentItem.cornerRadius
                        }
                    }

                    layer.enabled: platform.shortName == "gb" ? true : false
                    layer.effect: ShaderEffect {
                        width: video.width; height: video.height
                        property variant src: video
                        fragmentShader: "
                            varying highp vec2 qt_TexCoord0;
                            uniform sampler2D src;
                            uniform lowp float qt_Opacity;

                            void main() {
                                lowp vec4 tex = texture2D(src, qt_TexCoord0);

                                vec3 min = vec3(0.06, 0.22, 0.06);
                                vec3 max = vec3(0.61, 0.74, 0.06);

                                vec3 color = vec3(dot(tex.rgb, vec3(0.2126, 0.7152, 0.0722))) * (max - min) + min;

                                gl_FragColor = vec4(color, tex.a)* qt_Opacity;
                            }"
                    }
                }
            }
        }
    }

    GridView {
        id: grid

        focus: true

        anchors {
            fill: parent;
            leftMargin: vpx(7);
            rightMargin: vpx(7);
        }

        model: platform.games

        property real cellHeightRatio: 0.46739130434782608695652173913043

        cellWidth: width / 3
        cellHeight: cellWidth * cellHeightRatio

        displayMarginBeginning: cellHeight * 2
        displayMarginEnd: cellHeight * 2

        anchors.topMargin: cellHeight * 0.14
        anchors.bottomMargin: cellHeight * 0.07

        highlight: highlight
        highlightFollowsCurrentItem: false

        delegate: GameGridItem {
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight
            selected: GridView.isCurrentItem
            highlightVisible: highlightVisible

            game: modelData

            onClicked: GridView.view.currentIndex = index
            onDoubleClicked: {
                GridView.view.currentIndex = index;
                root.detailsRequested();
            }
            Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    root.launchRequested();
                }
            }
        }
    }
}
