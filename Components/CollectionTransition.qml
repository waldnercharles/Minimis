import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9

import "../utils.js" as Utils

Rectangle {
  id: root

  property var pendingCollection

  color: "#000000"
  opacity: 0

  SequentialAnimation {
    id: fadeAnimation;
    OpacityAnimator { target: root; from: 1; to: 0; duration: 500; }
  }

  Timer {
      id: debounceTimer

      interval: 500
      repeat: false
      running: false
      onTriggered: () => { 
        fadeAnimation.restart();

        currentCollection = pendingCollection;
      }
  }

  Image {
    id: logo

    anchors.centerIn: parent
    width: root.width / 2.0
    fillMode: Image.PreserveAspectFit

    source: pendingCollection != null ? "../assets/logos/" + Utils.getPlatformName(pendingCollection.shortName) + ".svg" : ""
    sourceSize: Qt.size(root.width / 2.0, 0)

    asynchronous: false
    smooth: true
  }

  onPendingCollectionChanged: {
    currentCollection = null;

    debounceTimer.stop();
    fadeAnimation.stop();

    root.opacity = 1;

    debounceTimer.restart();
  }
}
