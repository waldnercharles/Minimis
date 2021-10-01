import QtQuick 2.15

Item {
    id: root

    property int pixelsPerSecond: vpx(30)
    readonly property int delegateWidth: (marquee.width - marquee.spacing) / 2.0
    property alias delegate: textRepeater.delegate

    clip: true

    Row {
        id: marquee
        spacing: vpx(20)
        Repeater {
            id: textRepeater
            model: 2
        }

        NumberAnimation on x {
            id: anim

            from: 0
            to: -(root.delegateWidth + marquee.spacing)
            
            duration: Math.abs(anim.to) / root.pixelsPerSecond * 1000
            loops: Animation.Infinite

            running: root.width < root.delegateWidth

            onRunningChanged: {
                if (!running) {
                    marquee.x = 0;
                }
            }
        }
    }
}