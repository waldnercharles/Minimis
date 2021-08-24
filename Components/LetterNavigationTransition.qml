import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

Item {
    id: root
    anchors.fill: parent

    property string currentLetter

    opacity: 0

    SequentialAnimation {
        id: fadeAnimation;
        PauseAnimation { duration: api.memory.get('settings.game.letterNavPauseDuration') }
        OpacityAnimator { target: root; from: 1; to: 0; duration: api.memory.get('settings.game.letterNavFadeDuration'); }
    }

    Rectangle {
        id: letterTextBackground
        anchors.centerIn: letterText

        height: letterText.height * 1.2; width: height
        radius: height / 4

        color: api.memory.get('settings.theme.backgroundColor')
        opacity: api.memory.get('settings.game.letterNavOpacity')
    }

    Text {
        id: letterText
        anchors.centerIn: parent

        text: currentLetter

        antialiasing: true
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferNoHinting
        font.family: titleFont.name
        font.capitalization: Font.AllUppercase
        font.pixelSize: vpx(api.memory.get('settings.game.letterNavSize'))
        font.bold: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: api.memory.get('settings.theme.accentColor')

        layer.enabled: true
        layer.effect: DropShadow {
            anchors.fill: letterText 
            horizontalOffset: vpx(0); verticalOffset: vpx(6)

            samples: 10
            color: '#99000000';
            source: letterText
        }    
    }

    onCurrentLetterChanged: {
        fadeAnimation.stop();
        root.opacity = 1;
        fadeAnimation.restart();
    }
}
