import QtQuick 2.8

Timer {
    id: root

    property bool enabled: true

    interval: api.memory.get('settings.cardTheme.videoPreviewDelay')

    function debounce() {
        enabled ? root.restart() : root.stop();
    }
}