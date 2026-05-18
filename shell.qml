//@ pragma UseQApplication
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
        bottom: 5
    }

    implicitHeight: 34
    color: "transparent"

    // left
    WorkspacesManager {}

    // right
    Row {
        anchors.right: parent.right
        height: parent.height
        spacing: 10

        Tray {}
        Clock {}
    }
}

