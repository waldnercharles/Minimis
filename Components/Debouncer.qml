import QtQuick 2.8

Timer {
    id: root

    property bool enabled: true

    function debounce() {
        enabled ? root.restart() : root.stop();
    }
}