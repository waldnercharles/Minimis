import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

// import "../utils.js" as Utils
PathView {
    id: root

    readonly property int baseItemWidth: width / 8

    width: parent.width;
    height: vpx(64)

    model: ListModel {
        ListElement {
            name: "Bill Jones"
        }
        ListElement {
            name: "Jane Doe"
        }
        ListElement {
            name: "John Smith"
        }
    }

    delegate:  Column {
        id: wrapper
        opacity: PathView.isCurrentItem ? 1 : 0.5

        width: vpx(64)

        Rectangle {
            width: vpx(64); height: vpx(64)
            border.width: vpx(2)
            border.color: 'blue'
            color: 'red'
        }
        Text {
            id: nameText
            text: name
            font.pointSize: vpx(16)

            color: 'white'
        }
    }

    path: Path {
        startX: vpx(32); startY: vpx(32)
        PathLine {
            x: root.path.startX + (vpx(64) * 3)
            y: root.path.startY
        }
    }

    pathItemCount: model.count * 5
    snapMode: PathView.SnapOneItem
    highlightRangeMode: PathView.StrictlyEnforceRange
    clip: true

    preferredHighlightBegin: 0
    preferredHighlightEnd: 0

    Keys.onLeftPressed: decrementCurrentIndex()
    Keys.onRightPressed: incrementCurrentIndex()
}

// Rectangle {
//     id: root

//     property var pendingCollection

//     color: api.memory.get('settings.theme.backgroundColor')
//     opacity: 0

//     SequentialAnimation {
//         id: fadeAnimation;
//         OpacityAnimator { target: root; from: 1; to: 0; duration: 500; }
//     }

//     Timer {
//         id: debounceTimer

//         interval: 500
//         repeat: false
//         running: false
//         onTriggered: () => { 
//             fadeAnimation.restart();
//             currentCollection = pendingCollection;
//         }
//     }

//     Item {
//         id: logoContainer
//         anchors.fill: parent

//         Image {
//             id: logo

//             anchors.centerIn: parent
//             width: root.width / 2.0
//             fillMode: Image.PreserveAspectFit

//             source: pendingCollection ? "../assets/logos/" + Utils.getPlatformName(pendingCollection.shortName) + ".svg" : ""
//             sourceSize: Qt.size(root.width / 2.0, 0)

//             asynchronous: false
//             smooth: true

//             layer.enabled: true
//             layer.effect: ColorOverlay {
//                 id: colorMask
//                 anchors.fill: logo
//                 source: logo
//                 color: api.memory.get('settings.theme.accentColor')
//             }
//         }

//         Text {
//             id: logoFallback

//             anchors.centerIn: parent

//             text: pendingCollection ? pendingCollection.name : ''

//             font.family: titleFont.name
//             font.pixelSize: vpx(128)
//             font.bold: true
//             horizontalAlignment: Text.AlignHCenter
//             verticalAlignment: Text.AlignVCenter
//             color: api.memory.get('settings.theme.accentColor')

//             visible: logo.status == Image.Null || logo.status == Image.Error
//         }

//         layer.enabled: true
//         layer.effect: DropShadow {
//             anchors.fill: logoContainer 
//             horizontalOffset: vpx(0); verticalOffset: vpx(6)

//             samples: 10
//             color: '#99000000';
//             source: logoContainer
//         }
//     }

//     onPendingCollectionChanged: {
//         if (pendingCollection != currentCollection) {
//             debounceTimer.stop();
//             fadeAnimation.stop();

//             root.opacity = 1;

//             debounceTimer.restart();
//         }
//     }
// }
