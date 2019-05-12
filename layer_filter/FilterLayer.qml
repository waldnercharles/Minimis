// Pegasus Frontend
// Copyright (C) 2017-2019  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.0
import "qrc:/qmlutils" as PegasusUtils


FocusScope {
    id: root

    signal closeRequested
    signal titleFilterChanged(string tfil)

    Keys.onPressed: {
        if (event.isAutoRepeat)
            return;

        if (api.keys.isCancel(event) || api.keys.isFilters(event)) {
            event.accepted = true;
            closeRequested();
        }
    }


    Rectangle {
        id: shade
        anchors.fill: parent

        color: "#000"
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        PegasusUtils.HorizontalSwipeArea {
            anchors.fill: parent
            enabled: panel.visible
            onClicked: closeRequested()
            onSwipeLeft: closeRequested()
        }
    }

    FilterPanel {
        id: panel
        z: 400
        focus: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.left
        visible: false

        onTitleFilterChanged: root.titleFilterChanged(tfil)

        MouseArea {
            anchors.fill: parent
            enabled: panel.visible
        }
    }


    states: [
        State {
            name: "open"; when: root.focus
            PropertyChanges { target: shade; opacity: 0.25 }
            AnchorChanges {
                target: panel
                anchors.left: parent.left
                anchors.right: undefined
            }
        }
    ]
    transitions: [
        Transition {
            to: "open"
            onRunningChanged: {
                if (running)
                    panel.visible = true;
            }
            AnchorAnimation { duration: 500; easing.type: Easing.OutCubic }
        },
        Transition {
            from: "open"
            onRunningChanged: {
                if (!running)
                    panel.visible = false;
            }
            AnchorAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
    ]
}
