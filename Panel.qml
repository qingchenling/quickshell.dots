import Quickshell.Services.UPower
import Quickshell
import QtQuick

import "widgets"

PanelWindow {
    id: panel
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        right: 5
        left: 5
        top: 5
    }

    implicitHeight: 34
    color: "transparent"

    // left
    Row {
        anchors.left: parent.left
        height: parent.height
        spacing: 10

        StartMenu {}
        WorkspacesManager {}
    }

    // right
    Row {
        anchors.right: parent.right
        height: parent.height
        spacing: 10

        Tray {}
        Clock {}
        Text {
            text: UPower.displayDevice.percentage*100
        }
    }
}

