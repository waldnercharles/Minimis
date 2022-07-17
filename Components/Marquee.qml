import QtQuick 2.15

Item {
    id: root

    readonly property real titleFontSize: vpx(gameDelegateTitleFontSize)
    readonly property string titleColor: api.memory.get('settings.general.textColor')

    property bool selected: false
    property int pixelsPerSecond: vpx(30)
    property alias text: marquee.text

    readonly property int spacing: vpx(20)

    clip: true

    Text {
        id: marquee

        width: root.selected ? Math.max(contentWidth, root.width) : root.width
        height: titleFontSize
        color: titleColor
        font.family: subtitleFont.name
        font.pixelSize: titleFontSize
        fontSizeMode: Text.VerticalFit
        elide: root.selected ? Text.ElideNone : Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        style: Text.Outline

        NumberAnimation on x {
            id: anim

            running: root.width < marquee.width && selected
            from: 0
            to: -child.x

            duration: Math.abs(anim.to) / root.pixelsPerSecond * 1000
            loops: Animation.Infinite

            onRunningChanged: {
                if (!running) {
                    marquee.x = 0;
                }
            }
        }

        Text {
            id: child

            x: marquee.width + root.spacing
            text: anim.running ? parent.text : ''
            visible: anim.running

            width: parent.width
            height: parent.height
            color: parent.color
            font: parent.font
            fontSizeMode: parent.fontSizeMode
            elide: parent.elide
            horizontalAlignment: parent.horizontalAlignment
            verticalAlignment: parent.verticalAlignment
            style: parent.style
        }
    }
}