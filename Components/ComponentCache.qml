import QtQuick 2.15

Item {
    id: root

    property var cache: []
    property Component component

    function get() {
        if (cache.length > 0) {
            return cache.pop();
        } else {
            return component.createObject(root)
        }
    }

    function release(item) {
        item.parent = root;
        item.anchors.fill = root;

        cache.push(item);
    }

    visible: false
}