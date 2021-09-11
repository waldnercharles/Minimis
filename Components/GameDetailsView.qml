import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0
import QtQml.Models 2.10

FocusScope {
    id: root

    anchors.fill: parent
    anchors.leftMargin: vpx(api.memory.get('settings.theme.leftMargin'));
    anchors.rightMargin: vpx(api.memory.get('settings.theme.rightMargin'));

    property var game
    property var gameMedia

    onGameChanged: {
        const media = [];

        if (game) {
            game.assets.videoList.forEach(v => media.push(v));
            game.assets.screenshotList.forEach(v => media.push(v));
            game.assets.backgroundList.forEach(v => media.push(v));
        }

        gameMedia = media;
    }

    ListView {
        anchors.fill: parent
        focus: true

        highlightMoveDuration: 200

        model: ObjectModel {
            FocusScope {
                id: metadataContainer
                width: root.width; height: root.height;

                focus: true

                Image {
                    id: background
                    anchors.fill: parent
                    anchors.leftMargin: -vpx(api.memory.get('settings.theme.leftMargin'));
                    anchors.rightMargin: -vpx(api.memory.get('settings.theme.rightMargin'));

                    source: game ? game.assets.screenshot || '' : ''
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: false

                    cache: false
                }

                LinearGradient {
                    anchors.fill: background

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
                    source: game ? game.assets.logo || '' : ''
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

                Item {
                    id: metadata

                    anchors {
                        bottom: buttons.top; left: buttons.left; right: parent.right;
                        bottomMargin: vpx(30); leftMargin: vpx(5)
                    }

                    height: vpx(50)

                    property real fontSize: vpx(18)

                    property string year: (game && game.releaseYear != 0) ? game.releaseYear : 'N/A'
                    property real rating: parseFloat(game.rating * 5).toPrecision(2)
                    property int players: game ? game.players : 0

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
                            color: api.memory.get('settings.theme.textColor')
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
                            color: api.memory.get('settings.theme.textColor')
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
                                anchors.verticalCenter: parent.verticalCenter;

                                spacing: vpx(4)
                                Repeater {
                                    model: 5
                                    delegate: Text {
                                        text: metadata.rating <= index ? '\uf006' : metadata.rating <= index + 0.5 ? '\uf123' : '\uf005'
                                        anchors.verticalCenter: parent.verticalCenter;
                                        font.family: fontawesome.name
                                        font.pixelSize: metadata.fontSize
                                        color: api.memory.get('settings.theme.textColor')

                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: vpx(0); verticalOffset: vpx(3)
                        samples: 4
                        color: '#99000000'
                    }
                }

                ListView {
                    id: buttons

                    focus: true

                    anchors {
                        left: parent.left; right: parent.right; bottom: parent.bottom
                        topMargin: vpx(80); bottomMargin: vpx(80)
                    }

                    width: parent.width; height: vpx(40)
                    orientation: ListView.Horizontal
                    spacing: vpx(10)
                    keyNavigationWraps: true

                    Keys.onLeftPressed: { sfxNav.play(); decrementCurrentIndex() }
                    Keys.onRightPressed: { sfxNav.play(); incrementCurrentIndex() }

                    model: ObjectModel {
                        Button {
                            icon: '\uf04b'
                            text: 'Play Game'
                            height: parent.height
                            selected: metadataContainer.ListView.isCurrentItem && ListView.isCurrentItem
                            onActivated: {
                                sfxAccept.play();
                                game.launch();
                            }
                        }
                        Button {
                            icon: '\uf05a'
                            text: 'More Info'
                            height: parent.height
                            selected: metadataContainer.ListView.isCurrentItem && ListView.isCurrentItem
                            onActivated: {
                                sfxAccept.play();
                            }
                        }
                        Button {
                            icon: (game && game.favorite) ? '\uf004' : '\uf08a'
                            height: parent.height
                            selected: metadataContainer.ListView.isCurrentItem && ListView.isCurrentItem
                            circle: true
                            onActivated: {
                                sfxAccept.play();
                                game.favorite = !game.favorite;
                            }
                        }

                        Button {
                            property bool isBookmarked: game && (api.memory.get(`database.bookmarks.${game.collections.get(0).shortName}.${game.title}`) ?? false)
                            icon: isBookmarked ? '\uf02e' : '\uf097'
                            height: parent.height
                            text: selected ? (isBookmarked ? 'Remove from Bookmarks' : 'Add to Bookmarks') : ''
                            selected: metadataContainer.ListView.isCurrentItem && ListView.isCurrentItem
                            circle: true
                            onActivated: {
                                sfxAccept.play();
                                toggleBookmarks(game);
                            }
                        }
                    }

                    layer.enabled: true
                    layer.effect: DropShadow {
                        anchors.fill: buttons
                        horizontalOffset: vpx(0); verticalOffset: vpx(3)
                        samples: 4
                        color: '#77000000'
                        source: buttons
                    }
                }
            }

            FocusScope {
                id: mediaScope

                width: root.width; height: vpx(200)

                ListView {
                    id: mediaListView

                    focus: true

                    width: root.width; height: vpx(200)
                    orientation: ListView.Horizontal

                    model: gameMedia

                    highlightResizeDuration: 0
                    highlightMoveDuration: 0
                    highlightRangeMode: ListView.ApplyRange

                    highlight: GamesViewItemBorder {
                        width: mediaListView.currentItem ? mediaListView.currentItem.width : undefined
                        height: mediaListView.currentItem ? mediaListView.currentItem.height : undefined

                        scale: mediaListView.currentItem ? mediaListView.currentItem.scale : undefined

                        z: mediaListView.currentItem ? mediaListView.currentItem.z - 1 : undefined

                        visible: mediaListView.currentItem != null && mediaScope.focus
                    }

                    delegate: Item {
                        id: item
                        width: isVideo ? assetVideo.width : assetImage.width; height: vpx(150)

                        property string asset: modelData
                        property bool isVideo: asset.endsWith('.mp4') || asset.endsWith('.webm')

                        property bool selected: mediaScope.focus && ListView.isCurrentItem

                        GamesViewItemBorder { anchors.fill: parent; visible: selected }

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

                            autoPlay: true

                            opacity: selected ? 1.0 : 0.6
                        }

                        Text {
                            id: icon
                            height: item.height * 0.25; width: height
                            anchors.centerIn: parent

                            text: isVideo ? '\uf04b' : ''

                            font.family: fontawesome.name
                            font.pixelSize: height

                            color: api.memory.get('settings.theme.textColor')

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            layer.enabled: true
                            layer.effect: DropShadow {
                                horizontalOffset: vpx(0); verticalOffset: vpx(3)

                                samples: 4
                                color: '#99000000';
                            }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            id: mask
                            maskSource: Rectangle {
                                width: item.width; height: item.height
                                radius: vpx(api.memory.get('settings.global.cornerRadius'))
                            }

                            layer.enabled: !selected && api.memory.get('settings.performance.artDropShadow')
                            layer.effect: DropShadow {
                                anchors.fill: item
                                horizontalOffset: vpx(0); verticalOffset: vpx(3)

                                samples: 4
                                color: '#99000000';
                                source: mask
                            }
                        }
                    }
                }
            }
        }
    }
}