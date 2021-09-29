import QtQuick 2.3
import QtGraphicalEffects 1.0

Row {
    id: root

    property var game

    property real fontSize: vpx(18)

    property string year: (game && game.releaseYear != 0) ? game.releaseYear : 'N/A'
    property real rating: game && game.rating != null ? parseFloat(game.rating * 5).toPrecision(2) : 0
    property int players: game ? game.players : 0

    spacing: vpx(20)

    Text {
        text: year
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: fontSize
        font.family: subtitleFont.name
        font.bold: true
        color: api.memory.get('settings.theme.textColor')

        verticalAlignment: Text.AlignVCenter
    }

    Circle { radius: 2; anchors.verticalCenter: parent.verticalCenter }

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

            text: '1' + (players > 1 ? ' - ' + players + ' Players' : ' Player')

            font.pixelSize: fontSize * 0.9
            font.family: subtitleFont.name
            color: api.memory.get('settings.theme.textColor')

            verticalAlignment: Text.AlignVCenter
        }
    }

    Circle { radius: 2; anchors.verticalCenter: parent.verticalCenter }

    Row {
        spacing: vpx(10)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: root.rating
            anchors.verticalCenter: parent.verticalCenter

            font.pixelSize: fontSize * 0.9
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
                    text: root.rating <= index ? '\uf006' : root.rating <= index + 0.5 ? '\uf123' : '\uf005'
                    anchors.verticalCenter: parent.verticalCenter;
                    font.family: fontawesome.name
                    font.pixelSize: fontSize
                    color: api.memory.get('settings.theme.textColor')

                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    layer.enabled: true
    layer.effect: DropShadowLow { }
}