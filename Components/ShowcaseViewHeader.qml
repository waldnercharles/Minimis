import QtQuick 2.3
import QtQml.Models 2.10
import QtGraphicalEffects 1.0

ListView {
    id: root

    height: vpx(33)

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top

        topMargin: height / 2.0
        bottomMargin: height / 2.0
    }

    spacing: vpx(12)

    orientation: ListView.Horizontal
    layoutDirection: Qt.RightToLeft

    model: ObjectModel {
        Button {
            id: settingsButton
            icon: '\uf013'

            width: root.height; height: root.height
            circle: true

            selected: root.focus && ListView.isCurrentItem

            onActivated: {
                toSettingsView();
            }

            Rectangle {
                id: dropdown

                color: '#191a1c'

                anchors.top: parent.bottom
                anchors.right: parent.right

                anchors.topMargin: vpx(4)

                height: vpx(33) * api.collections.count
                width: vpx(100)

                ListView {
                    anchors.fill: parent

                    model: api.collections
                    delegate: Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        height: vpx(33)

                        color: ListView.isCurrentItem ? '#22ffffff' : 'transparent'

                        Text {
                            anchors.fill: parent
                            text: modelData.name

                            antialiasing: true
                            renderType: Text.NativeRendering
                            font.hintingPreference: Font.PreferNoHinting
                            font.family: subtitleFont.name
                            font.pixelSize: vpx(33) * 0.4

                            color: api.memory.get('settings.theme.textColor')

                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                state: 'closed'

                states: [
                    State { name: 'open' },
                    State { name: 'closed' }
                ]

                transitions: Transition { }

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: dropdown.width; height: dropdown.height
                        radius: vpx(2)
                    }

                    layer.enabled: true
                    layer.effect: DropShadowLow { }
                }
            }
        }

        Button {
            id: sortButton
            // icon: '\uf0b0'
            text: `By Title`

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { }
        }

        Button {
            id: filterButton
            // icon: '\uf0b0'
            text: `All Games`

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { }
        }

        Button {
            id: collectionsButton
            // icon: '\uf0b0'
            text: currentCollection.name

            height: parent.height
            circle: false
            selected: root.focus && ListView.isCurrentItem

            onActivated: { }
        }
    }

    Keys.onDownPressed: {
        sfxNav.play();
        showcase.focus = true;
    }

}