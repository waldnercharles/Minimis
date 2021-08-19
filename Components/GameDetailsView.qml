import QtQuick 2.3
import QtMultimedia 5.9
import QtGraphicalEffects 1.0

FocusScope {
    id: root
    anchors.fill: parent

    Image {
        id: art
        anchors.fill: parent

        source: selectedGame.assets.screenshot || ''
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: false
    }
}