import QtQuick 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

ColumnLayout {
    id: root
    property var game

    property int bottomMargin: vpx(35)

    Image {
        id: logo

        source: root.game ? root.game.assets.logo || '' : ''
        sourceSize: Qt.size(parent.width * 0.5, 0)

        Layout.fillHeight: true
        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

        Layout.topMargin: vpx(30)

        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignLeft
        verticalAlignment: Image.AlignBottom

        asynchronous: true
        smooth: true
        cache: false

        layer.enabled: true
        layer.effect: DropShadowHigh { }
    }

    GameDetailsMetadata {
        game: root.game

        Layout.fillWidth: true
        Layout.leftMargin: vpx(10)
        Layout.topMargin: vpx(20)
        Layout.bottomMargin: root.bottomMargin

        Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
    }

    // Text {
    //     id: title

    //     text: game ? game.title : ''
    //     anchors {
    //         top: parent.top; left: parent.left;
    //     }
    //     anchors.topMargin: font.pixelSize / 2

    //     width: parent.width * 0.75

    //     antialiasing: true
    //     renderType: Text.NativeRendering
    //     font.hintingPreference: Font.PreferNoHinting
    //     font.pixelSize: parent.height / 5
    //     font.family: homeFont.name
    //     font.capitalization: Font.AllUppercase 
    //     color: api.memory.get('settings.theme.textColor')

    //     fontSizeMode: Text.Fit
    //     verticalAlignment: Text.AlignVCenter

    //     layer.enabled: true
    //     layer.effect: DropShadow {
    //         horizontalOffset: vpx(0); verticalOffset: vpx(2)
    //         samples: 3
    //         color: '#ff000000';
    //     }
    // }

    // Text {
    //     id: description

    //     text: game ? game.description : ''
    //     anchors {
    //         top: title.bottom; left: parent.left; bottom: parent.bottom
    //     }
    //     anchors.topMargin: font.pixelSize / 2
    //     anchors.bottomMargin: font.pixelSize / 2

    //     width: parent.width * 0.75

    //     antialiasing: true
    //     renderType: Text.NativeRendering
    //     font.hintingPreference: Font.PreferNoHinting
    //     font.pixelSize: parent.height / 20
    //     font.family: bodyFont.name
    //     color: api.memory.get('settings.theme.textColor')

    //     elide: Text.ElideRight

    //     lineHeight: 1.15
    //     wrapMode: Text.WordWrap

    //     layer.enabled: true
    //     layer.effect: DropShadow {
    //         horizontalOffset: vpx(0); verticalOffset: vpx(2)
    //         samples: 3
    //         color: '#ff000000';
    //     }
    // }
}