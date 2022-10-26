import QtQuick 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import "qrc:/qmlutils" as PegasusUtils

ColumnLayout {
    id: root
    property var game

    property bool showDetails: false

    property int bottomMargin: vpx(35) * uiScale

    readonly property real fontSize: vpx(18) * uiScale

    readonly property string year: game && game.releaseYear != 0 ? game.releaseYear : 'N/A'
    readonly property real rating: game && game.rating != null ? parseFloat(game.rating * 5).toPrecision(2) : 0
    readonly property int players: game ? game.players : 0

    onGameChanged: {
        description.animate = false;
        showDetails = false;
        description.animate = true;
    }

    Item {
        Layout.preferredWidth: parent.width
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

        Layout.topMargin: vpx(30) * uiScale
        Layout.bottomMargin: metadata.height * 0.5

        Item {
            anchors.fill: parent

            Image {
                id: logo

                source: root.game ? root.game.assets.logo || '' : ''
                sourceSize: Qt.size(width, height)
                anchors.fill: parent

                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignLeft
                verticalAlignment: Image.AlignBottom

                asynchronous: true
                smooth: true
                cache: false

                layer.enabled: true
                layer.effect: DropShadowHigh { }
            }

            opacity: showDetails ? 0 : 1
            Behavior on opacity { OpacityAnimator { duration: 200 } }
        }

        ColumnLayout {
            anchors.fill: parent

            Text {
                id: logoText

                text: root.game ? root.game.title : ''
                color: api.memory.get('settings.general.textColor')

                font.family: titleFont.name
                font.pixelSize: vpx(44)
                font.bold: true

                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom

                elide: Text.ElideRight

                Layout.topMargin: vpx(16)
                Layout.fillWidth: true
            }

            PegasusUtils.AutoScroll
            {
                id: description

                property bool animate: true

                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

                scrollWaitDuration: 5000
                pixelsPerSecond: 4

                Text {
                    anchors.left: parent.left; anchors.right: parent.right

                    text: root.game && (root.game.summary || root.game.description) ? root.game.summary || root.game.description : "No description available"
                    color: api.memory.get('settings.general.textColor')

                    font.pixelSize: vpx(16)
                    font.family: bodyFont.name
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                }
            }

            opacity: (logo.status != Image.Ready && logo.status != Image.Loading) || showDetails ? 1 : 0
            Behavior on opacity {
                SequentialAnimation {
                    NumberAnimation { duration: 200 }
                    ScriptAction { script: { description.restartScroll(); description.contentY = description.originY; } }
                }

                enabled: description.animate
            }
        }
    }

    Row {
        id: metadata

        Layout.fillWidth: true
        Layout.leftMargin: vpx(10) * uiScale
        Layout.bottomMargin: height * 0.5

        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

        spacing: vpx(20)

        Text {
            text: year
            anchors.verticalCenter: parent.verticalCenter

            font.pixelSize: fontSize
            font.family: subtitleFont.name
            font.bold: true
            color: api.memory.get('settings.general.textColor')

            verticalAlignment: Text.AlignVCenter
        }

        Circle { radius: vpx(2); anchors.verticalCenter: parent.verticalCenter }

        Rectangle {
            id: playersBackground
            anchors.verticalCenter: parent.verticalCenter

            width: playersText.contentWidth + vpx(40) * uiScale
            height: playersText.contentHeight + vpx(10) * uiScale

            border.width: vpx(2)
            border.color: api.memory.get('settings.general.accentColor')

            radius: vpx(5)

            color: 'transparent'

            Text {
                id: playersText
                anchors.centerIn: parent

                text: '1' + (players > 1 ? ' - ' + players + ' Players' : ' Player')

                font.pixelSize: fontSize * 0.9
                font.family: subtitleFont.name
                color: api.memory.get('settings.general.textColor')

                verticalAlignment: Text.AlignVCenter
            }
        }

        Circle { radius: vpx(2); anchors.verticalCenter: parent.verticalCenter }

        Row {
            spacing: vpx(10) * uiScale
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root.rating
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: fontSize * 0.9
                font.family: subtitleFont.name
                color: api.memory.get('settings.general.textColor')

                verticalAlignment: Text.AlignVCenter
            }

            Row {
                id: ratingStars
                anchors.verticalCenter: parent.verticalCenter;

                spacing: vpx(4) * uiScale
                Repeater {
                    model: 5
                    delegate: Text {
                        text: root.rating <= index ? '\uf006' : root.rating <= index + 0.5 ? '\uf123' : '\uf005'
                        anchors.verticalCenter: parent.verticalCenter;
                        font.family: fontawesome.name
                        font.pixelSize: fontSize
                        color: api.memory.get('settings.general.textColor')

                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: DropShadowLow { }
    }
}