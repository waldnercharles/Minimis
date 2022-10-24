
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.10

FocusScope {
    id: root

    anchors.top: parent.bottom
    anchors.topMargin: vpx(4) * uiScale

    property alias items: dropdownItems.model
    property int checkedIndex: 0
    readonly property alias currentIndex: dropdownItems.currentIndex

    property string checkedIcon: '\uf00c'

    property string roleName

    signal activated(index: int)

    state: 'closed'

    onFocusChanged: {
        if (!root.focus && root.state === 'open') {
            root.state = 'closed';
        }
    }

    states: [
        State {
            name: 'open'
            PropertyChanges { target: dropdownItems; currentIndex: root.checkedIndex; explicit: true; restoreEntryValues: false }
        },
        State {
            name: 'closed'
            PropertyChanges { target: dropdownItems; width: 0; height: 0 }
        }
    ]

    transitions: Transition {
        NumberAnimation { target: dropdownItems; property: 'width'; duration: 150; easing.type: Easing.OutQuad }
        NumberAnimation { target: dropdownItems; property: 'height'; duration: 150; easing.type: Easing.OutQuad }
    }

    function toggle() {
        state = state == 'open' ? 'closed' : 'open';
    }

    ColumnLayout {
        id: textMetrics

        Repeater {
            model: dropdownItems.model
            delegate: Text {
                text: !!root.roleName ? model[root.roleName] : modelData
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
            readonly property bool checked: index === root.checkedIndex

            color: selected ? '#14ffffff' : 'transparent'

            width: childrenRect.width
            height: childrenRect.height

            Row {
                leftPadding: dropdownItems.delegateHeight * 0.44
                rightPadding: dropdownItems.delegateHeight * 0.44

                Text {
                    text: !!root.roleName ? model[root.roleName] : modelData

                    width: textMetrics.width
                    height: dropdownItems.delegateHeight

                    font.family: subtitleFont.name
                    font.pixelSize: height * 0.4
                    font.bold: true
                    color: checked ? api.memory.get('settings.general.accentColor') : api.memory.get('settings.general.textColor')
                    opacity: selected ? 1.0 : 0.6

                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: checked ? root.checkedIcon : ''

                    width: height
                    height: dropdownItems.delegateHeight

                    font.family: fontawesome.name
                    font.pixelSize: height * 0.4

                    color: checked ? api.memory.get('settings.general.accentColor') : api.memory.get('settings.general.textColor')
                    opacity: selected ? 1.0 : 0.6

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    ListView {
        id: dropdownItems
        anchors.centerIn: dropdownBackground

        readonly property int delegateHeight: vpx(33) * uiScale
        readonly property var fullHeight: delegateHeight * (root.items.count ?? root.items.length ?? 0)
        readonly property var maxHeight: delegateHeight * 5

        focus: root.focus && root.state == 'open'
        clip: true

        height: fullHeight > maxHeight ? maxHeight : fullHeight
        width: contentItem.childrenRect.width

        delegate: dropdownItem 
        Keys.onPressed: {
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                sfxAccept.play();
                root.activated(dropdownItems.currentIndex);
            }

            if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                event.accepted = true;
                root.state = 'closed';
                sfxBack.play();
            }
        }

        Keys.onUpPressed: { event.accepted = true; dropdownItems.decrementCurrentIndex(); sfxNav.play(); }
        Keys.onDownPressed: { event.accepted = true; dropdownItems.incrementCurrentIndex(); sfxNav.play(); }

        Rectangle {
            color: api.memory.get('settings.general.textColor')

            anchors.right: dropdownItems.right

            width: vpx(4) * uiScale
            height: visible ? dropdownItems.height * (dropdownItems.height / dropdownItems.contentHeight) : 0

            radius: width
            opacity: 0.5

            y: visible ? dropdownItems.height * (dropdownItems.contentY / dropdownItems.contentHeight) : 0

            visible: root.state === 'open' && (dropdownItems.maxHeight < dropdownItems.fullHeight)
        }
    }
}