import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQml.Models 2.10

import "../utils.js" as Utils

FocusScope {
    id: root

    property string text

    anchors {
        left: parent.left; right: parent.right; top: parent.top;
        leftMargin: vpx(settings.theme.leftMargin.value + settings.game.borderWidth.value) + (parent.width / settings.game.gameViewColumns.value * (1.0 - settings.game.scale.value) / 2.0);
        rightMargin: vpx(settings.theme.rightMargin.value + settings.game.borderWidth.value) + (parent.width / settings.game.gameViewColumns.value * (1.0 - settings.game.scale.value) / 2.0);
    }

    height: vpx(75)

    Rectangle {
        anchors.fill: parent
        color: settings.theme.backgroundColor.value

        Item {
            id: container

            anchors.fill: parent

            Rectangle {
                id: background
                color: settings.theme.accentColor.value

                width: (title.visible ? title.width : logo.width) + vpx(80)
                height: root.height
            }

            Image {
                id: logo

                height: root.height - vpx(30)
                anchors.centerIn: background

                fillMode: Image.PreserveAspectFit
                source: currentCollection ? '../assets/logos/png/' + Utils.getPlatformName(currentCollection.shortName) + '.png' : ''
                smooth: true
                asynchronous: false
                visible: false
            }

            ColorOverlay {
                anchors.fill: logo
                source: logo
                color: settings.theme.backgroundColor.value

                visible: !title.visible
            }

            Text {
                id: title

                height: root.height - vpx(30)
                anchors.centerIn: background

                text: root.text ?? currentCollection.name

                font.family: titleFont.name
                font.pixelSize: vpx(36)
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: settings.theme.backgroundColor.value

                visible: root.text || logo.status === Image.Null || logo.status === Image.Error
            }

            ListView {
                id: buttons
                focus: true

                model: ObjectModel {
                    Item {
                        id: settingsButton

                        property bool selected: ListView.isCurrentItem && root.focus

                        width: buttons.height; height: buttons.height

                        anchors {
                            top: parent.top; bottom: parent.bottom; right: parent.right;
                        }

                        Rectangle {
                            id: settingsButtonBackground

                            anchors.fill: parent;

                            radius: height / 2.0
                            color: settingsButton.selected ? settings.theme.accentColor.value : "white"
                            opacity: settingsButton.selected ? 1.0 : 0.1
                        }

                        Image {
                            id: settingsButtonIcon

                            anchors.fill: settingsButtonBackground
                            anchors.margins: settingsButtonBackground.height / 6.0

                            smooth: true
                            asynchronous: true
                            source: "../assets/icons/settings.svg"
                        }

                        Keys.onPressed: {
                            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                                event.accepted = true;
                                toSettingsView();
                            }
                        }
                    }
                }

                orientation: ListView.Horizontal
                layoutDirection: Qt.RightToLeft

                anchors.fill: parent
                anchors.centerIn: parent

                anchors.topMargin: parent.height / 4.0
                anchors.bottomMargin: anchors.topMargin
            }
        }
    }
}