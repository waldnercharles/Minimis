import QtQuick 2.15
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property bool selected: false
    property bool circle: false

    property alias text: label.text
    property alias icon: icon.text

    signal activated

    width: buttonBackground.width

    onSelectedChanged: { if (selected) { sfxNav.play(); } }

    Rectangle {
        id: buttonBackground

        anchors.fill: button

        radius: circle ? height / 2 : vpx(5)
        color: selected ? api.memory.get('settings.theme.accentColor') : api.memory.get('settings.theme.textColor')

        opacity: selected ? 1 : 0.4

        layer.enabled: true
        layer.effect: DropShadowLow { }
    }

    Row {
        id: button
        height: root.height;
        anchors.verticalCenter: parent.verticalCenter

        property var padding: (height - icon.height) * ((circle && text == '') ? 0.5 : 0.8)
        spacing: padding * 0.5

        leftPadding: padding
        rightPadding: padding

        Behavior on leftPadding { NumberAnimation { duration: 200 } }
        Behavior on rightPadding { NumberAnimation { duration: 200 } }

        Text {
            id: icon
            height: button.height * 0.45; width: icon.visible ? height : vpx(0);
            anchors.verticalCenter: parent.verticalCenter

            font.family: fontawesome.name
            font.pixelSize: height

            color: selected ? api.memory.get('settings.theme.backgroundColor') : api.memory.get('settings.theme.textColor')

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            visible: !!text
        }

        TextMetrics {
            id: labelFake

            font.family: subtitleFont.name
            font.pixelSize: button.height * 0.4
            font.bold: true

            text: label.text
        }

        Text {
            id: label

            font.family: subtitleFont.name
            font.pixelSize: button.height * 0.4
            font.bold: true
            color: selected ? api.memory.get('settings.theme.backgroundColor'): api.memory.get('settings.theme.textColor')
            anchors { top: parent.top; bottom: parent.bottom }

            width: labelFake.width
            Behavior on width { PropertyAnimation { duration: 200; easing.type: Easing.OutQuad } }

            clip: true
            verticalAlignment: Text.AlignVCenter
        }
    }

    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            activated();
            sfxAccept.play();
        }
    }
}