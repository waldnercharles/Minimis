import QtQuick 2.0
import QtQuick.Layouts 1.11

FocusScope {
    id: root
    anchors.fill: parent

    property var categories: []

    function getPrecision(a) {
        if (!isFinite(a)) {
            return 0;
        }

        var e = 1, p = 0;
        while (Math.round(a * e) / e !== a) {
            e *= 10;
            p++;
        }

        return p;
    }

    function capitalizeFirstLetter([ first, ...rest ], locale = 'en-US') {
        return first.toLocaleUpperCase(locale) + rest.join('');
    }
    function capitalize(str) {
        return capitalizeFirstLetter(str).split(/([A-Z]?[^A-Z]*)/g).join(' ');
    }

    Component.onCompleted: {
        root.categories = Object.keys(settings).map(k => ({
            name: k,
            settings: Object.values(settings[k])
        }));
    }

    Component.onDestruction: {
        loadSettings();
    }

    GamesViewHeader {
        id: header
        text: 'Settings'
    }

    property real rowHeight: vpx(50)

    ListView {
        id: categoriesListView
        property var currentCategory: root.categories[categoriesListView.currentIndex]

        focus: true
        anchors {
            top: header.bottom; bottom: parent.bottom; left: header.left;
            topMargin: vpx(20)
        }

        width: parent.width / 5.0
        keyNavigationWraps: true

        model: root.categories
        delegate: Item {
            width: ListView.view.width; height: rowHeight

            property bool selected: ListView.isCurrentItem

            Text {
                text: capitalize(modelData.name)
                color: settings.theme.textColor.value
                font.family: subtitleFont.name
                font.pixelSize: vpx(22)
                verticalAlignment: Text.AlignVCenter
                opacity: selected ? 1 : 0.2
                
                height: parent.height

                anchors.left: parent.left
                anchors.leftMargin: vpx(5)
            }
        }

        Keys.onPressed: {
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                sfxAccept.play();
                settingsListView.focus = true;

                event.accepted = true;
            }
        }

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
    }

    ListView {
        id: settingsListView

        model: categoriesListView.currentCategory.settings

        anchors {
            top: categoriesListView.top; bottom: parent.bottom; left: categoriesListView.right; right: header.right
        }

        preferredHighlightBegin: settingsListView.height / 2 - rowHeight
        preferredHighlightEnd: settingsListView.height / 2
        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 100
        clip: true

        keyNavigationWraps: true

        delegate: FocusScope {
            property bool selected: ListView.isCurrentItem && settingsListView.focus
            property var value: api.memory.get(categoriesListView.currentCategory.name + modelData.name)

            width: ListView.view.width; height: rowHeight

            Text {
                id: settingsName

                text: modelData.name
                color: settings.theme.textColor.value
                font.family: subtitleFont.name
                font.pixelSize: vpx(20)
                verticalAlignment: Text.AlignVCenter
                opacity: selected ? 1 : 0.2

                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: vpx(5)
            }

            Text {
                id: settingsValue

                text: capitalizeFirstLetter((modelData.type != 'array' ? value : modelData.values[value]).toString())
                color: settings.theme.textColor.value
                font.family: subtitleFont.name
                font.pixelSize: vpx(20)
                verticalAlignment: Text.AlignVCenter
                opacity: selected ? 1.0 : 0.2

                height: parent.height
                anchors.right: parent.right
                anchors.rightMargin: vpx(5)
            }

            Keys.onLeftPressed: {
                event.accepted = true;
                sfxToggle.play();
                decrementSettingValue();
            }

            Keys.onRightPressed: {
                event.accepted = true;
                sfxToggle.play();
                incrementSettingValue();
            }

            Keys.onPressed: {
                if (event.isAutoRepeat) {
                    return;
                }

                if (api.keys.isAccept(event)) {
                    event.accepted = true;
                    sfxToggle.play();
                    incrementSettingValue();
                }

                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    sfxBack.play();
                    categoriesListView.focus = true;
                }
            }

            function incrementSettingValue() {
                var newValue = value;

                switch (modelData.type) {
                    case 'bool':
                        newValue = !value;
                        break;
                    case 'int':
                        newValue = parseInt(value) + 1;
                        break;
                    case 'real':
                        newValue = (parseFloat(value) + parseFloat(modelData.delta)).toFixed(getPrecision(modelData.delta));
                        break;
                    case 'array':
                        newValue = (parseInt(value) + modelData.values.length + 1) % modelData.values.length
                        break;
                }

                if (modelData.min != null) {
                    newValue = Math.max(newValue, modelData.min);
                }

                if (modelData.max != null) {
                    newValue = Math.min(newValue, modelData.max);
                }

                api.memory.set(categoriesListView.currentCategory.name + modelData.name, newValue);
            }

            function decrementSettingValue() {
                var newValue = value;

                switch (modelData.type) {
                    case 'bool':
                        newValue = !value;
                        break;
                    case 'int':
                        newValue = parseInt(value) - 1;
                        break;
                    case 'real':
                        newValue = (parseFloat(value) - parseFloat(modelData.delta)).toFixed(getPrecision(modelData.delta));
                        break;
                    case 'array':
                        newValue = (parseInt(value) + modelData.values.length - 1) % modelData.values.length
                        break;
                }

                if (modelData.min != null) {
                    newValue = Math.max(newValue, modelData.min);
                }

                if (modelData.max != null) {
                    newValue = Math.min(newValue, modelData.max);
                }

                api.memory.set(categoriesListView.currentCategory.name + modelData.name, newValue);
            }
        }

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
    }
}