import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    // Image {
    //     id: image
    //     anchors.fill: parent

    //     asynchronous: false
    //     opacity: 1

    //     source: '../assets/defaultbg.jpg'
    //     visible: source
    //     fillMode: Image.PreserveAspectCrop
    //     smooth: false
    // }

    // ColorOverlay {
    //     anchors.fill: image
    //     source: image
    //     color: "#7715181e"
    // }

    Rectangle {
        anchors.fill: parent
        color: settings.theme.backgroundColor.value
    }
}
