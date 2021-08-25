import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10

FocusScope {
    id: root
    anchors.fill: parent

    Item {
        anchors.fill: parent

        Image {
            id: art
            anchors.fill: parent

            source: selectedGame.assets.screenshot || ''
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: false

            cache: false
        }

        Timer {
            id: videoDelay
            interval: 600
            onTriggered: {
                if (selectedGame && selectedGame.assets.videos.length > 0) {
                    for (var i = 0; i < selectedGame.assets.videos.length; i++)
                        videoPreview.playlist.addItem(selectedGame.assets.videos[i]);

                    videoPreview.play();
                    videoPreview.state = "playing";
                }
            }
        }

        Video {
            id: videoPreview
            anchors.fill: parent

            fillMode: VideoOutput.PreserveAspectCrop

            playlist: Playlist {
                playbackMode: Playlist.Loop
            }

            states: State {
                name: "playing"
                PropertyChanges { target: videoPreview; opacity: 1 }
            }
            transitions: Transition {
                from: ""; to: "playing"
                NumberAnimation { properties: 'opacity'; duration: 500 }
            }

            opacity: 0
            visible: videoPreview.playlist.itemCount > 0 && opacity > 0

            muted: true //root.muted 

            volume: api.memory.get('settings.game.previewVolume')
        }
    }

    LinearGradient {
        anchors.fill: parent
        start: Qt.point(0, 0); end: Qt.point(0, parent.height)
        gradient: Gradient {
            GradientStop { position: 0.0; color: 'transparent' }
            GradientStop { position: 1.0; color: api.memory.get('settings.theme.backgroundColor') }
        }
    }

    Image {
        id: logo

        anchors {
            bottom: metadata.top; left: metadata.left; bottomMargin: vpx(15)
        }

        width: parent.width / 3.0
        source: selectedGame.assets.logo || ''
        sourceSize: Qt.size(logo.width, 0)
        fillMode: Image.PreserveAspectFit

        asynchronous: true
        smooth: true

        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: logo
            horizontalOffset: vpx(0); verticalOffset: vpx(6)
            samples: 10
            color: '#75000000'
            source: logo
        }

        cache: false
    }

    LinearGradient {
        id: gradient
        anchors {
            left: parent.left;
            bottom: parent.bottom; top: logo.top;
        }

        start: Qt.point(0, height)
        end: Qt.point(0, 0)
        gradient: Gradient {
            GradientStop { position: 0.0; color: api.memory.get('settings.theme.backgroundColor') }
            GradientStop { position: 0.5; color: "transparent" }
        }
    }

    Item {
        id: metadata

        anchors {
            bottom: buttons.top; left: buttons.left; right: logo.right;
            bottomMargin: vpx(30); leftMargin: vpx(5)
        }

        height: vpx(50)

        property real fontSize: vpx(18)

        property string year: selectedGame.releaseYear != 0 ? selectedGame.releaseYear : '20XX'
        property real rating: parseFloat(selectedGame.rating * 5).toPrecision(2)
        property int players: selectedGame.players

        Row {
            spacing: vpx(20)
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: metadata.year
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: metadata.fontSize
                font.family: subtitleFont.name
                font.bold: true
                color: api.memory.get('settings.theme.textColor')

                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(4); height: width;
                radius: height / 2;
            }

            Rectangle {
                id: playersBackground
                anchors.verticalCenter: parent.verticalCenter

                width: playersText.contentWidth + vpx(40)
                height: playersText.contentHeight + vpx(10)

                border.width: vpx(2)
                border.color: api.memory.get('settings.theme.accentColor')

                radius: vpx(5)

                color: 'transparent'

                Text {
                    id: playersText
                    anchors.centerIn: parent

                    text: '1' + (metadata.players > 1 ? ' - ' + metadata.players + ' Players' : ' Player')

                    font.pixelSize: metadata.fontSize * 0.9
                    font.family: subtitleFont.name
                    color: api.memory.get('settings.theme.textColor')

                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(4); height: width;
                radius: height / 2;
            }

            Row {
                spacing: vpx(10)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: metadata.rating
                    anchors.verticalCenter: parent.verticalCenter

                    font.pixelSize: metadata.fontSize * 0.9
                    font.family: subtitleFont.name
                    color: api.memory.get('settings.theme.textColor')

                    verticalAlignment: Text.AlignVCenter
                }

                Row {
                    id: ratingStars

                    spacing: vpx(4)
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: 5
                        delegate: Image {

                            height: metadata.fontSize; width: height

                            source: '../assets/icons/star_' + (metadata.rating <= index ? 'empty' : metadata.rating <= index + 0.5 ? 'half' : 'full') + '.png'
                            sourceSize: Qt.size(width, height)
                            asynchronous: true
                            smooth: true

                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        anchors.fill: ratingStars
                        source: ratingStars
                        color: api.memory.get('settings.theme.textColor')
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: metadata
            horizontalOffset: vpx(0); verticalOffset: vpx(2)
            samples: 2
            color: '#99000000'
            source: metadata
        }
    }

    ListView {
        id: buttons

        focus: true

        anchors {
            left: parent.left; right: parent.right; bottom: parent.bottom
            leftMargin: vpx(50); topMargin: vpx(80); bottomMargin: vpx(80)
        }

        width: parent.width; height: vpx(40)
        orientation: ListView.Horizontal
        spacing: vpx(10)
        keyNavigationWraps: true

        Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }

        model: ObjectModel {
            Button {
                icon: '../assets/icons/play.svg'
                text: 'Play Game'
                height: parent.height
                selected: ListView.isCurrentItem
                onActivated: {
                    sfxAccept.play();
                    selectedGame.launch();
                }
            }
            Button {
                icon: '../assets/icons/info-circle.svg'
                text: 'More Info'
                height: parent.height
                selected: ListView.isCurrentItem
                onActivated: {
                    sfxAccept.play();
                }
            }
            Button {
                icon: selectedGame.favorite ? '../assets/icons/heart_filled.svg' : '../assets/icons/heart_empty.svg'
                height: parent.height
                selected: ListView.isCurrentItem
                circle: true
                onActivated: {
                    sfxAccept.play();
                    selectedGame.favorite = !selectedGame.favorite;
                }
            }

            Button {
                property var inMyList: (api.memory.get(`database.mylist.${currentCollection.shortName}.${selectedGame.title}`) ?? false)
                icon: inMyList ? '../assets/icons/check.svg' : '../assets/icons/plus.svg'
                height: parent.height
                text: selected ? (inMyList ? 'Remove from My List' : 'Add to My List') : ''
                selected: ListView.isCurrentItem
                circle: true
                onActivated: {
                    sfxAccept.play();
                    toggleMyList(currentCollection, selectedGame);
                }
            }
        }

        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: buttons
            horizontalOffset: vpx(0); verticalOffset: vpx(2)
            samples: 2
            color: '#77000000'
            source: buttons
        }
    }
}