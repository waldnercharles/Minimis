
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.10

FocusScope {
    id: root

    anchors.top: parent.bottom
    anchors.topMargin: vpx(4)

    property alias items: dropdownItems.model

    state: 'closed'

    states: [
        State {
            name: 'open'
            PropertyChanges { target: root; focus: true }
        },
        State {
            name: 'closed'
            PropertyChanges { target: root; focus: false }
            PropertyChanges { target: dropdownItems; width: 0; height: 0 }
        }
    ]

    transitions: Transition {
        NumberAnimation { target: dropdownItems; property: 'width'; duration: 100; easing.type: Easing.OutQuad }
        NumberAnimation { target: dropdownItems; property: 'height'; duration: 100; easing.type: Easing.OutQuad }
    }

    function toggle() {
        state = state == 'open' ? 'closed' : 'open';
    }

    ColumnLayout {
        id: textMetrics

        Repeater {
            model: dropdownItems.model
            delegate: Text {
                text: modelData
                font.family: subtitleFont.name
                font.pixelSize: dropdownItems.delegateHeight * 0.4
                font.bold: true

                opacity: 0
            }
        }
    }

    Rectangle {
        id: dropdownBackground
        
        color: '#191a1c'
        radius: vpx(4)

        width: dropdownItems.width
        height: dropdownItems.height + radius * 2
    }

    Component {
        id: dropdownItem

        Rectangle {
            readonly property bool selected: ListView.isCurrentItem

            color: selected ? '#14ffffff' : 'transparent'

            width: childrenRect.width
            height: childrenRect.height


            Row {
                leftPadding: dropdownItems.delegateHeight * 0.44
                rightPadding: dropdownItems.delegateHeight * 0.44

                Text {
                    text: modelData

                    width: textMetrics.width
                    height: dropdownItems.delegateHeight

                    font.family: subtitleFont.name
                    font.pixelSize: height * 0.4
                    font.bold: true
                    color: api.memory.get('settings.theme.textColor')
                    opacity: ListView.isCurrentItem ? 1.0 : 0.7

                    verticalAlignment: Text.AlignVCenter
                    // horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    ListView {
        id: dropdownItems
        anchors.centerIn: dropdownBackground

        focus: root.focus
        clip: true

        height: delegateHeight * api.collections.count
        width: contentItem.childrenRect.width

        readonly property int delegateHeight: vpx(33)
        delegate: dropdownItem 
    }
}