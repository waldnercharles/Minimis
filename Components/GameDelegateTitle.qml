import QtQuick 2.15

Column {
    id: root

    property var game
    property bool selected

    readonly property bool titleEnabled: api.memory.get('settings.cardTheme.titleEnabled') 
    readonly property bool titleAlwaysVisible: api.memory.get('settings.cardTheme.titleAlwaysVisible')
    readonly property real titleFontSize: vpx(api.memory.get('settings.cardTheme.titleFontSize'))
    readonly property string titleColor: api.memory.get('settings.globalTheme.textColor')

    readonly property bool borderEnabled: api.memory.get('settings.cardTheme.borderEnabled')
    readonly property real borderWidth: api.memory.get('settings.cardTheme.borderWidth')

    opacity: selected ? 1 : 0.2
    visible: titleEnabled && (titleAlwaysVisible || selected)

    topPadding: gameDelegateTitlePadding + (borderEnabled ? borderWidth : 0)
    bottomPadding: gameDelegateTitlePadding

    spacing: gameDelegateTitlePadding * 0.25

    Marquee {
        id: titleScroller

        width: parent.width
        height: titleFontSize

        text: game ? game.title : ''
        selected: root.selected
    }

    Row {
        width: childrenRect.width
        height: titleFontSize

        anchors.horizontalCenter: parent.horizontalCenter

        readonly property string orderByField: orderByFields[orderByIndex]

        spacing: vpx(3)

        Text {
            color: titleColor

            text: getIcon()
            height: parent.height * 0.9

            anchors.verticalCenter: parent.verticalCenter

            font.family: fontawesome.name
            font.pixelSize: titleFontSize
            fontSizeMode: Text.VerticalFit

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            style: Text.Outline

            visible: text != ''

            function getIcon() {
                if (game == null) {
                    return ''
                }

                switch (parent.orderByField) {
                    case 'players':
                        return '\uf007'
                    case 'rating':
                        return (game.rating == null || game.rating < 0.33) ? '\uf006' : game.rating < 0.66 ? '\uf123' : '\uf005';
                    default:
                        return '';
                }
            }                
        }

        Text {
            id: sortTitle

            color: textColor

            text: getText()
            width: Math.min(sortTitleMetrics.width, root.width)
            height: parent.height

            anchors.verticalCenter: parent.verticalCenter

            font.family: subtitleFont.name
            font.pixelSize: titleFontSize
            fontSizeMode: Text.VerticalFit

            elide: sortTitleMetrics.width > root.width ? Text.ElideRight : Text.ElideNone

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            style: Text.Outline

            TextMetrics {
                id: sortTitleMetrics
                text: sortTitle.text

                font.family: subtitleFont.name
                font.pixelSize: sortTitle.font.pixelSize
            }

            function getText() {
                if (game == null) {
                    return '';
                }

                const value = game[parent.orderByField];
                switch (parent.orderByField) {
                    case 'title':
                        return game.releaseYear;
                    case 'players':
                        return `${value > 1 ? '1 - ' : ' '}${value}`;
                    case 'lastPlayed':
                        return getTimeAgo(value);
                    case 'rating':
                        return `${game.rating != null ? Math.round(parseFloat(game.rating * 100)) : 0}%`
                    default:
                        return value;
                }
            }

            function getTimeAgo(date) {
                if (date.getTime() !== date.getTime()) {
                    return 'Never';
                }

                const MINUTE = 60, HOUR = MINUTE * 60, DAY = HOUR * 24, WEEK = DAY * 7, MONTH = DAY * 30, YEAR = DAY * 365
                const secondsAgo = Math.round((+new Date() - date) / 1000)
                let divisor = null
                let unit = null

                if (secondsAgo < MINUTE) {
                    return secondsAgo + " seconds ago"
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
                return  `${count} ${unit}${(count > 1)?'s':''} ago`
            }
        }
    }
}