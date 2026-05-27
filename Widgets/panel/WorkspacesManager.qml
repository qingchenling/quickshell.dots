import QtQuick
import Quickshell.Hyprland

import qs.Components

Row {
    spacing: 8
    height: parent.height
    Repeater {
        model: Hyprland.workspaces
        delegate: Button {
            width: 65
            height: parent.height
            active: modelData.focused
            text: modelData.id
            activeColor: "primary"
            onClicked: modelData.activate()
        }
    }
}
