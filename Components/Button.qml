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

        property var padding: height * icon.scale / 2

        leftPadding: icon.visible ? 0 : padding
        rightPadding: label.text ? padding : 0

        scale: selected ? 0.9 : 0.85
        Behavior on scale { NumberAnimation { duration: 100 } }

        Image {
            id: icon
            width: icon.visible ? root.height : vpx(0);
            height: icon.width;

            scale: 0.5

            anchors.verticalCenter: parent.verticalCenter

            sourceSize: Qt.size(icon.width, icon.height)

            fillMode: Image.PreserveAspectFit
            asynchronous: true
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
            font.pixelSize: vpx(16)
            font.bold: true

            text: label.text

            visible: false
        }

        Text {
            id: label

            font.family: subtitleFont.name
            font.pixelSize: vpx(16)
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