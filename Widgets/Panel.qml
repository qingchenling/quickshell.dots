import Quickshell
import QtQuick

import "panel"
import "Settings"

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

    function toggleSettings() { settingsCenter.toggle() }

    // left
    Row {
        anchors.left: parent.left
        height: parent.height
        spacing: 10

        StartMenu {}
        WorkspacesManager {}
    }

    KeyTips {}

    // right
    Row {
        anchors.right: parent.right
        height: parent.height
        spacing: 10

        BatteryInfo {}
        NetworkApplet {}
        Tray {}
        Clock {}
    }

    // ── Settings center popup ──
    SettingsCenter { id: settingsCenter }
}

