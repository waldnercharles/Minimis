import QtQuick 2.0
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property bool selected
    property alias text: label.text
    property alias icon: icon.source

    signal activated

    width: buttonBackground.width

    Rectangle {
        id: buttonBackground

        anchors.fill: button

        radius: vpx(5)
        color: selected ? api.memory.get('settings.theme.accentColor') : api.memory.get('settings.theme.textColor')

        opacity: selected ? 1 : 0.4

        Behavior on width { NumberAnimation { duration: 100 } }
    }

    Item {
        id: button

        width: icon.width + label.width + parent.height / 3.0
        height: root.height

        scale: selected ? 0.9 : 0.85
        Behavior on scale { NumberAnimation { duration: 100 } }

        Image {
            id: icon
            width: icon.visible ? button.height : vpx(0);
            height: icon.width;

            scale: 0.5

            source: ''
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
            id: label

            font.family: subtitleFont.name
            font.pixelSize: vpx(16)
            font.bold: true
            color: selected ? api.memory.get('settings.theme.backgroundColor'): api.memory.get('settings.theme.textColor')
            anchors { top: parent.top; bottom: parent.bottom; left: icon.right }
            anchors.leftMargin: icon.visible ? vpx(0) : parent.height / 4.0

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    // Input handling
    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            activated();
        }
    }
}