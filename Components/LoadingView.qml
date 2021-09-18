import QtQuick 2.3
import QtMultimedia 5.9

Background {
    id: root

    Image {
        anchors.centerIn: parent
        source: root.visible ? '../assets/loading-spinner.png' : ''
        asynchronous: false
        smooth: true

        RotationAnimator on rotation {
            loops: Animator.Infinite;
            from: 0;
            to: 360;
            duration: 1000

            running: root.visible
        }
    }
}

