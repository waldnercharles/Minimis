import QtQuick 2.0
import QtQuick.Layouts 1.11

FocusScope {
    id: root

    anchors.fill: parent

    Item {
        id: header

        anchors {
            top: parent.top; left: parent.left; right: parent.right
        }

        height: vpx(75)

        Rectangle {
            id: titleBackground
            anchors.fill: parent

            color: settings.theme.accentColor.value
        }

        // Text {
        //     id: title
        //     anchors.fill: parent

        //     color: settings.theme.backgroundColor.value
        // }
    }

    ListView {
        focus: true

    }
}