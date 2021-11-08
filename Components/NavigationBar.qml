import QtQuick 2.12
import QtGraphicalEffects 1.12

Item {
    id: root 

    // TODO: Add readonly to properties that can be readonly
    property string roleName: orderByFields[orderByIndex]
    property bool sortDirection: orderByDirection

    property bool active: false

    property var selectedItem
    property int selectedItemIndex: 0

    property var games: []

    property var items: []
    property var enabledItems: []
    property var itemIndexes: []

    // TODO: Use a signal instead
    property var onIndexChanged: (collectionIndex, index, indexValue) => { }

    // TODO: Consolidate this function with the one in GameDelegateTitle
    function getText(item, roleName) {
        if (item == null) {
            return '';
        }

        const value = item[roleName];
        switch (roleName) {
            case 'players':
                return `${value > 1 ? '1 - ' : ' '}${value}`;
            case 'lastPlayed':
                return getTimeAgo(value);
            case 'rating':
                return `${value != null ? Math.round(parseFloat(value * 100)) : 0}%`
            default:
                return value;
        }
    }

    // TODO: Consolidate this function with the one in GameDelegateTitle
    function getTimeAgo(date) {
        if (date.getTime() !== date.getTime()) {
            return 'Never';
        }

        const MINUTE = 60, HOUR = MINUTE * 60, DAY = HOUR * 24, WEEK = DAY * 7, MONTH = DAY * 30, YEAR = DAY * 365
        const secondsAgo = Math.round((+new Date() - date) / 1000)
        let divisor = null
        let unit = null

        if (secondsAgo < MINUTE) {
            [divisor, unit] = [1, 'second']
        } else if (secondsAgo < HOUR) {
            [divisor, unit] = [MINUTE, 'minute']
        } else if (secondsAgo < DAY) {
            [divisor, unit] = [HOUR, 'hour']
        } else if (secondsAgo < WEEK) {
            [divisor, unit] = [DAY, 'day']
        } else if (secondsAgo < MONTH) {
            [divisor, unit] = [WEEK, 'week']
        } else if (secondsAgo < YEAR) {
            [divisor, unit] = [MONTH, 'month']
        } else if (secondsAgo > YEAR) {
            [divisor, unit] = [YEAR, 'year']
        }

        const count = Math.floor(secondsAgo / divisor);
        return  `${count} ${unit}${(count < 1 || count == 0) ? 's' : ''} ago`
    }

    // TODO: Move to utils or something similar
    function isLetter(c) {
        return c.toLocaleUpperCase() != c.toLocaleLowerCase() || c.codePointAt(0) > 127;
    }
 
    // TODO: Split into multiple functions so that we can be more specific about what needs to be updated
    function updateNavigation() {
        var selectedIndex = 0

        let tempItems = null;
        let tempEnabledItems = null;
        let tempItemIndexes = null;

        switch (roleName) {
            case 'title':
            case 'developer':
            case 'publisher':
            case 'genre':
            {
                tempItems = ["#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
                tempEnabledItems = new Array(tempItems.length).fill(false);
                tempItemIndexes = new Array(tempItems.length).fill(null);

                if (orderByDirection == Qt.DescendingOrder) {
                    tempItems.reverse();
                }

                const selectedItemTitle = selectedItem ? selectedItem[roleName] : '#';
                let selectedItemFirstChar = selectedItemTitle.charAt(0).toUpperCase();
                selectedItemFirstChar = isLetter(selectedItemFirstChar) ? selectedItemFirstChar : '#';

                let previousFirstChar = '';
                for (let i = 0; i < games.count; i++) {
                    const role = games.get(i)[roleName];
                    let firstChar = role.charAt(0).toUpperCase();
                    firstChar = isLetter(firstChar) ? firstChar : '#';

                    if (firstChar != previousFirstChar) {
                        previousFirstChar = firstChar;

                        const charIndex = tempItems.indexOf(firstChar);
                        tempItemIndexes[charIndex] = i;
                        tempEnabledItems[charIndex] = true;

                        if (firstChar == selectedItemFirstChar) {
                            selectedItemIndex = i;
                            listView.currentIndex = charIndex;
                        }
                    }
                }

                break;
            }
            case 'releaseYear':
            case 'players':
            case 'rating':
            case 'lastPlayed':
            default: 
            {
                tempItems = [];
                tempEnabledItems = [];
                tempItemIndexes = [];

                const selectedItemValue = selectedItem ? getText(selectedItem, roleName) : null;

                let previousValue = null;
                for (let i = 0; i < games.count; i++) {
                    const game = games.get(i);
                    const value = getText(game, roleName);

                    if (value != previousValue) {
                        previousValue = value;

                        tempItems.push(value);
                        tempItemIndexes[tempItems.length - 1] = i;
                        tempEnabledItems[tempItems.length - 1] = true;

                        if (value == selectedItemValue) {
                            selectedItemIndex = i;
                            listView.currentIndex = tempItems.length - 1;
                        }
                    }
                }
                break;
            }
        }
            
        items = tempItems;
        enabledItems = tempEnabledItems;
        itemIndexes = tempItemIndexes;
    }

    // TODO: Remove; Use signal
    function updateIndex() {
        onIndexChanged(itemIndexes[listView.currentIndex]);
    }

    // TODO: Optimize. We shouldn't be calling updateNavigation unnecessarily.
    onActiveChanged: { updateNavigation(); }
    onGamesChanged: { updateNavigation(); }
    onRoleNameChanged: { updateNavigation(); }
    onSortDirectionChanged: { updateNavigation(); }
    
    Keys.onUpPressed: { 
        sfxNav.play()
        event.accepted = true

        const startingIndex = listView.currentIndex;

        do {
            const prevIndex = listView.currentIndex;
            listView.decrementCurrentIndex();

            if (prevIndex == listView.currentIndex) {
                listView.currentIndex = startingIndex;
                break;
            }
        } while (!listView.currentItem.enabled)
        
        updateIndex();
    }      

    Keys.onDownPressed: { 
        sfxNav.play()
        event.accepted = true

        const startingIndex = listView.currentIndex;

        do {
            const prevIndex = listView.currentIndex;
            listView.incrementCurrentIndex();

            if (prevIndex == listView.currentIndex) {
                listView.currentIndex = startingIndex;
                break;
            }
        } while (!listView.currentItem.enabled)
        
        updateIndex();
    }    

    ListView {
        id: listView 

        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        model: items.length
        delegate: Item {
            enabled: !!enabledItems[index]

            opacity: enabled ? 1 : 0.33

            width: parent.width
            height: vpx(32)

            property bool selected: ListView.isCurrentItem && root.activeFocus

            Text {
                text: items[index]

                font.family: subtitleFont.name
                font.pixelSize: parent.height * 0.4
                font.bold: true

                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                
                opacity: selected ? 1 : 0.5
                color: selected ? api.memory.get('settings.globalTheme.accentColor') : api.memory.get('settings.globalTheme.textColor')

                layer.enabled: true
                layer.effect: DropShadowLow { }
            }
        }

        spacing: vpx(5)

        currentIndex: 0
        orientation: ListView.Vertical

        snapMode: ListView.SnapOneItem
        highlightMoveDuration: 0
    }
}