import QtQuick 2.3
import SortFilterProxyModel 0.2

Item {
    anchors.fill: parent

    readonly property alias games: games
    readonly property alias model: games.sourceModel

    readonly property var metadata: roleMetadata[sorter.roleName]

    property var roleMetadata: ({
        'title': {
            type: 'string',
            getText: (value) => {
                const c = value.charAt(0);
                return isLetter(c) ? c : '#';
            }
        },
        'developer': { type: 'string' },
        'publisher': { type: 'string' },
        'genre': { type: 'string' },
        'releaseYear': { type: 'number', delta: api.memory.get('settings.cardTheme.navigationYearIncrement'), getText: (value) => value > 0 ? value : 'N/A' },
        'players': { type: 'number', icon: '\uf007', getText: (value) => value > 1 ? `1-${value}` : '1' },
        'rating': {
            type: 'number',
            delta: Math.round(api.memory.get('settings.cardTheme.navigationRatingIncrement') * 20),
            factor: 100,
            icon: '\uf005',
            getText: (value) => (value * 5).toString()
        },
        // 'lastPlayed': { type: 'number' }
    })

    ValueFilter { id: gameFilters; roleName: 'favorite'; value: true; enabled: filterByFavorites }

    FilterSorter {
        id: playCountSorter
        ValueFilter {
            roleName: 'playCount'
            value: 0
            inverted: true
        }
        enabled: orderByFields[orderByIndex] === 'lastPlayed'
        sortOrder: orderByDirection
    }

    RoleSorter {
        id: sorter
        roleName: orderByFields[orderByIndex]
        sortOrder: orderByDirection
    } 

    RegExpFilter {
        id: textFilter

        property string currentLetter

        roleName: sorter.roleName
        pattern: currentLetter ? `^${currentLetter}` : '^[^a-z]'

        caseSensitivity: Qt.CaseInsensitive

        enabled: metadata && metadata.type === 'string' 
    }

    ExpressionFilter {
        id: numberFilter

        property real currentValue: 0

        property real factor: (metadata && metadata.factor) || 1
        property real delta: (metadata && metadata.delta) || 1

        property real minimumValue: currentValue
        property real maximumValue: currentValue + delta

        property bool ignoreMin: false
        property bool ignoreMax: false

        expression: {
            currentValue; ignoreMin; ignoreMax;

            const value = Math.round(modelData[sorter.roleName] * factor);
            return (ignoreMin || minimumValue <= value) && (ignoreMax || value < maximumValue);
        }

        enabled: metadata && metadata.type === 'number' 
    }

    SortFilterProxyModel {
        id: nav

        sourceModel: games.sourceModel

        filters: [ gameFilters, textFilter, numberFilter ]
        sorters: [ playCountSorter, sorter ]

        // delayed: true
    }

    SortFilterProxyModel {
        id: games

        sourceModel: currentCollection.games

        filters: gameFilters
        sorters: [ playCountSorter, sorter ]

        // delayed: true
    }

    function nextChar(c, modifier) {
        const firstAlpha = 97;
        const lastAlpha = 122;

        var charCode = c.charCodeAt(0) + modifier;

        if (modifier > 0) {
            if (charCode < firstAlpha || isNaN(charCode)) { return 'a'; }
            if (charCode > lastAlpha) { return ''; }
        } else {
            if (charCode == firstAlpha - 1) { return ''; }
            if (charCode < firstAlpha || charCode > lastAlpha || isNaN(charCode)) { return 'z'; }
        }

        return String.fromCharCode(charCode);
    }

    function navigate(index, direction) {
        direction = direction < 0 ? -1 : 1;
        direction = direction * (orderByDirection == Qt.AscendingOrder ? 1 : -1);

        const currentValue = games.get(index)[orderBy[orderByIndex]];

        if (metadata == null) {
            return null;
        }

        if (metadata.type === 'string') {
            const currentLetter = currentValue.toLocaleLowerCase().charAt(0);
            var nextLetter = currentLetter;

            do {
                textFilter.currentLetter = nextLetter = nextChar(nextLetter, direction);
            } while (nav.count === 0 && nextLetter != currentLetter)

            const value = nav.get(0)[sorter.roleName];
            navOverlay.text = metadata.getText ? metadata.getText(value) : value;
        }

        if (metadata.type === 'number') {
            const factor = metadata.factor || 1;
            const delta = metadata.delta || 1;

            const getMinimum = (value) => delta * Math.floor(value / delta);

            const firstValue = getMinimum(Math.round((games.get(0)[sorter.roleName] ?? 0) * factor));
            const lastValue = getMinimum(Math.round((games.get(games.count - 1)[sorter.roleName] ?? 0) * factor))

            let prev = getMinimum(Math.round((currentValue ?? 0) * factor));
            let curr = prev;
            do {
                curr = getMinimum(curr) + delta * direction;

                if (firstValue <= lastValue) {
                    if (curr > lastValue) {
                        curr = firstValue;
                    } else if (curr < firstValue) {
                        curr = lastValue;
                    }
                } else {
                    if (curr < lastValue) {
                        curr = firstValue;
                    } else if (curr > firstValue) {
                        curr = lastValue;
                    }
                }

                if (prev === curr) {
                    return null;
                }

                numberFilter.ignoreMin = false;
                numberFilter.ignoreMax = false;
                numberFilter.currentValue = curr;

                if (nav.count === 0) {
                    if (direction > 0) { numberFilter.ignoreMax = true; }
                    if (direction < 0) { numberFilter.ignoreMin = true; }

                    if (nav.count > 0) {
                        curr = getMinimum(Math.round(nav.get(0)[sorter.roleName] * factor));
                    }
                }
            } while (nav.count === 0)

            const precision = factor !== delta ? Math.round(factor / delta) : 0;
            curr = (curr / factor).toFixed(precision);

            navOverlay.text = metadata.getText ? metadata.getText(curr) : curr;
        }

        navOverlay.icon = metadata ? metadata.icon || '' : '';

        return games.mapFromSource(nav.mapToSource(0));
    }

    // LetterNavigationTransition {
    //     id: navOverlay
    //     icon: (metadata ? metadata.icon : '') || ''
    // }

    function isLetter(c) {
        return c.toLocaleUpperCase() != c.toLocaleLowerCase() || c.codePointAt(0) > 127;
    }
}