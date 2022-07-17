import QtQuick 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

ColumnLayout {
    id: root
    property var game

    property int bottomMargin: vpx(35) * uiScale

    readonly property real fontSize: vpx(18) * uiScale

    readonly property string year: game && game.releaseYear != 0 ? game.releaseYear : 'N/A'
    readonly property real rating: game && game.rating != null ? parseFloat(game.rating * 5).toPrecision(2) : 0
    readonly property int players: game ? game.players : 0

    Image {
        id: logo

        source: root.game ? root.game.assets.logo || '' : ''
        sourceSize: Qt.size(parent.width * 0.5, 0)

        Layout.fillHeight: true
        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

        Layout.topMargin: vpx(30) * uiScale

        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignBottom

        asynchronous: true
        smooth: true
        cache: false

        layer.enabled: true
        layer.effect: DropShadowHigh { }
    }

    Row {
        Layout.fillWidth: true
        Layout.leftMargin: vpx(10) * uiScale
        Layout.topMargin: vpx(20) * uiScale
        Layout.bottomMargin: root.bottomMargin

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