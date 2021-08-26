import QtQuick 2.15
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property bool selected
    property bool circle: false

    property alias text: label.text
    property alias icon: icon.source

    signal activated

    width: buttonBackground.width

    Rectangle {
        id: buttonBackground

        anchors.fill: button

        radius: circle ? height / 2 : vpx(5)
        color: selected ? api.memory.get('settings.theme.accentColor') : api.memory.get('settings.theme.textColor')

        opacity: selected ? 1 : 0.4
    }

    Row {
        id: button
        height: root.height;
        anchors.verticalCenter: parent.verticalCenter

        property var padding: (height - icon.height) * 0.5
        spacing: padding * 0.5

        leftPadding: padding
        rightPadding: padding

        Image {
            id: icon

            height: button.height * 0.35; width: icon.visible ? height : vpx(0);
            anchors.verticalCenter: parent.verticalCenter

            sourceSize: Qt.size(icon.width, icon.height)

            fillMode: Image.PreserveAspectFit
            asynchronous: false
            smooth: true

            Behavior on opacity { NumberAnimation { duration: 100 } }

            layer.enabled: true
            layer.effect: ColorOverlay {
                anchors.fill: icon
                source: icon
                color: selected ? api.memory.get('settings.theme.backgroundColor') : api.memory.get('settings.theme.textColor')
            }

            visible: icon.status != Image.Null && icon.status != Image.Error
        }

        Text {
            id: labelFake

            font.family: subtitleFont.name
            font.pixelSize: vpx(13)
            font.bold: true

            text: label.text

            visible: false
        }

        Text {
            id: label

            font.family: subtitleFont.name
            font.pixelSize: vpx(13)
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
        }
    }
}