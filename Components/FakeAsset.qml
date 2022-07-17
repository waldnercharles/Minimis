import QtQuick 2.3
import QtMultimedia 5.9

Image {
    property var collection 
    readonly property string assetKey: settingsMetadata.library.art.values[api.memory.get('settings.library.art')]

    source: {
        if (collection != null) {
            for (var i = 0; i < collection.games.count; i++) {
                var game = collection.games.get(i);
                if (game && game.assets[assetKey]) {
                    return game.assets[assetKey] || '';
                }
            }
        }

        return '';
    }

    fillMode: Image.PreserveAspectFit

    asynchronous: !api.memory.get('settings.library.aspectRatioNative')
    visible: false
    enabled: false
}