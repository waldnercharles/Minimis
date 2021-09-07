import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

Item {
    id: root
    anchors.fill: parent

    property string text: ''
    property alias icon: icon.text

    opacity: 0

    SequentialAnimation {
        id: fadeAnimation;
        PauseAnimation { duration: api.memory.get('settings.global.navigationPauseDuration') }
        NumberAnimation { target: root; property: 'opacity'; to: 0; duration: api.memory.get('settings.global.navigationFadeDuration'); }
        PropertyAction { target: root; property: 'text'; value: null }
    }

    Rectangle {
        id: letterTextBackground
        anchors.centerIn: overlay

        height: letterText.contentHeight;
        width: Math.max(height, (letterText.contentWidth + icon.contentWidth) + height / 2)
        radius: height / 4

        color: api.memory.get('settings.theme.backgroundColor')
        opacity: api.memory.get('settings.global.navigationOpacity')
    }

    Item {
        id: overlay

        anchors.centerIn: parent
        height: letterText.font.pixelSize; width: parent.width

        Text {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: letterText.left

            antialiasing: true
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: fontawesome.name
            font.pixelSize: letterText.font.pixelSize * 0.85

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: api.memory.get('settings.theme.accentColor')
        }

        Text {
            id: letterText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: -(contentWidth / 2) + (icon.contentWidth / 2)

            text: `${icon.text ? ' ' : ''}${root.text}`

            width: parent.width / 1.2

            antialiasing: true
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.family: titleFont.name
            font.capitalization: Font.Capitalize
            font.pixelSize: vpx(api.memory.get('settings.global.navigationSize'))
            font.bold: true

            minimumPointSize: vpx(24)
            fontSizeMode: Text.Fit

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
