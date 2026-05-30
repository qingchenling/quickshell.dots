import Quickshell
import QtQuick

import qs.Components
import qs.Themes

PopupWindow {
    anchor.window: panel
    height: island.height
    width: island.width
    anchor.rect.x: (panel.width - width) / 2
    visible: island.active
    color: "transparent"

    property alias active: island.active

    Rectangle {
        id: island
        width: 100; height: 34
        color: Colors.surface; radius: 36

        property bool active: false

        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }
}
