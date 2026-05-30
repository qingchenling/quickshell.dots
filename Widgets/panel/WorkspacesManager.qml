import QtQuick
import Quickshell.Hyprland

import qs.Components
import qs.Themes

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
            activeBgColor: Colors.primary
            activeFgColor: Colors.on_primary
            onClicked: modelData.activate()
        }
    }
}
