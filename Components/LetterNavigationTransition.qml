import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

Item {
    id: root
    anchors.fill: parent

    property alias text: letterText.text
    property alias icon: icon.text

    opacity: 0

    SequentialAnimation {
        id: fadeAnimation;
        PauseAnimation { duration: api.memory.get('settings.gameNavigation.pauseDuration') }
        NumberAnimation { target: root; property: 'opacity'; to: 0; duration: api.memory.get('settings.gameNavigation.fadeDuration'); }
        PropertyAction { target: root; property: 'text'; value: null }
    }

    Rectangle {
        id: letterTextBackground
        anchors.centerIn: overlay

        height: overlay.height * 1.2; width: Math.max(overlay.height, overlay.width) * 1.2
        radius: height / 4

        color: api.memory.get('settings.theme.backgroundColor')
        opacity: api.memory.get('settings.gameNavigation.opacity')
    }

    Row {
        id: overlay
        anchors.centerIn: parent

        height: letterText.height
        // width: parent.width

        spacing: vpx(api.memory.get('settings.gameNavigation.size')) / 8

        Text {
            id: icon
            anchors.verticalCenter: parent.verticalCenter

            antialiasing: true
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: fontawesome.name
            font.pixelSize: letterText.font.pixelSize * 0.9

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: api.memory.get('settings.theme.accentColor')
        }

        Text {
            id: letterText
            anchors.verticalCenter: parent.verticalCenter

            antialiasing: true
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: titleFont.name
            font.capitalization: Font.Capitalize
            font.pixelSize: vpx(api.memory.get('settings.gameNavigation.size'))
            font.bold: true

            minimumPointSize: vpx(24)
            fontSizeMode: Text.Fit

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: api.memory.get('settings.theme.accentColor')
        }

    }

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: vpx(0); verticalOffset: vpx(6)

            samples: 10
            color: '#99000000';
        }

    onTextChanged: {
        if (text) {
            fadeAnimation.stop();
            root.opacity = 1;
            fadeAnimation.restart();
        }
    }
}
