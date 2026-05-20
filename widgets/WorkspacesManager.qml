import QtQuick
import Quickshell.Hyprland

import "../components"

Row {
    spacing: 8
    height: parent.height
    Repeater {
        model: Hyprland.workspaces
        delegate: MD3Card {
            width: 65
            height: parent.height
            is_active: modelData.focused
            text: modelData.id
            onClicked: modelData.activate()
        }
    }
}
