import QtQuick 2.0
import QtQuick.Layouts 1.11

FocusScope {
    id: root
    anchors.fill: parent

    property var categories: []
    property var currentCategory: categories[categoriesListView.currentIndex]

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
        root.categories = Object.entries(settingsMetadata).map(([categoryKey, category]) => ({
            key: categoryKey,
            value: Object.entries(category).map(([settingKey, setting]) => ({
                key: settingKey,
                value: setting
            }))
        }));
    }

    GamesViewHeader {
        id: header
        text: 'Settings'
        titleOnly: true
    }

    property real rowHeight: vpx(50)

    ListView {
        id: categoriesListView

        focus: true
        anchors {
            top: header.bottom; bottom: parent.bottom; left: header.left;
            topMargin: vpx(20)
        }

        width: parent.width / 5.0
        keyNavigationWraps: true

        model: categories
        delegate: Item {
            width: ListView.view.width; height: rowHeight

            property bool selected: ListView.isCurrentItem

            Text {
                text: capitalize(modelData.key)
                color: api.memory.get('settings.theme.textColor')
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

        model: currentCategory.value

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

            property string settingKey: `settings.${currentCategory.key}.${modelData.key}`
            property var settingMetadata: modelData.value

            property var value: api.memory.get(settingKey)

            width: ListView.view.width; height: rowHeight

            Text {
                id: settingsName

                text: settingMetadata.name
                color: api.memory.get('settings.theme.textColor')
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

                text: capitalizeFirstLetter((settingMetadata.type != 'array' ? value : settingMetadata.values[value]).toString())
                color: api.memory.get('settings.theme.textColor')
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

                switch (settingMetadata.type) {
                    case 'bool':
                        newValue = !value;
                        break;
                    case 'int':
                        newValue = parseInt(value) + (settingMetadata.delta ? parseInt(settingMetadata.delta) : 1 );
                        break;
                    case 'real':
                        newValue = (parseFloat(value) + parseFloat(settingMetadata.delta)).toFixed(getPrecision(settingMetadata.delta));
                        break;
                    case 'array':
                        newValue = (parseInt(value) + settingMetadata.values.length + 1) % settingMetadata.values.length
                        break;
                }

                if (settingMetadata.min != null) {
                    newValue = Math.max(newValue, settingMetadata.min);
                }

                if (settingMetadata.max != null) {
                    newValue = Math.min(newValue, settingMetadata.max);
                }

                api.memory.set(settingKey, newValue);
            }

            function decrementSettingValue() {
                var newValue = value;

                switch (settingMetadata.type) {
                    case 'bool':
                        newValue = !value;
                        break;
                    case 'int':
                        newValue = parseInt(value) - (settingMetadata.delta ? parseInt(settingMetadata.delta) : 1 );
                        break;
                    case 'real':
                        newValue = (parseFloat(value) - parseFloat(settingMetadata.delta)).toFixed(getPrecision(settingMetadata.delta));
                        break;
                    case 'array':
                        newValue = (parseInt(value) + settingMetadata.values.length - 1) % settingMetadata.values.length
                        break;
                }

                if (settingMetadata.min != null) {
                    newValue = Math.max(newValue, settingMetadata.min);
                }

                if (settingMetadata.max != null) {
                    newValue = Math.min(newValue, settingMetadata.max);
                }

                api.memory.set(settingKey, newValue);
            }
        }

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
    }
}